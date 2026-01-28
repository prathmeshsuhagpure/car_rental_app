import 'dart:io';
import 'package:car_rent_app/services/api_service.dart';
import 'package:car_rent_app/user_screens/profile/user_profile_screen.dart';
import 'package:car_rent_app/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _driverLicenseController = TextEditingController();
  final _aadharCardController = TextEditingController();

  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  bool _isUploadingImage = false;

  String? _profileImagePath;
  String? _driverLicenseImagePath;
  String? _aadharImagePath;
  String? _selectedGender;
  DateTime? _selectedDateOfBirth;

  final ImagePicker _picker = ImagePicker();
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  // Unified Image Picker Method
  Future<void> _pickImage(String imageType) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          if (imageType == "profilePicture") {
            _profileImagePath = pickedFile.path;
          } else if (imageType == "driverLicense") {
            _driverLicenseImagePath = pickedFile.path;
          } else if (imageType == "identityProof") {
            _aadharImagePath = pickedFile.path;
          }
          //_isUploadingImage = true;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to select $imageType image');
    }
  }

  // Optimized Method to Upload Multiple Images
  Future<void> _uploadUserImages() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id;

      if (userId == null) {
        _showErrorSnackBar('User not found. Please login again.');
        return;
      }

      // Create list of files to upload
      final List<File> imageFiles = [];
      final Map<String, String> imagePaths = {};

      if (_profileImagePath != null) {
        imageFiles.add(File(_profileImagePath!));
        imagePaths["profilePicture"] = _profileImagePath!;
      }
      if (_driverLicenseImagePath != null) {
        imageFiles.add(File(_driverLicenseImagePath!));
        imagePaths["driverLicense"] = _driverLicenseImagePath!;
      }
      if (_aadharImagePath != null) {
        imageFiles.add(File(_aadharImagePath!));
        imagePaths["identityProof"] = _aadharImagePath!;
      }

      if (imageFiles.isEmpty) {
        debugPrint('No images selected. Skipping image upload.');
        return;
      }

      setState(() {
        _isUploadingImage = true;
      });

      // Call API to upload multiple images
      final response = await _apiService.uploadImages(
        imageFiles: imageFiles,
        userId: userId,
      );

      if (response['success']) {
        _showSuccessSnackBar('Images uploaded successfully');
      } else {
        _showErrorSnackBar('Failed to upload images: ${response['message']}');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to upload images');
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  // Method to show date picker
  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime(1990),
      firstDate: DateTime(1940),
      lastDate: DateTime.now().subtract(const Duration(days: 6570)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: primaryGreen,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  // Helper method to show success snackbar
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // Helper method to show error snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    _nameController.text = authProvider.user?.name ?? '';
    _emailController.text = authProvider.user?.email ?? '';
    _phoneController.text = authProvider.user?.phoneNumber ?? '';
    _driverLicenseController.text =
        authProvider.user?.driverLicenseNumber ?? '';
    _aadharCardController.text = authProvider.user?.aadharCardNumber ?? '';
    final genderFromApi = authProvider.user?.gender;
    _selectedGender =
        _genderOptions.contains(genderFromApi) ? genderFromApi : null;
    _selectedDateOfBirth = authProvider.user?.dateOfBirth;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _driverLicenseController.dispose();
    _aadharCardController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final dob = _selectedDateOfBirth!;
    final dobString =
        '${dob.year}-${dob.month.toString().padLeft(2, '0')}-${dob.day.toString().padLeft(2, '0')}';

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        bool success = await authProvider.updateProfile({
          'name': _nameController.text,
          'email': _emailController.text,
          'phoneNumber': _phoneController.text,
          'driverLicenseNumber': _driverLicenseController.text,
          'aadharCardNumber': _aadharCardController.text,
          'gender': _selectedGender,
          'dateOfBirth': dobString,
        });


        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Profile updated successfully'
                  : 'Failed to update profile: ${authProvider.error}',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: success ? primaryGreen : Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unexpected error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGray,
      appBar: CustomAppBar(
        title: 'My Profile',
        iconButton: IconButton(
          icon: const Icon(Icons.more_horiz, color: textPrimary),
          onPressed: () {},
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: cardBackground,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              color: accentGreen,
                              borderRadius: BorderRadius.circular(55),
                              border: Border.all(
                                color: primaryGreen.withValues(alpha: 0.2),
                                width: 3,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(55),
                              child: _profileImagePath != null
                                  ? Image.file(
                                      File(_profileImagePath!),
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.person,
                                          size: 50,
                                          color: primaryGreen,
                                        );
                                      },
                                    )
                                  : Image.asset(
                                      'assets/images/avatar.jpeg',
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.person,
                                          size: 50,
                                          color: primaryGreen,
                                        );
                                      },
                                    ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: primaryGreen,
                                borderRadius: BorderRadius.circular(18),
                                border:
                                    Border.all(color: Colors.white, width: 3),
                              ),
                              child: _isUploadingImage
                                  ? const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : IconButton(
                                      icon: const Icon(Icons.camera_alt),
                                      color: Colors.white,
                                      iconSize: 17,
                                      onPressed: _isUploadingImage
                                          ? null
                                          : () => _pickImage("profilePicture"),
                                    ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: _isUploadingImage
                            ? null
                            : () => _pickImage("profilePicture"),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: _isUploadingImage
                                ? Colors.grey.shade300
                                : accentGreen,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: _isUploadingImage
                              ? const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        color: primaryGreen,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'UPLOADING...',
                                      style: TextStyle(
                                        color: primaryGreen,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                )
                              : const Text(
                                  'ADD PHOTO',
                                  style: TextStyle(
                                    color: primaryGreen,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardBackground,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Personal Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: darkGray,
                        ),
                      ),
                      const SizedBox(height: 24),
                      buildModernTextField(
                          'Name', _nameController, Icons.person_outline),
                      const SizedBox(height: 20),
                      buildModernPhoneField(),
                      const SizedBox(height: 20),
                      buildModernTextField(
                          'Email', _emailController, Icons.email_outlined),
                      const SizedBox(height: 20),
                      buildGenderField(),
                      const SizedBox(height: 20),
                      buildDateOfBirthField(),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardBackground,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Documents',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: darkGray,
                        ),
                      ),
                      const SizedBox(height: 24),
                      buildModernTextField('Driver License Number',
                          _driverLicenseController, Icons.drive_eta_outlined),
                      const SizedBox(height: 16),
                      buildDocumentUploadCard(
                        'Driver License',
                        'Upload your driver license',
                        _driverLicenseImagePath,
                        _isUploadingImage,
                        () => _pickImage("driverLicense"),
                        Icons.drive_eta,
                      ),
                      const SizedBox(height: 20),
                      buildModernTextField('Aadhar Card Number',
                          _aadharCardController, Icons.credit_card_outlined),
                      const SizedBox(height: 16),
                      buildDocumentUploadCard(
                        'Aadhar Card',
                        'Upload your Aadhar card',
                        _aadharImagePath,
                        _isUploadingImage,
                        () => _pickImage("identityProof"),
                        Icons.credit_card,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: (_isLoading || _isUploadingImage)
                        ? null
                        : () async {
                            await _saveProfile();
                            await _uploadUserImages();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const UserProfileScreen()),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'UPDATE PROFILE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildModernTextField(
      String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: const TextStyle(
            fontSize: 16,
            color: darkGray,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: primaryGreen,
                size: 20,
              ),
            ),
            filled: true,
            fillColor: lightGray,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryGreen, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            hintStyle: TextStyle(color: Colors.grey[400]),
          ),
          validator: (value) {
            if (label.contains('Driver License') || label.contains('Aadhar')) {
              return null; // Optional fields
            }
            return (value == null || value.isEmpty)
                ? '$label is required'
                : null;
          },
        ),
      ],
    );
  }

  Widget buildModernPhoneField() {
    final isVerified =
        Provider.of<AuthProvider>(context).user?.isVerified ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PHONE NUMBER',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _phoneController,
          enabled: !isVerified,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.asset(
                  'assets/images/indian flag.jpeg',
                  width: 20,
                  height: 20,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.flag,
                      color: Colors.grey[600],
                      size: 20,
                    );
                  },
                ),
              ),
            ),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GENDER',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue:
              _genderOptions.contains(_selectedGender) ? _selectedGender : null,
          decoration: InputDecoration(
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.person_outline,
                color: primaryGreen,
                size: 20,
              ),
            ),
            filled: true,
            fillColor: lightGray,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryGreen, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          items: _genderOptions.map((String gender) {
            return DropdownMenuItem<String>(
              value: gender,
              child: Text(gender),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedGender = newValue;
            });
          },
          style: const TextStyle(
            fontSize: 16,
            color: darkGray,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget buildDateOfBirthField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DATE OF BIRTH',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDateOfBirth,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: lightGray,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.calendar_today_outlined,
                    color: primaryGreen,
                    size: 20,
                  ),
                ),
                Expanded(
                  child: Text(
                    _selectedDateOfBirth != null
                        ? '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}'
                        : 'Select Date of Birth',
                    style: TextStyle(
                      fontSize: 16,
                      color: _selectedDateOfBirth != null
                          ? darkGray
                          : Colors.grey[400],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildDocumentUploadCard(
    String title,
    String subtitle,
    String? imagePath,
    bool isUploading,
    VoidCallback onTap,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: lightGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: primaryGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: darkGray,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  imagePath != null ? 'Document uploaded' : subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          InkWell(
            onTap: isUploading ? null : onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isUploading ? Colors.grey.shade300 : primaryGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: isUploading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: primaryGreen,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.upload_file,
                      color: Colors.white,
                      size: 20,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
