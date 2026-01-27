import 'dart:convert';
import 'dart:io';
import 'package:car_rent_app/providers/auth_provider.dart';
import 'package:car_rent_app/screens/host_screens/helper/vehicle_registration_helper.dart';
import 'package:car_rent_app/services/api_service.dart';
import 'package:car_rent_app/utils/theme.dart';
import 'package:car_rent_app/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/helper.dart';
import '../../utils/user_and_car_current_location.dart';
import '../../widgets/car_images_uploads.dart';
import 'helper/location_helper.dart';

class AddCarScreen extends StatefulWidget {
  const AddCarScreen({super.key});

  @override
  State<AddCarScreen> createState() => AddCarScreenState();
}

class AddCarScreenState extends State<AddCarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _isDraftLoaded = false;

  // Controllers for text fields
  final _licensePlateController = TextEditingController();
  final _averageController = TextEditingController();
  final _dailyRateController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _landmarkController = TextEditingController();
  final _zipCodeController = TextEditingController();

  // Dropdown values
  String? _carBrands;
  String? _selectedModel;
  String? _modelYear;
  String? _selectedFuelType;
  String? _selectedTransmission;
  String? _selectedBodyType;
  String? _selectedColor;
  int _selectedSeats = 5;

  // Lists
  Set<String> selectedFeatures = {};
  List<File> carImages = [];

  bool _hasActiveFastTag = true;
  bool _instantBooking = true;
  bool _isAvailable = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: CustomAppBar(
          title: "Add New Car",
          textButton: TextButton(
            onPressed: () {
              _saveDraft();
            },
            child: Text(
              "Save Draft",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  children: [
                    Text(
                      _isDraftLoaded
                          ? 'Continue Your Car Listing'
                          : 'Fill Your Car Details.',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (_isDraftLoaded)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Draft loaded - continue where you left off',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[700],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildSectionCard(
                        'Car Photos',
                        'Add high-quality photos to attract more renters',
                        [
                          _buildImageUploadSection(),
                        ],
                      ),
                      const SizedBox(height: 20),
                      buildSectionCard(
                        'Basic Information',
                        'Enter your car\'s basic details',
                        [
                          Row(
                            children: [
                              Expanded(
                                child: _buildDropdown(
                                  'Car Brand',
                                  _carBrands,
                                  carBrands,
                                  (value) => setState(() {
                                    _carBrands = value;
                                    _selectedModel = null;
                                  }),
                                  Icons.car_rental,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildDropdown(
                                  'Model',
                                  _selectedModel, // Use the new state variable
                                  _carBrands != null
                                      ? (carModelsByBrand[_carBrands!] ?? [])
                                      : [], // Dynamically get models
                                  (value) =>
                                      setState(() => _selectedModel = value),
                                  // Update _selectedModel
                                  Icons.car_rental,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                  child: _buildDropdown(
                                'Model Year',
                                _modelYear,
                                modelYear,
                                (value) => setState(() {
                                  _modelYear = value;
                                }),
                                Icons.calendar_month,
                              )),
                              const SizedBox(width: 16),
                              Expanded(
                                child: buildVehicleRegTextField(
                                  _licensePlateController,
                                  Icons.credit_card,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Specifications
                      buildSectionCard(
                        'Specifications',
                        'Technical details about your car',
                        [
                          Row(
                            children: [
                              Expanded(
                                child: _buildDropdown(
                                  'Fuel Type',
                                  _selectedFuelType,
                                  fuelTypes,
                                  (value) =>
                                      setState(() => _selectedFuelType = value),
                                  Icons.local_gas_station,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildDropdown(
                                  'Transmission',
                                  _selectedTransmission,
                                  transmissionTypes,
                                  (value) => setState(
                                      () => _selectedTransmission = value),
                                  Icons.settings,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildDropdown(
                                  'Body Type',
                                  _selectedBodyType,
                                  bodyTypes,
                                  (value) =>
                                      setState(() => _selectedBodyType = value),
                                  Icons.directions_car,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildDropdown(
                                  'Color',
                                  _selectedColor,
                                  colors,
                                  (value) =>
                                      setState(() => _selectedColor = value),
                                  Icons.color_lens,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildSeatsSelector(),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  'Average (KM/L)',
                                  _averageController,
                                  Icons.speed,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildSwitchTile(
                            'FastTag',
                            'Has Active FastTag',
                            _hasActiveFastTag,
                            Icons.check_circle,
                            (value) =>
                                setState(() => _hasActiveFastTag = value),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Features
                      buildSectionCard(
                        'Features & Amenities',
                        'Select all features available in your car',
                        [
                          _buildFeaturesGrid(),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Pricing
                      buildSectionCard(
                        'Pricing',
                        'Set competitive rates for your car',
                        [
                          _buildTextField(
                            'Price per Day',
                            _dailyRateController,
                            Icons.currency_rupee,
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Location & Description
                      buildSectionCard(
                        'Location & Description',
                        'Help renters find and understand your car',
                        [
                          _buildDropdown(
                            'Select State',
                            _stateController.text.isNotEmpty
                                ? _stateController.text
                                : null,
                            indianStates,
                            (value) => setState(() {
                              _stateController.text = value ?? '';
                              _cityController.text = '';
                            }),
                            Icons.location_on,
                          ),
                          const SizedBox(height: 16),
                          _buildDropdown(
                            'Select City / District',
                            _cityController.text.isNotEmpty
                                ? _cityController.text
                                : null,
                            _stateController.text.isNotEmpty
                                ? citiesByState[_stateController.text] ?? []
                                : [],
                            (value) => setState(
                                () => _cityController.text = value ?? ''),
                            Icons.location_city,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            'Address Line 1',
                            _addressLine1Controller,
                            Icons.home,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            'Landmark',
                            _landmarkController,
                            Icons.place,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            'ZIP Code',
                            _zipCodeController,
                            Icons.local_post_office,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            'Car Description',
                            _descriptionController,
                            Icons.description,
                            maxLines: 4,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Availability Settings
                      buildSectionCard(
                        'Availability Settings',
                        'Configure how renters can book your car',
                        [
                          _buildSwitchTile(
                            'Instant Booking',
                            'Allow renters to book immediately without approval',
                            _instantBooking,
                            Icons.flash_on,
                            (value) => setState(() => _instantBooking = value),
                          ),
                          const SizedBox(height: 8),
                          _buildSwitchTile(
                            'Currently Available',
                            'Your car is ready for bookings',
                            _isAvailable,
                            Icons.check_circle,
                            (value) => setState(() => _isAvailable = value),
                          ),
                        ],
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: FloatingActionButton.extended(
            onPressed: _isLoading ? null : _submitForm,
            backgroundColor: _isLoading ? Colors.grey : hostPrimary,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(Icons.check),
            label: Text(
              _isLoading ? "Listing..." : " List My Car",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2196F3)),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  Widget _buildDropdown(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged,
    IconData icon,
  ) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2196F3)),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select $label';
        }
        return null;
      },
    );
  }

  Widget _buildSeatsSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[50],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.airline_seat_recline_normal, color: Colors.grey[600]),
              const SizedBox(width: 8),
              const Text('Number of Seats'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [2, 5, 7].map((seats) {
              return GestureDetector(
                onTap: () => setState(() => _selectedSeats = seats),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _selectedSeats == seats
                        ? const Color(0xFF2196F3)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _selectedSeats == seats
                          ? const Color(0xFF2196F3)
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      seats.toString(),
                      style: TextStyle(
                        color: _selectedSeats == seats
                            ? Colors.white
                            : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: availableFeatures.map((feature) {
        final isSelected = selectedFeatures.contains(feature);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                selectedFeatures.remove(feature);
              } else {
                selectedFeatures.add(feature);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF2196F3).withValues(alpha: 0.1)
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? const Color(0xFF2196F3) : Colors.grey[300]!,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Color(0xFF2196F3),
                  ),
                if (isSelected) const SizedBox(width: 4),
                Text(
                  feature,
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        isSelected ? const Color(0xFF2196F3) : Colors.black87,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildImageUploadSection() {
    return SizedBox(
      height: 120,
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              addPhoto(
                carId: "",
                carImages: carImages,
                context: context,
                onImagesAdded: (newImages) {
                  setState(() {
                    carImages.addAll(newImages);
                  });
                },
              );
            },
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey[300]!,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate,
                      color: Colors.grey[600], size: 32),
                  const SizedBox(height: 4),
                  Text(
                    'Add Photo',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Photo previews
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: carImages.map((image) {
                  return Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: FileImage(image),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _removePhoto(image),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    IconData icon,
    Function(bool) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF2196F3),
          ),
        ],
      ),
    );
  }

  void _removePhoto(File image) {
    setState(() {
      carImages.remove(image);
    });
  }

  void _saveDraft() async {
    if (carImages.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please add at least 5 images to save a draft.')),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();

    final location =
        '${_stateController.text}, ${_cityController.text}, ${_addressLine1Controller.text} ${_landmarkController.text} ${_zipCodeController.text}';

    final draft = {
      'carBrand': _carBrands,
      'selectedModel': _selectedModel,
      'modelYear': _modelYear,
      'licensePlate': _licensePlateController.text,
      'selectedFuelType': _selectedFuelType,
      'selectedTransmission': _selectedTransmission,
      'selectedBodyType': _selectedBodyType,
      'selectedColor': _selectedColor,
      'selectedSeats': _selectedSeats,
      'average': _averageController.text,
      'dailyRate': _dailyRateController.text,
      'description': _descriptionController.text,
      'location': location,
      'selectedFeatures': selectedFeatures.toList(),
      //'images': carImages.map((f) => f.path).toList(),
      'instantBooking': _instantBooking,
      'isAvailable': _isAvailable,
      'incomplete': true,
    };

    await prefs.setString('car_listing_draft', jsonEncode(draft));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Draft saved successfully!')),
    );
  }

  Future<void> checkAndLoadDraft() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? draftJson = prefs.getString('car_listing_draft');

      if (draftJson != null && draftJson.isNotEmpty) {
        final shouldLoad = await _showLoadDraftDialog();
        if (shouldLoad == true) {
          await _loadDraft(draftJson);
        }
      }
    } catch (e) {
      debugPrint('Error checking draft: $e');
    }
  }

  Future<bool?> _showLoadDraftDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Draft Found'),
          content: const Text(
            'You have a saved draft. Would you like to continue from where you left off?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Start Fresh'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Load Draft'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadDraft(String draftJson) async {
    try {
      final draft = jsonDecode(draftJson) as Map<String, dynamic>;

      setState(() {
        _carBrands = draft['carBrand'];
        _selectedModel = draft['selectedModel'];
        _modelYear = draft['modelYear'];
        _licensePlateController.text = draft['licensePlate'] ?? '';
        _selectedFuelType = draft['selectedFuelType'];
        _selectedTransmission = draft['selectedTransmission'];
        _selectedBodyType = draft['selectedBodyType'];
        _selectedColor = draft['selectedColor'];
        _selectedSeats = draft['selectedSeats'] ?? 5;
        _averageController.text = draft['average'] ?? '';
        _dailyRateController.text = draft['dailyRate'] ?? '';
        _descriptionController.text = draft['description'] ?? '';
        _instantBooking = draft['instantBooking'] ?? true;
        _isAvailable = draft['isAvailable'] ?? true;

        // Load location data
        if (draft['location'] != null) {
          final locationParts = (draft['location'] as String).split(', ');
          if (locationParts.length >= 2) {
            _stateController.text = locationParts[0].trim();
            _cityController.text = locationParts[1].trim();
            if (locationParts.length > 2) {
              _addressLine1Controller.text = locationParts[2].trim();
            }
            if (locationParts.length > 4) {
              _landmarkController.text = locationParts[4].trim();
            }
            if (locationParts.length > 5) {
              _zipCodeController.text = locationParts[5].trim();
            }
          }
        }

        // Load features
        if (draft['selectedFeatures'] != null) {
          selectedFeatures = Set<String>.from(draft['selectedFeatures']);
        }

        _isDraftLoaded = true;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Draft loaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('Error loading draft: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading draft: $e')),
      );
    }
  }

  Future<void> _clearDraft() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('car_listing_draft');
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (carImages.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload at least 5 images.')),
      );
      return;
    }

    if (_carBrands == null ||
        _selectedModel == null ||
        _modelYear == null ||
        _selectedFuelType == null ||
        _selectedTransmission == null ||
        _selectedBodyType == null ||
        _selectedColor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final hostedBy = authProvider.user!.name!;
      final hostId = authProvider.user!.id;

      final address = [
        _addressLine1Controller.text,
        _landmarkController.text,
        _cityController.text,
        _stateController.text,
        _zipCodeController.text,
        'India',
      ].where((e) => e.trim().isNotEmpty).join(', ');

      final carLocation = await getCarLocation(address);

      final imageUrls = await uploadCarImages(carImages, hostId);
      if (imageUrls.isEmpty) {
        throw Exception('Image upload failed');
      }

      final carData = {
        'brand': _carBrands!,
        'model': _selectedModel!,
        'year': int.parse(_modelYear!),
        'licensePlate': _licensePlateController.text.trim(),
        'fuelType': _selectedFuelType!,
        'transmission': _selectedTransmission!,
        'category': _selectedBodyType!,
        'color': _selectedColor!,
        'seats': _selectedSeats,
        'average': _averageController.text,
        'hasActiveFastTag': _hasActiveFastTag,
        'features': selectedFeatures.toList(),
        'originalPrice': _dailyRateController.text,
        'description': _descriptionController.text,
        'instantBooking': _instantBooking,
        'isAvailable': _isAvailable,
        'hostedBy': hostedBy,
        'hostId': hostId,
        'rating': 0.0,
        'reviews': 0,
        'images': imageUrls,
        'location': {
          'type': 'Point',
          'coordinates': [
            carLocation.longitude, // ⚠️ lng first
            carLocation.latitude,
          ],
          'address': address,
        },
      };

      final token = await _apiService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      await _apiService.createCarWithMap(carData, token);

      await _clearDraft();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Car listed successfully with ${imageUrls.length} images',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      debugPrint('Error listing car: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error listing car: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _licensePlateController.dispose();
    _averageController.dispose();
    _dailyRateController.dispose();
    _descriptionController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _addressLine1Controller.dispose();
    _landmarkController.dispose();
    _zipCodeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
