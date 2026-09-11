import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/property_model.dart';
import '../../repositories/seed_data.dart';
import '../../widgets/app_text_field.dart';
import 'property_list_screen.dart';

class PropertyFormScreen extends ConsumerStatefulWidget {
  const PropertyFormScreen({super.key});

  @override
  ConsumerState<PropertyFormScreen> createState() => _PropertyFormScreenState();
}

class _PropertyFormScreenState extends ConsumerState<PropertyFormScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final _codeCtrl = TextEditingController(text: 'PF-PROP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}');
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

  String _selectedBranch = SeedData.branches[0].id;
  String _selectedStatus = AppConstants.propertyAvailable;
  List<String> _sampleImages = [
    'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=800&q=80',
  ];

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
        const SnackBar(content: Text('Please fill all required property title and price fields.')),
      );
      return;
    }

    final double price = double.tryParse(_priceCtrl.text.replaceAll(',', '')) ?? 0.0;

    final newProperty = PropertyModel(
      id: 'prop_${DateTime.now().millisecondsSinceEpoch}',
      propertyCode: _codeCtrl.text.trim(),
      title: _titleCtrl.text.trim(),
      type: _selectedType,
      description: _descCtrl.text.trim(),
      price: price,
      location: _locationCtrl.text.trim(),
      region: _regionCtrl.text.trim(),
      district: _districtCtrl.text.trim(),
      size: _selectedType == AppConstants.typeKiwanja || _selectedType == AppConstants.typeNyumba ? _sizeCtrl.text.trim() : null,
      plotNumber: _selectedType == AppConstants.typeKiwanja ? _plotNoCtrl.text.trim() : null,
      blockNumber: _selectedType == AppConstants.typeKiwanja ? _blockNoCtrl.text.trim() : null,
      surveyStatus: _selectedType == AppConstants.typeKiwanja ? 'Surveyed' : null,
      bedrooms: _selectedType == AppConstants.typeNyumba ? int.tryParse(_bedroomsCtrl.text) : null,
      bathrooms: _selectedType == AppConstants.typeNyumba ? int.tryParse(_bathroomsCtrl.text) : null,
      vehicleMake: _selectedType == AppConstants.typeGari ? _vehicleMakeCtrl.text.trim() : null,
      vehicleModel: _selectedType == AppConstants.typeGari ? _vehicleModelCtrl.text.trim() : null,
      vehicleYear: _selectedType == AppConstants.typeGari ? int.tryParse(_vehicleYearCtrl.text) : null,
      vehicleRegistration: _selectedType == AppConstants.typeGari ? _vehicleRegCtrl.text.trim() : null,
      images: _sampleImages,
      documents: ['Property_Title_Document.pdf'],
      status: _selectedStatus,
      branchId: _selectedBranch,
      createdBy: 'user_admin',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final repo = ref.read(propertyRepositoryProvider);
    await repo.createProperty(newProperty);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Property created successfully!')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Property'),
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          type: StepperType.horizontal,
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
                  AppTextField(label: 'Property Code', controller: _codeCtrl),
                  const SizedBox(height: 12),
                  const Text('Select Property Category:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: const InputDecoration(filled: true),
                    items: const [
                      DropdownMenuItem(value: AppConstants.typeKiwanja, child: Text('Kiwanja (Land / Plot)')),
                      DropdownMenuItem(value: AppConstants.typeNyumba, child: Text('Nyumba (House / Villa)')),
                      DropdownMenuItem(value: AppConstants.typeGari, child: Text('Gari (Vehicle)')),
                    ],
                    onChanged: (val) => setState(() => _selectedType = val!),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(label: 'Property Title', hint: 'e.g. 600 SQM Prime Plot Kigamboni', controller: _titleCtrl),
                  const SizedBox(height: 12),
                  AppTextField(label: 'Price in TZS', hint: 'e.g. 50000000', controller: _priceCtrl, keyboardType: TextInputType.number),
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
                    AppTextField(label: 'Land Size (SQM)', hint: 'e.g. 800 SQM', controller: _sizeCtrl),
                    const SizedBox(height: 12),
                    AppTextField(label: 'Plot Number', hint: 'e.g. 142', controller: _plotNoCtrl),
                    const SizedBox(height: 12),
                    AppTextField(label: 'Block Number', hint: 'e.g. Block C', controller: _blockNoCtrl),
                  ],
                  if (_selectedType == AppConstants.typeNyumba) ...[
                    AppTextField(label: 'Bedrooms', hint: '4', controller: _bedroomsCtrl, keyboardType: TextInputType.number),
                    const SizedBox(height: 12),
                    AppTextField(label: 'Bathrooms', hint: '3', controller: _bathroomsCtrl, keyboardType: TextInputType.number),
                    const SizedBox(height: 12),
                    AppTextField(label: 'Property Size', hint: 'e.g. 400 SQM', controller: _sizeCtrl),
                  ],
                  if (_selectedType == AppConstants.typeGari) ...[
                    AppTextField(label: 'Make', hint: 'Toyota', controller: _vehicleMakeCtrl),
                    const SizedBox(height: 12),
                    AppTextField(label: 'Model', hint: 'Land Cruiser V8', controller: _vehicleModelCtrl),
                    const SizedBox(height: 12),
                    AppTextField(label: 'Year', hint: '2020', controller: _vehicleYearCtrl, keyboardType: TextInputType.number),
                    const SizedBox(height: 12),
                    AppTextField(label: 'Registration Number', hint: 'T 884 EFG', controller: _vehicleRegCtrl),
                  ],
                ],
              ),
            ),

            // Step 3: Location & Description
            Step(
              title: const Text('Location'),
              isActive: _currentStep >= 2,
              content: Column(
                children: [
                  AppTextField(label: 'Location Address', hint: 'Physical location', controller: _locationCtrl),
                  const SizedBox(height: 12),
                  AppTextField(label: 'Region', hint: 'Dar es Salaam', controller: _regionCtrl),
                  const SizedBox(height: 12),
                  AppTextField(label: 'District', hint: 'Kinondoni', controller: _districtCtrl),
                  const SizedBox(height: 12),
                  AppTextField(label: 'Property Description', hint: 'Detailed features and highlights...', controller: _descCtrl, maxLines: 3),
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
                  const Text('Branch Assignment:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedBranch,
                    decoration: const InputDecoration(filled: true),
                    items: SeedData.branches.map((b) {
                      return DropdownMenuItem(value: b.id, child: Text('${b.name} (${b.code})'));
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedBranch = val!),
                  ),
                  const SizedBox(height: 14),
                  const Text('Initial Status:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(filled: true),
                    items: const [
                      DropdownMenuItem(value: AppConstants.propertyAvailable, child: Text('Available')),
                      DropdownMenuItem(value: AppConstants.propertyReserved, child: Text('Reserved')),
                      DropdownMenuItem(value: AppConstants.propertyUnderProcess, child: Text('Under Process')),
                    ],
                    onChanged: (val) => setState(() => _selectedStatus = val!),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
