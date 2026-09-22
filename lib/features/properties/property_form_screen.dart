import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/tanzania_locations.dart';
import '../../models/property_model.dart';

import '../../widgets/app_text_field.dart';
import 'property_list_screen.dart';
import '../dashboard/dashboard_providers.dart';
import '../auth/auth_controller.dart';

class PropertyFormScreen extends ConsumerStatefulWidget {
  final PropertyModel? propertyToEdit;
  const PropertyFormScreen({super.key, this.propertyToEdit});

  @override
  ConsumerState<PropertyFormScreen> createState() => _PropertyFormScreenState();
}

class _PropertyFormScreenState extends ConsumerState<PropertyFormScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final _codeCtrl = TextEditingController(
    text:
        'PF-PROP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
  );
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _regionCtrl = TextEditingController(text: 'Dar es Salaam');
  final _districtCtrl = TextEditingController(text: 'Kinondoni');

  // Type Specific Controllers
  String _selectedType = AppConstants.typeKiwanja;
  final _sizeCtrl = TextEditingController(text: '600 SQM');
  final _plotNoCtrl = TextEditingController(text: '105');
  final _blockNoCtrl = TextEditingController(text: 'Block B');
  final _bedroomsCtrl = TextEditingController(text: '3');
  final _bathroomsCtrl = TextEditingController(text: '2');
  final _vehicleMakeCtrl = TextEditingController(text: 'Toyota');
  final _vehicleModelCtrl = TextEditingController(text: 'Prado');
  final _vehicleYearCtrl = TextEditingController(text: '2021');
  final _vehicleRegCtrl = TextEditingController(text: 'T 992 EFG');

  String _selectedBranch = 'branch_dar';
  String _selectedStatus = AppConstants.propertyAvailable;
  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    if (widget.propertyToEdit != null) {
      final p = widget.propertyToEdit!;
      _codeCtrl.text = p.propertyCode;
      _titleCtrl.text = p.title;
      _descCtrl.text = p.description;
      _priceCtrl.text = p.price.toStringAsFixed(0);
      _locationCtrl.text = p.location;
      _regionCtrl.text = p.region;
      _districtCtrl.text = p.district;
      _selectedType =
          [
            AppConstants.typeKiwanja,
            AppConstants.typeNyumba,
            AppConstants.typeGari,
          ].contains(p.type)
          ? p.type
          : AppConstants.typeKiwanja;
      _sizeCtrl.text = p.size ?? '';
      _plotNoCtrl.text = p.plotNumber ?? '';
      _blockNoCtrl.text = p.blockNumber ?? '';
      _bedroomsCtrl.text = p.bedrooms?.toString() ?? '';
      _bathroomsCtrl.text = p.bathrooms?.toString() ?? '';
      _vehicleMakeCtrl.text = p.vehicleMake ?? '';
      _vehicleModelCtrl.text = p.vehicleModel ?? '';
      _vehicleYearCtrl.text = p.vehicleYear?.toString() ?? '';
      _vehicleRegCtrl.text = p.vehicleRegistration ?? '';
      _selectedBranch = p.branchId.isNotEmpty ? p.branchId : 'branch_dar';
      _selectedStatus =
          [
            AppConstants.propertyAvailable,
            AppConstants.propertyReserved,
            AppConstants.propertyUnderProcess,
          ].contains(p.status)
          ? p.status
          : AppConstants.propertyAvailable;
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _locationCtrl.dispose();
    _regionCtrl.dispose();
    _districtCtrl.dispose();
    _sizeCtrl.dispose();
    _plotNoCtrl.dispose();
    _blockNoCtrl.dispose();
    _bedroomsCtrl.dispose();
    _bathroomsCtrl.dispose();
    _vehicleMakeCtrl.dispose();
    _vehicleModelCtrl.dispose();
    _vehicleYearCtrl.dispose();
    _vehicleRegCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitProperty() async {
    if (_titleCtrl.text.isEmpty || _priceCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill all required property title and price fields.',
          ),
        ),
      );
      return;
    }

    setState(() => _isUploading = true);
    final repo = ref.read(propertyRepoProvider); // Changed from propertyRepositoryProvider
    final user = ref.read(authControllerProvider).value;
    final isAdmin = user?.role.toUpperCase() == AppConstants.roleSuperAdmin || 
                    user?.role.toUpperCase() == AppConstants.roleSystemAdmin;

    if (!isAdmin && (user?.branchId == null || user!.branchId!.isEmpty || user.branchId!.length != 36)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Error: Your Branch Manager account is missing a valid Branch ID. Please assign a branch in Supabase users table.',
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
      setState(() => _isUploading = false);
      return;
    }

    List<String> finalImages = widget.propertyToEdit?.images.isNotEmpty == true
        ? widget.propertyToEdit!.images
        : [];
    if (_selectedImageBytes != null && _selectedImage != null) {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${_selectedImage!.name}';
      final url = await repo.uploadPropertyImage(
        _selectedImageBytes!,
        fileName,
      );
      if (url != null) {
        finalImages = [url];
      }
    } else if (finalImages.isEmpty) {
      finalImages.add(
        'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=800&q=80',
      );
    }

    final double price =
        double.tryParse(_priceCtrl.text.replaceAll(',', '')) ?? 0.0;

    final newProperty = PropertyModel(
      id:
          widget.propertyToEdit?.id ??
          'prop_${DateTime.now().millisecondsSinceEpoch}',
      propertyCode: _codeCtrl.text.trim(),
      title: _titleCtrl.text.trim(),
      type: _selectedType,
      description: _descCtrl.text.trim(),
      price: price,
      location: _locationCtrl.text.trim(),
      region: _regionCtrl.text.trim(),
      district: _districtCtrl.text.trim(),
      size:
          _selectedType == AppConstants.typeKiwanja ||
              _selectedType == AppConstants.typeNyumba
          ? _sizeCtrl.text.trim()
          : null,
      plotNumber: _selectedType == AppConstants.typeKiwanja
          ? _plotNoCtrl.text.trim()
          : null,
      blockNumber: _selectedType == AppConstants.typeKiwanja
          ? _blockNoCtrl.text.trim()
          : null,
      surveyStatus: _selectedType == AppConstants.typeKiwanja
          ? 'Surveyed'
          : null,
      bedrooms: _selectedType == AppConstants.typeNyumba
          ? int.tryParse(_bedroomsCtrl.text)
          : null,
      bathrooms: _selectedType == AppConstants.typeNyumba
          ? int.tryParse(_bathroomsCtrl.text)
          : null,
      vehicleMake: _selectedType == AppConstants.typeGari
          ? _vehicleMakeCtrl.text.trim()
          : null,
      vehicleModel: _selectedType == AppConstants.typeGari
          ? _vehicleModelCtrl.text.trim()
          : null,
      vehicleYear: _selectedType == AppConstants.typeGari
          ? int.tryParse(_vehicleYearCtrl.text)
          : null,
      vehicleRegistration: _selectedType == AppConstants.typeGari
          ? _vehicleRegCtrl.text.trim()
          : null,
      images: finalImages,
      documents: ['Property_Title_Document.pdf'],
      status: _selectedStatus,
      branchId: isAdmin ? _selectedBranch : (user?.branchId ?? ''),
      createdBy: user?.uid ?? 'user_admin',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (widget.propertyToEdit != null) {
      await repo.updateProperty(newProperty);
    } else {
      await repo.createProperty(newProperty);
    }

    // Invalidate the global provider so dashboard stats refresh
    ref.invalidate(propertiesProvider);

    setState(() => _isUploading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.propertyToEdit != null
                ? 'Property updated successfully!'
                : 'Property created successfully!',
          ),
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).value;
    final isAdmin = user?.role.toUpperCase() == AppConstants.roleSuperAdmin || 
                    user?.role.toUpperCase() == AppConstants.roleSystemAdmin;
    final branches = ref.watch(branchesProvider).value ?? [];

    final isWide = MediaQuery.of(context).size.width > 600;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.propertyToEdit != null ? 'Edit Property' : 'Add New Property',
        ),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: Stepper(
              type: isWide ? StepperType.horizontal : StepperType.vertical,
              currentStep: _currentStep,
              onStepContinue: () {
                if (_currentStep < 3) {
                  setState(() => _currentStep += 1);
                } else {
                  _submitProperty();
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() => _currentStep -= 1);
                }
              },
              steps: [
                // Step 1: Basic Info & Type
                Step(
                  title: const Text('Basic'),
                  isActive: _currentStep >= 0,
                  content: Column(
                    children: [
                      AppTextField(
                        label: 'Property Code',
                        controller: _codeCtrl,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Select Property Category:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _selectedType,
                        isExpanded: true,
                        decoration: const InputDecoration(filled: true),
                        items: const [
                          DropdownMenuItem(
                            value: AppConstants.typeKiwanja,
                            child: Text('Kiwanja (Land / Plot)'),
                          ),
                          DropdownMenuItem(
                            value: AppConstants.typeNyumba,
                            child: Text('Nyumba (House / Villa)'),
                          ),
                          DropdownMenuItem(
                            value: AppConstants.typeGari,
                            child: Text('Gari (Vehicle)'),
                          ),
                        ],
                        onChanged: (val) =>
                            setState(() => _selectedType = val!),
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'Property Title',
                        hint: 'e.g. 600 SQM Prime Plot Kigamboni',
                        controller: _titleCtrl,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'Price in TZS',
                        hint: 'e.g. 50000000',
                        controller: _priceCtrl,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Property Image:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (image != null) {
                            final bytes = await image.readAsBytes();
                            setState(() {
                              _selectedImage = image;
                              _selectedImageBytes = bytes;
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.border,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: _selectedImageBytes != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(
                                    _selectedImageBytes!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                )
                              : (widget.propertyToEdit != null &&
                                    widget.propertyToEdit!.images.isNotEmpty)
                              ? Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        widget.propertyToEdit!.images.first,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black45,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'Tap to change image',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate_outlined,
                                      size: 40,
                                      color: AppColors.textSecondary,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Tap to upload image',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Step 2: Category Specific Specs
                Step(
                  title: const Text('Specs'),
                  isActive: _currentStep >= 1,
                  content: Column(
                    children: [
                      if (_selectedType == AppConstants.typeKiwanja) ...[
                        AppTextField(
                          label: 'Land Size (SQM)',
                          hint: 'e.g. 800 SQM',
                          controller: _sizeCtrl,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          label: 'Plot Number',
                          hint: 'e.g. 142',
                          controller: _plotNoCtrl,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          label: 'Block Number',
                          hint: 'e.g. Block C',
                          controller: _blockNoCtrl,
                        ),
                      ],
                      if (_selectedType == AppConstants.typeNyumba) ...[
                        AppTextField(
                          label: 'Bedrooms',
                          hint: '4',
                          controller: _bedroomsCtrl,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          label: 'Bathrooms',
                          hint: '3',
                          controller: _bathroomsCtrl,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          label: 'Property Size',
                          hint: 'e.g. 400 SQM',
                          controller: _sizeCtrl,
                        ),
                      ],
                      if (_selectedType == AppConstants.typeGari) ...[
                        AppTextField(
                          label: 'Make',
                          hint: 'Toyota',
                          controller: _vehicleMakeCtrl,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          label: 'Model',
                          hint: 'Land Cruiser V8',
                          controller: _vehicleModelCtrl,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          label: 'Year',
                          hint: '2020',
                          controller: _vehicleYearCtrl,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          label: 'Registration Number',
                          hint: 'T 884 EFG',
                          controller: _vehicleRegCtrl,
                        ),
                      ],
                    ],
                  ),
                ),

                // Step 3: Location & Description
                Step(
                  title: const Text('Location'),
                  isActive: _currentStep >= 2,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Region:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value:
                            TanzaniaLocations.allRegions.contains(
                              _regionCtrl.text,
                            )
                            ? _regionCtrl.text
                            : 'Dar es Salaam Region',
                        isExpanded: true,
                        decoration: const InputDecoration(
                          filled: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        items: TanzaniaLocations.allRegions.map((reg) {
                          return DropdownMenuItem(value: reg, child: Text(reg));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _regionCtrl.text = val;
                              final dists = TanzaniaLocations.getDistricts(val);
                              _districtCtrl.text = dists.isNotEmpty
                                  ? dists.first
                                  : '';
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 14),

                      const Text(
                        'Select District / Municipal:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Builder(
                        builder: (context) {
                          final dists = TanzaniaLocations.getDistricts(
                            _regionCtrl.text.isEmpty
                                ? 'Dar es Salaam Region'
                                : _regionCtrl.text,
                          );
                          final validDist = dists.contains(_districtCtrl.text)
                              ? _districtCtrl.text
                              : (dists.isNotEmpty ? dists.first : null);
                          return DropdownButtonFormField<String>(
                            value: validDist,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              filled: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            items: dists.map((dist) {
                              return DropdownMenuItem(
                                value: dist,
                                child: Text(dist),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _districtCtrl.text = val;
                                });
                              }
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 14),

                      AppTextField(
                        label: 'Specific Location / Street Address',
                        hint: 'e.g. Mbuyuni Street, Near Beach',
                        controller: _locationCtrl,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'Property Description',
                        hint: 'Detailed features and highlights...',
                        controller: _descCtrl,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),

                // Step 4: Branch & Status Assignment
                Step(
                  title: const Text('Publish'),
                  isActive: _currentStep >= 3,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isAdmin) ...[
                        const Text(
                          'Branch Assignment:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: branches.any((b) => b.id == _selectedBranch) 
                              ? _selectedBranch 
                              : (branches.isNotEmpty ? branches.first.id : null),
                          isExpanded: true,
                          decoration: const InputDecoration(filled: true),
                          items: branches.map((b) {
                            return DropdownMenuItem(
                              value: b.id,
                              child: Text('${b.name} (${b.code})'),
                            );
                          }).toList(),
                          onChanged: (val) =>
                              setState(() => _selectedBranch = val ?? ''),
                        ),
                        const SizedBox(height: 14),
                      ],
                      const SizedBox(height: 14),
                      const Text(
                        'Initial Status:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        isExpanded: true,
                        decoration: const InputDecoration(filled: true),
                        items: const [
                          DropdownMenuItem(
                            value: AppConstants.propertyAvailable,
                            child: Text('Available'),
                          ),
                          DropdownMenuItem(
                            value: AppConstants.propertyReserved,
                            child: Text('Reserved'),
                          ),
                          DropdownMenuItem(
                            value: AppConstants.propertyUnderProcess,
                            child: Text('Under Process'),
                          ),
                        ],
                        onChanged: (val) =>
                            setState(() => _selectedStatus = val!),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isUploading)
            Container(
              color: Colors.black45,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Uploading Image & Saving...',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
