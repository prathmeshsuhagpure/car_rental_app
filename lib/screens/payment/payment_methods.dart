import 'package:car_rent_app/models/payment_method_model.dart';
import 'package:car_rent_app/services/payment_service.dart';
import 'package:car_rent_app/widgets/custom_app_bar.dart';
import 'package:car_rent_app/widgets/price_breakup_sheet.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/booking_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../utils/helper.dart';
import '../../utils/theme.dart';
import '../../widgets/bottom_navigation_bar.dart';
import '../../widgets/month_year_selector.dart';

class PaymentMethodsScreen extends StatefulWidget {
  final double amount;
  final String currency;
  final String carId;
  final DateTime startDate;
  final DateTime endDate;
  final String pickUpLocation;
  final String dropOffLocation;
  final String carName;
  final double rating;

  const PaymentMethodsScreen({
    super.key,
    required this.amount,
    required this.currency,
    required this.carId,
    required this.startDate,
    required this.endDate,
    required this.pickUpLocation,
    required this.dropOffLocation,
    required this.carName,
    required this.rating,
  });

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  final _zipController = TextEditingController();

  //final paymentId = mongo.ObjectId().oid;

  String _selectedCountry = 'India';
  bool _agreedToTerms = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  double _calculateGST() {
    return widget.amount * 0.18; // 18% GST
  }

  double _calculatePlatformFee() {
    return 99.0; // Fixed platform fee
  }

  double _calculateFinalAmount() {
    return widget.amount + _calculateGST() + _calculatePlatformFee() + _securityDeposit();
  }

