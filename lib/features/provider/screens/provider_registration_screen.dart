import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/provider_service.dart';

/// استمارة تسجيل مقدم الخدمة الكاملة، مقسّمة إلى 3 خطوات (Stepper)
/// لتفادي صفحة طويلة مزدحمة على الهاتف.
class ProviderRegistrationScreen extends StatefulWidget {
  const ProviderRegistrationScreen({super.key});

  @override
  State<ProviderRegistrationScreen> createState() =>
      _ProviderRegistrationScreenState();
}

class _ProviderRegistrationScreenState
    extends State<ProviderRegistrationScreen> {
  final _providerService = ProviderService();
  final _picker = ImagePicker();

  int _currentStep = 0;
  bool _isLoading = false;
  String? _error;

  // بيانات عامة
  final _bioController = TextEditingController();
  final _experienceController = TextEditingController();
  final _priceController = TextEditingController();
  final _nationalIdController = TextEditingController();

  // قوائم من قاعدة البيانات
  List<Map<String, dynamic>> _cities = [];
  List<Map<String, dynamic>> _areas = [];
  List<Map<String, dynamic>> _categories = [];

  // القيم المختارة
  String? _selectedCityId;
  String? _selectedAreaId;
  String? _selectedCategoryId;
  // ملاحظة: في هذا الإصدار المبسّط نربط الفئة مباشرة كخدمة placeholder؛
  // لاحقًا تُستبدل بقائمة "services" الفعلية المرتبطة بالفئة المختارة.

  File? _frontIdImage;
  File? _backIdImage;
  File? _selfieImage;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final cities = await _providerService.getCities();
    final categories = await _providerService.getCategories();
    setState(() {
      _cities = cities;
      _categories = categories;
    });
  }

  Future<void> _loadAreas(String cityId) async {
    final areas = await _providerService.getAreas(cityId);
    setState(() {
      _areas = areas;
      _selectedAreaId = null;
    });
  }

  Future<void> _pickImage(void Function(File) onPicked) async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      onPicked(File(picked.path));
      setState(() {});
    }
  }

  bool get _canSubmit =>
      _selectedCityId != null &&
      _selectedAreaId != null &&
      _selectedCategoryId != null &&
      _nationalIdController.text.trim().isNotEmpty &&
      _frontIdImage != null &&
      _backIdImage != null &&
      _selfieImage != null;

  Future<void> _submit() async {
    if (!_canSubmit) {
      setState(() => _error = 'أكمل كل البيانات والصور المطلوبة أولًا');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await _providerService.registerProvider(
        bio: _bioController.text.trim(),
        yearsExperience: int.tryParse(_experienceController.text) ?? 0,
        cityId: _selectedCityId!,
        areaId: _selectedAreaId!,
        categoryId: _selectedCategoryId!,
        serviceId: _selectedCategoryId!, // مبسّط مؤقتًا (راجع الملاحظة أعلاه)
        basePrice: double.tryParse(_priceController.text) ?? 0,
        nationalIdNumberPlaceholder: _frontIdImage!,
        nationalIdNumber: _nationalIdController.text.trim(),
        frontIdImage: _frontIdImage!,
        backIdImage: _backIdImage!,
        selfieImage: _selfieImage!,
      );
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('تم إرسال طلبك بنجاح'),
          content: const Text(
            'حسابك الآن قيد المراجعة من الإدارة. ستصلك رسالة عند الموافقة.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('حسنًا'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() => _error = 'خطأ: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل كمقدم خدمة')),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 2) {
            setState(() => _currentStep++);
          } else {
            _submit();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) setState(() => _currentStep--);
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : details.onStepContinue,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text(_currentStep == 2 ? 'إرسال للمراجعة' : 'التالي'),
                  ),
                ),
                if (_currentStep > 0) ...[
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text('رجوع'),
                  ),
                ],
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('البيانات الأساسية'),
            isActive: _currentStep >= 0,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _bioController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'نبذة عن خبرتك',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _experienceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'سنوات الخبرة',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedCityId,
                  decoration: InputDecoration(
                    labelText: 'المدينة',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  items: _cities
                      .map((c) => DropdownMenuItem(
                            value: c['id'] as String,
                            child: Text(c['name_ar']),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedCityId = value);
                    if (value != null) _loadAreas(value);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedAreaId,
                  decoration: InputDecoration(
                    labelText: 'المنطقة',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  items: _areas
                      .map((a) => DropdownMenuItem(
                            value: a['id'] as String,
                            child: Text(a['name_ar']),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedAreaId = value),
                ),
              ],
            ),
          ),
          Step(
            title: const Text('الخدمة والسعر'),
            isActive: _currentStep >= 1,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  decoration: InputDecoration(
                    labelText: 'فئة الخدمة',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  items: _categories
                      .map((c) => DropdownMenuItem(
                            value: c['id'] as String,
                            child: Text(c['name_ar']),
                          ))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedCategoryId = value),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'السعر الابتدائي (أوقية)',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          Step(
            title: const Text('التحقق من الهوية'),
            isActive: _currentStep >= 2,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _nationalIdController,
                  decoration: InputDecoration(
                    labelText: 'رقم البطاقة الوطنية',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                _ImagePickerTile(
                  label: 'صورة البطاقة (الأمام)',
                  file: _frontIdImage,
                  onTap: () => _pickImage((f) => _frontIdImage = f),
                ),
                const SizedBox(height: 12),
                _ImagePickerTile(
                  label: 'صورة البطاقة (الخلف)',
                  file: _backIdImage,
                  onTap: () => _pickImage((f) => _backIdImage = f),
                ),
                const SizedBox(height: 12),
                _ImagePickerTile(
                  label: 'صورة شخصية (سيلفي)',
                  file: _selfieImage,
                  onTap: () => _pickImage((f) => _selfieImage = f),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePickerTile extends StatelessWidget {
  final String label;
  final File? file;
  final VoidCallback onTap;

  const _ImagePickerTile({
    required this.label,
    required this.file,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              file != null ? Icons.check_circle : Icons.add_a_photo,
              color: file != null ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(file != null ? '$label ✓ تم الاختيار' : label)),
          ],
        ),
      ),
    );
  }
}
