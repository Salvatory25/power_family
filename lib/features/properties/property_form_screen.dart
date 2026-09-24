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

  // New Fields
  String _selectedFuelType = 'Petrol';
  String _selectedTransmission = 'Automatic';
  String _selectedBodyType = 'SUV';
  String _selectedHouseType = 'House';
  String _selectedHouseCondition = 'New';
  String _selectedDocumentation = 'Title Deed';
  String _selectedVehicleCondition = 'Used';
  final _colorCtrl = TextEditingController(text: 'White');
  final _mileageCtrl = TextEditingController(text: '0');

  // Acquisition Plans
  List<String> _allowedAcquisitionPlans = ['FULL_PAYMENT'];

  String _selectedBranch = 'branch_dar';
  String _selectedStatus = AppConstants.propertyAvailable;
  List<XFile> _selectedImages = [];
  List<Uint8List> _selectedImagesBytes = [];
  List<String> _existingImages = [];
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
      _selectedFuelType = p.fuelType ?? 'Petrol';
      _selectedTransmission = p.transmission ?? 'Automatic';
      _selectedBodyType = p.bodyType ?? 'SUV';
      _selectedHouseType = p.houseType ?? 'House';
      _selectedHouseCondition = p.houseCondition ?? 'New';
      _selectedDocumentation = p.documentation ?? 'Title Deed';
      _selectedVehicleCondition = p.vehicleCondition ?? 'Used';
      _colorCtrl.text = p.color ?? '';
      _mileageCtrl.text = p.vehicleMileage ?? '';
      
      if (p.allowedAcquisitionPlans.isNotEmpty) {
        _allowedAcquisitionPlans = List.from(p.allowedAcquisitionPlans);
      }
      
      _selectedBranch = p.branchId.isNotEmpty ? p.branchId : 'branch_dar';
      _selectedStatus =
          [
            AppConstants.propertyAvailable,
            AppConstants.propertyReserved,
            AppConstants.propertyUnderProcess,
          ].contains(p.status)
          ? p.status
          : AppConstants.propertyAvailable;
      if (p.images.isNotEmpty) {
        _existingImages = List.from(p.images);
      }
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
    _colorCtrl.dispose();
    _mileageCtrl.dispose();
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

    List<String> finalImages = List.from(_existingImages);
    
    if (_selectedImagesBytes.isNotEmpty) {
      for (int i = 0; i < _selectedImagesBytes.length; i++) {
        final bytes = _selectedImagesBytes[i];
        final file = _selectedImages[i];
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
        final url = await repo.uploadPropertyImage(bytes, fileName);
        if (url != null) {
          finalImages.add(url);
        }
      }
    }
    
    if (finalImages.isEmpty) {
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
      fuelType: _selectedType == AppConstants.typeGari ? _selectedFuelType : null,
      transmission: _selectedType == AppConstants.typeGari ? _selectedTransmission : null,
      bodyType: _selectedType == AppConstants.typeGari ? _selectedBodyType : null,
      color: _selectedType == AppConstants.typeGari ? _colorCtrl.text.trim() : null,
      vehicleMileage: _selectedType == AppConstants.typeGari ? _mileageCtrl.text.trim() : null,
      vehicleCondition: _selectedType == AppConstants.typeGari ? _selectedVehicleCondition : null,
      documentation: _selectedType == AppConstants.typeKiwanja ? _selectedDocumentation : null,
      houseType: _selectedType == AppConstants.typeNyumba ? _selectedHouseType : null,
      houseCondition: _selectedType == AppConstants.typeNyumba ? _selectedHouseCondition : null,
      images: finalImages,
      documents: ['Property_Title_Document.pdf'],
      allowedAcquisitionPlans: _allowedAcquisitionPlans,
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
                      SizedBox(
                        height: 120,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            ..._existingImages.map((url) => Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(url, width: 120, height: 120, fit: BoxFit.cover),
                                      ),
                                      Positioned(
                                        top: 4, right: 4,
                                        child: InkWell(
                                          onTap: () => setState(() => _existingImages.remove(url)),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                            child: const Icon(Icons.close, size: 16, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                            ..._selectedImagesBytes.asMap().entries.map((entry) {
                               final index = entry.key;
                               final bytes = entry.value;
                               return Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.memory(bytes, width: 120, height: 120, fit: BoxFit.cover),
                                      ),
                                      Positioned(
                                        top: 4, right: 4,
                                        child: InkWell(
                                          onTap: () => setState(() {
                                            _selectedImages.removeAt(index);
                                            _selectedImagesBytes.removeAt(index);
                                          }),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                            child: const Icon(Icons.close, size: 16, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                            }),
                            InkWell(
                              onTap: () async {
                                final ImagePicker picker = ImagePicker();
                                final List<XFile> images = await picker.pickMultiImage();
                                if (images.isNotEmpty) {
                                  for (var image in images) {
                                    final bytes = await image.readAsBytes();
                                    setState(() {
                                      _selectedImages.add(image);
                                      _selectedImagesBytes.add(bytes);
                                    });
                                  }
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_photo_alternate_outlined, size: 30, color: AppColors.textSecondary),
                                    SizedBox(height: 8),
                                    Text('Add Photo', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                          ],
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
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedDocumentation,
                          decoration: const InputDecoration(labelText: 'Documentation', filled: true),
                          items: ['Title Deed', 'Offer Letter', 'Other'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (val) => setState(() => _selectedDocumentation = val!),
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
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedHouseType,
                          decoration: const InputDecoration(labelText: 'Property Type', filled: true),
                          items: ['House', 'Villa', 'Apartment'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (val) => setState(() => _selectedHouseType = val!),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedHouseCondition,
                          decoration: const InputDecoration(labelText: 'Condition', filled: true),
                          items: ['New', 'Used'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (val) => setState(() => _selectedHouseCondition = val!),
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
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedVehicleCondition,
                          decoration: const InputDecoration(labelText: 'Condition', filled: true),
                          items: ['New', 'Used', 'Excellent', 'Good'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (val) => setState(() => _selectedVehicleCondition = val!),
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          label: 'Mileage (KM)',
                          hint: 'e.g. 50000',
                          controller: _mileageCtrl,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedFuelType,
                          decoration: const InputDecoration(labelText: 'Fuel Type', filled: true),
                          items: ['Petrol', 'Diesel', 'Hybrid', 'Electric'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (val) => setState(() => _selectedFuelType = val!),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedTransmission,
                          decoration: const InputDecoration(labelText: 'Transmission', filled: true),
                          items: ['Automatic', 'Manual'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (val) => setState(() => _selectedTransmission = val!),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedBodyType,
                          decoration: const InputDecoration(labelText: 'Body Type', filled: true),
                          items: ['SUV', 'Sedan', 'Hatchback', 'Pickup', 'Van', 'Wagon', 'Other'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (val) => setState(() => _selectedBodyType = val!),
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          label: 'Color',
                          hint: 'e.g. Pearl White',
                          controller: _colorCtrl,
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
                  title: const Text('Publish & Options'),
                  isActive: _currentStep >= 3,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Allowed Acquisition Plans:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        children: [
                          FilterChip(
                            label: const Text('Full Payment'),
                            selected: _allowedAcquisitionPlans.contains('FULL_PAYMENT'),
                            onSelected: (val) {
                              setState(() {
                                if (val) _allowedAcquisitionPlans.add('FULL_PAYMENT');
                                else _allowedAcquisitionPlans.remove('FULL_PAYMENT');
                              });
                            },
                          ),
                          FilterChip(
                            label: const Text('Installment Plan'),
                            selected: _allowedAcquisitionPlans.contains('INSTALLMENT'),
                            onSelected: (val) {
                              setState(() {
                                if (val) _allowedAcquisitionPlans.add('INSTALLMENT');
                                else _allowedAcquisitionPlans.remove('INSTALLMENT');
                              });
                            },
                          ),
                          FilterChip(
                            label: const Text('Kikoba Package'),
                            selected: _allowedAcquisitionPlans.contains('KIKOBA'),
                            onSelected: (val) {
                              setState(() {
                                if (val) _allowedAcquisitionPlans.add('KIKOBA');
                                else _allowedAcquisitionPlans.remove('KIKOBA');
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
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
