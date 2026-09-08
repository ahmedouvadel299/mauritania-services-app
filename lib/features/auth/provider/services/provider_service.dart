import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase_client.dart';

/// كل منطق تسجيل مقدم الخدمة: رفع الصور للـ Storage الخاص،
/// ثم إنشاء صفوف service_providers + identity_documents + provider_services.
class ProviderService {
  final _client = AppSupabase.client;

  Future<List<Map<String, dynamic>>> getCities() async {
    final res = await _client.from('cities').select().eq('is_active', true);
    return List<Map<String, dynamic>>.from(res);
  }

  Future<List<Map<String, dynamic>>> getAreas(String cityId) async {
    final res = await _client
        .from('areas')
        .select()
        .eq('city_id', cityId)
        .eq('is_active', true);
    return List<Map<String, dynamic>>.from(res);
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final res =
        await _client.from('service_categories').select().eq('is_active', true);
    return List<Map<String, dynamic>>.from(res);
  }

  /// يرفع صورة إلى Bucket خاص (identity-documents) ويرجع المسار الداخلي
  /// (وليس رابطًا عامًا — البكت غير عام أصلًا).
  Future<String> _uploadPrivateFile({
    required File file,
    required String bucket,
    required String path,
  }) async {
    await _client.storage.from(bucket).upload(
          path,
          file,
          fileOptions: const FileOptions(upsert: true),
        );
    return path;
  }

  /// الخطوة الكاملة: ينشئ provider profile، يرفع وثائق الهوية،
  /// يربط الخدمة المختارة، كل شيء بحالة "قيد المراجعة".
  Future<void> registerProvider({
    required String bio,
    required int yearsExperience,
    required String cityId,
    required String areaId,
    required String categoryId,
    required String serviceId,
    required double basePrice,
    required File nationalIdNumberPlaceholder, // احتياطي، لا يُستخدم مباشرة
    required String nationalIdNumber,
    required File frontIdImage,
    required File backIdImage,
    required File selfieImage,
  }) async {
    final userId = _client.auth.currentUser!.id;

    // 1) أنشئ صف service_providers أولًا لنحصل على provider_id
    final providerRow = await _client
        .from('service_providers')
        .insert({
          'user_id': userId,
          'bio': bio,
          'years_experience': yearsExperience,
          'city_id': cityId,
          'area_id': areaId,
          'verification_status': 'pending_verification',
        })
        .select()
        .single();
    final providerId = providerRow['id'] as String;

    // 2) ارفع الصور الثلاث إلى bucket خاص، بمسار فريد لكل مقدم خدمة
    final frontPath = await _uploadPrivateFile(
      file: frontIdImage,
      bucket: 'identity-documents',
      path: '$providerId/front_id.jpg',
    );
    final backPath = await _uploadPrivateFile(
      file: backIdImage,
      bucket: 'identity-documents',
      path: '$providerId/back_id.jpg',
    );
    final selfiePath = await _uploadPrivateFile(
      file: selfieImage,
      bucket: 'identity-documents',
      path: '$providerId/selfie.jpg',
    );

    // 3) احفظ بيانات الهوية (الرقم يُفترض تشفيره لاحقًا عبر Edge Function
    // في مرحلة إنتاجية حقيقية — هنا نخزنه كما هو مؤقتًا لبيئة التطوير فقط)
    await _client.from('identity_documents').insert({
      'provider_id': providerId,
      'national_id_number_encrypted': nationalIdNumber,
      'front_image_path': frontPath,
      'back_image_path': backPath,
      'selfie_image_path': selfiePath,
    });

    // 4) اربط الخدمة والسعر
    await _client.from('provider_services').insert({
      'provider_id': providerId,
      'service_id': serviceId,
      'price_type': 'fixed',
      'base_price': basePrice,
    });
  }
}
