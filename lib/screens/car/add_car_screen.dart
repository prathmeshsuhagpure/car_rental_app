import 'dart:convert';
import 'dart:io';
import 'package:car_rent_app/providers/auth_provider.dart';
import 'package:car_rent_app/services/api_service.dart';
import 'package:car_rent_app/utils/theme.dart';
import 'package:car_rent_app/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/car_model.dart';
import '../../utils/helper.dart';

class AddCarScreen extends StatefulWidget {
  const AddCarScreen({super.key});

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  // Controllers for text fields
  final _licensePlateController = TextEditingController();
  final _averageController = TextEditingController();
  final _dailyRateController = TextEditingController();
  final _weeklyRateController = TextEditingController();
  final _monthlyRateController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
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

  // Feature selections
  Set<String> _selectedFeatures = {};

  final ImagePicker _picker = ImagePicker();
  List<File> _carImages = [];

  // Availability
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
              // Progress indicator
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: 0.3,
                            backgroundColor: Colors.grey[200],
                            color: const Color(0xFF2196F3),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Step 1 of 3',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Basic Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
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
                      // Car Images Section
                      _buildSectionCard(
                        'Car Photos',
                        'Add high-quality photos to attract more renters',
                        [
                          _buildImageUploadSection(),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Basic Information
                      _buildSectionCard(
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
                                      (value) =>
                                      setState(() {
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
                                        (value) =>
                                        setState(() {
                                          _modelYear = value;
                                        }),
                                    Icons.calendar_month,
                                  )),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  'Vehicle Registration Number',
                                  'AB12CD3456',
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
                      _buildSectionCard(
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
                                      (value) =>
                                      setState(
                                              () =>
                                          _selectedTransmission = value),
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
                                  '15.00',
                                  _averageController,
                                  Icons.speed,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Features
                      _buildSectionCard(
                        'Features & Amenities',
                        'Select all features available in your car',
                        [
                          _buildFeaturesGrid(),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Pricing
                      _buildSectionCard(
                        'Pricing',
                        'Set competitive rates for your car',
                        [
                          _buildTextField(
                            'Daily Rate (₹)',
                            '500',
                            _dailyRateController,
                            Icons.currency_rupee,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  'Weekly Rate (₹)',
                                  '3500',
                                  _weeklyRateController,
                                  Icons.date_range,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  'Monthly Rate (₹)',
                                  '15000',
                                  _monthlyRateController,
                                  Icons.calendar_month,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Location & Description
                      _buildSectionCard(
                        'Location & Description',
                        'Help renters find and understand your car',
                        [
                          _buildTextField(
                            'Enter State',
                            'Street address or landmark',
                            _stateController,
                            Icons.location_on,
                          ),
                          const SizedBox(height: 10),
                          _buildTextField(
                            'Enter City',
                            'Street address or landmark',
                            _cityController,
                            Icons.location_on,
                          ),
                          const SizedBox(height: 10),
                          _buildTextField(
                            'Address Line 1',
                            'Street address or landmark',
                            _addressLine1Controller,
                            Icons.location_on,
                          ),
                          const SizedBox(height: 10),
                          _buildTextField(
                            'Address Line 2',
                            'Street address or landmark',
                            _addressLine2Controller,
                            Icons.location_on,
                          ),
                          const SizedBox(height: 10),
                          _buildTextField(
                            'Enter Land Mark',
                            'Street address or landmark',
                            _landmarkController,
                            Icons.location_on,
                          ),
                          const SizedBox(height: 10),
                          _buildTextField(
                            'Enter ZIP Code',
                            'Street address or landmark',
                            _zipCodeController,
                            Icons.location_on,
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            'Car Description',
                            'Describe your car, any special instructions, etc.',
                            _descriptionController,
                            Icons.description,
                            maxLines: 4,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Availability Settings
                      _buildSectionCard(
                        'Availability Settings',
                        'Configure how renters can book your car',
                        [
                          _buildSwitchTile(
                            'Instant Booking',
                            'Allow renters to book immediately without approval',
                            _instantBooking,
                            Icons.flash_on,
                                (value) =>
                                setState(() => _instantBooking = value),
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

  Widget _buildSectionCard(String title, String subtitle,
      List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(String label,
      String hint,
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
        hintText: hint,
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

  Widget _buildDropdown(String label,
      String? value,
      List<String> items,
      Function(String?) onChanged,
      IconData icon,) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: value,
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
        final isSelected = _selectedFeatures.contains(feature);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedFeatures.remove(feature);
              } else {
                _selectedFeatures.add(feature);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF2196F3).withOpacity(0.1)
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
          // Add photo button
          GestureDetector(
            onTap: _addPhoto,
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
                children: _carImages.map((image) {
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
                                color: Colors.black.withOpacity(0.7),
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

  Widget _buildSwitchTile(String title,
      String subtitle,
      bool value,
      IconData icon,
      Function(bool) onChanged,) {
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
            activeColor: const Color(0xFF2196F3),
          ),
        ],
      ),
    );
  }

  void _addPhoto() async {
    if (_carImages.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You can only upload up to 10 photos.')),
      );
      return;
    }

    final List<XFile>? pickedFiles = await _picker.pickMultiImage();

    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      final newFiles = pickedFiles.map((file) => File(file.path)).toList();

      if (_carImages.length + newFiles.length > 10) {
        final allowedCount = 10 - _carImages.length;
        newFiles.removeRange(allowedCount, newFiles.length);
      }

      setState(() {
        _carImages.addAll(newFiles);
      });

      if (_carImages.length < 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please upload at least 5 images.')),
        );
      }
    }
  }

  void _removePhoto(File image) {
    setState(() {
      _carImages.remove(image);
    });
  }

  void _saveDraft() async {
    if (_carImages.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please add at least 5 images to save a draft.')),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Build location string
    final location =
        '${_stateController.text}, ${_cityController
        .text}, ${_addressLine1Controller.text} ${_addressLine2Controller
        .text} ${_landmarkController.text} ${_zipCodeController.text}';

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
      'weeklyRate': _weeklyRateController.text,
      'monthlyRate': _monthlyRateController.text,
      'description': _descriptionController.text,
      'location': location,
      'selectedFeatures': _selectedFeatures.toList(),
      'images': _carImages.map((f) => f.path).toList(),
      'instantBooking': _instantBooking,
      'isAvailable': _isAvailable,
      'incomplete': true,
    };

    await prefs.setString('car_listing_draft', jsonEncode(draft));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Draft saved successfully!')),
    );
  }

  Future<void> _clearDraft() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('car_listing_draft');
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_carImages.length < 5) {
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

      setState(() {
        _isLoading = true;
      });

      try {
        final location =
            '${_stateController.text}, ${_cityController
            .text}, ${_addressLine1Controller.text}, ${_addressLine2Controller
            .text}, ${_landmarkController.text}, ${_zipCodeController.text}';

        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final String hostedBy = authProvider.user!.name.toString();
        final String hostId = authProvider.user!.id;

        // Create Car object
        final newCar = Car(
          //id: '', // Will be assigned by backend
          brand: _carBrands!,
          model: _selectedModel!,
          year: int.parse(_modelYear!),
          color: _selectedColor!,
          licensePlate: _licensePlateController.text,
          pricePerDay: double.parse(_dailyRateController.text),
          seats: _selectedSeats,
          transmission: _selectedTransmission!,
          fuelType: _selectedFuelType!,
          features: _selectedFeatures.toList(),
          images: _carImages.map((file) => file.path).toList(),
          location: location,
          availability: _isAvailable,
          category: _selectedBodyType!,
          rating: 0,
          originalPrice: _weeklyRateController.text,
          distance: "",
          hostedBy: hostedBy,
          reviews: 0,
          isFavorite: true,
          isGuestFavorite: false,
          hasActiveFastTag: true,
          hostId: hostId,
        );
        final createdCar = await _apiService.createCar(newCar);
        await _clearDraft();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Car listed successfully: ${createdCar.brand} ${createdCar
                    .model}'),
          ),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error listing car: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  @override
  void dispose() {
    _licensePlateController.dispose();
    _averageController.dispose();
    _dailyRateController.dispose();
    _weeklyRateController.dispose();
    _monthlyRateController.dispose();
    _descriptionController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _landmarkController.dispose();
    _zipCodeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}