  double _securityDeposit (){
    return 5000.0;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  Future<void> _handlePayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please accept the terms and conditions'),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final bookingProvider =
          Provider.of<BookingProvider>(context, listen: false);
      final userProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = userProvider.user;
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      // Create payment method data
      final paymentData = PaymentMethod(
        cardNumber: _cardNumberController.text.trim(),
        expiryDate: _expiryDateController.text.trim(),
        cvv: _cvvController.text.trim(),
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        country: _selectedCountry,
        zip: _zipController.text.trim(),
      );

      // Process payment first
      await PaymentService().submitPaymentForm(context, paymentData);

      final totalAmount1 = _calculateFinalAmount();
      final booking = BookingModel(
        carId: widget.carId,
        startDate: widget.startDate,
        endDate: widget.endDate,
        pickUpLocation: widget.pickUpLocation,
        dropOffLocation: widget.dropOffLocation,
        amount: totalAmount1,
        paymentId: "",
        id: '',
        userId: currentUser.id,
        carName: widget.carName,
        rating: widget.rating,
        paymentStatus: '',
        bookingStatus: '',
        status: 'active',
        bookingDate: DateTime.now(),
      );

      final bookingResult = await bookingProvider.createBooking(booking);

      if (bookingResult is Map<String, dynamic> &&
          bookingResult['success'] == true) {
        if (mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Booking confirmed successfully!'),
              backgroundColor: primaryGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );

          // Navigate to home screen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const UserHomeScreen()),
            (route) => false,
          );
        }
      } else {
        final errorMsg = bookingResult is Map<String, dynamic>
            ? bookingResult['message']?.toString() ?? 'Booking failed'
            : 'Unexpected response from server';
        throw Exception(errorMsg);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(
        title: 'Payment Details',
        iconButton: IconButton(
          icon: const Icon(Icons.more_horiz, color: textPrimary),
          onPressed: () {},
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: 200,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    aspectRatio: 16 / 9,
                    viewportFraction: 0.9,
                  ),
                  items: cardImages.map((imagePath) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        image: DecorationImage(
                          image: AssetImage(imagePath),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 30),

              // Amount Display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Amount',
                          style: TextStyle(
                            fontSize: 14,
                            color: textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PriceBreakupSheet(
                                      currency: widget.currency,
                                      amount: widget.amount,
                                      gst: _calculateGST(),
                                      platformFee: _calculatePlatformFee(),
                                      totalAmount: _calculateFinalAmount(),
                                      securityDeposit: _securityDeposit(),
                                    )),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E7D57).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF2E7D57).withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.receipt_long,
                                  size: 14,
                                  color: const Color(0xFF2E7D57),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Price Breakdown',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: const Color(0xFF2E7D57),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.currency} ${_calculateFinalAmount().toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Amount to be charged to your card',
                      style: TextStyle(
                        fontSize: 12,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Card Information
              const Text(
                'Card Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),

              const SizedBox(height: 16),

              // Full Name
              _buildTextField(
                obscureText: false,
                controller: _fullNameController,
                hintText: 'Cardholder Name',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter cardholder name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Email Address
              _buildTextField(
                obscureText: false,
                controller: _emailController,
                hintText: 'Email Address',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an email address';
                  }
                  if (!RegExp(
                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                      .hasMatch(value.trim())) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Card Number
              _buildTextField(
                obscureText: false,
                controller: _cardNumberController,
                hintText: 'Card Number',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(19), // 16 digits + 3 spaces
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    String digitsOnly = newValue.text.replaceAll(' ', '');
                    if (digitsOnly.length > 16) return oldValue;

                    String formatted = '';
                    for (int i = 0; i < digitsOnly.length; i++) {
                      formatted += digitsOnly[i];
                      if ((i + 1) % 4 == 0 && i != 15) {
                        formatted += ' ';
                      }
                    }

                    return TextEditingValue(
                      text: formatted,
                      selection:
                          TextSelection.collapsed(offset: formatted.length),
                    );
                  }),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a card number';
                  }
                  final cleanValue = value.replaceAll(' ', '');
                  if (cleanValue.length != 16) {
                    return 'Enter a valid 16-digit card number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Expiry and CVV
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      obscureText: false,
                      controller: _expiryDateController,
                      hintText: 'MM/YY',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.calendar_today_outlined,
                            color: primaryGreen),
                        onPressed: () {
                          showCustomMonthYearPicker(
                              context, _expiryDateController);
                        },
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(5),
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d{0,2}\/?\d{0,2}$')),
                        ExpiryDateTextInputFormatter(),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter expiry date';
                        }
                        if (!RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$')
                            .hasMatch(value.trim())) {
                          return 'Invalid format (MM/YY)';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _cvvController,
                      hintText: 'CVV',
                      keyboardType: TextInputType.number,
                      suffixIcon: Icon(Icons.credit_card, color: primaryGreen),
                      obscureText: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter CVV';
                        }
                        if (value.length != 3) {
                          return 'Enter valid 3-digit CVV';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Country or Region
              const Text(
                'Billing Address',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),

              const SizedBox(height: 16),

              Container(
                decoration: BoxDecoration(
                  color: cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedCountry,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: textSecondary),
                  ),
                  items: [
                    'United States',
                    'Canada',
                    'United Kingdom',
                    'Germany',
                    'India'
                  ]
                      .map((country) => DropdownMenuItem(
                            value: country,
                            child: Text(
                              country,
                              style: const TextStyle(color: textPrimary),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCountry = value!;
                    });
                  },
                ),
              ),

              const SizedBox(height: 16),

              // ZIP Code
              _buildTextField(
                obscureText: false,
                controller: _zipController,
                hintText: 'ZIP Code',
                keyboardType: TextInputType.text,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a ZIP code';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // UPI Apps section
              Center(
                child: Text(
                  'Quick Payment Options',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // PhonePe Button
              _buildPaymentOption(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('PhonePe payment not implemented yet')),
                  );
                },
                imagePath: 'assets/images/phonePe.jpg',
                label: 'PhonePe',
              ),

              const SizedBox(height: 12),

              // Google Pay Button
              _buildPaymentOption(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Google Pay payment not implemented yet')),
                  );
                },
                imagePath: 'assets/images/googlepay.png',
                label: 'Google Pay',
              ),

              const SizedBox(height: 40),

              // Terms and Conditions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: _agreedToTerms,
                      onChanged: (value) {
                        setState(() {
                          _agreedToTerms = value!;
                        });
                      },
                      activeColor: primaryGreen,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                    ),
                    const Expanded(
                      child: Text(
                        'I agree to Terms & Conditions',
                        style: TextStyle(
                          fontSize: 14,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down, color: textSecondary),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handlePayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Complete Payment',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    required obscureText,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        inputFormatters: inputFormatters,
        validator: validator,
        style: const TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: textSecondary,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          suffixIcon: suffixIcon,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: InputBorder.none,
          counterText: "",
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required VoidCallback onTap,
    required String imagePath,
    required String label,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                imagePath,
                width: 32,
                height: 32,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
