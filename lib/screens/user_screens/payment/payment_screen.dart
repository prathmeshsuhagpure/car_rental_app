import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../models/booking_model.dart';
import '../../../models/car_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/booking_provider.dart';
import '../../../services/payment_service.dart';
import '../../../utils/theme.dart';
import '../../../widgets/booking_card.dart';
import '../../../widgets/bottom_navigation_bar.dart';
import '../../../widgets/custom_app_bar.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    super.key,
    required this.car,
    required this.user,
    required this.startDate,
    required this.endDate,
    required this.pickUpLocation,
    required this.dropOffLocation,
    required this.carId,
    required this.amount,
    required this.currency,
  });

  final String currency;
  final double amount;
  final String carId;
  final Car car;
  final User user;
  final DateTime startDate;
  final DateTime endDate;
  final String pickUpLocation;
  final String dropOffLocation;

  @override
  State<PaymentScreen> createState() => PaymentScreenState();
}

class PaymentScreenState extends State<PaymentScreen> {
  late BookingModel booking;
  bool _agreedToTerms = false;
  bool _isProcessing = false;
  late Razorpay _razorpay;

  String? currentOrderId;

  int get _durationInDays {
    final days = widget.endDate.difference(widget.startDate).inDays;
    return days <= 0 ? 1 : days;
  }

  double get _totalAmount {
    return widget.car.originalPrice * _durationInDays;
  }

  @override
  void initState() {
    super.initState();

    booking = BookingModel(
      id: '',
      userId: widget.user.id,
      carId: widget.car.id,
      car: widget.car,
      amount: _totalAmount,
      pickUpLocation: widget.pickUpLocation,
      dropOffLocation: widget.dropOffLocation,
      startDate: widget.startDate,
      endDate: widget.endDate,
      bookingStatus: 'pending',
      paymentStatus: 'pending',
      paymentId: null,
      rentalStatus: "",
      createdAt: DateTime.now(),
    );

    _initializeRazorpay();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  }

  double _calculateGST() {
    return widget.amount * 0.18; // 18% GST
  }

  double _calculatePlatformFee() {
    return 99.0; // Fixed platform fee
  }

  double _securityDeposit() {
    return 5000.0;
  }

  double _calculateFinalAmount() {
    return widget.amount +
        _calculateGST() +
        _calculatePlatformFee() +
        _securityDeposit();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      setState(() {
        _isProcessing = true;
      });

      final bookingProvider =
          Provider.of<BookingProvider>(context, listen: false);
      final userProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = userProvider.user;

      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      final paymentService = PaymentService();
      final verifyRes = await paymentService.verifyPayment(response);

      if (verifyRes['success'] == true) {
        // Create booking after successful payment verification
        final totalAmount = _calculateFinalAmount();

        final booking = BookingModel(
          id: '',
          userId: currentUser.id,
          carId: widget.carId,
          car: null,
          amount: totalAmount,
          pickUpLocation: widget.pickUpLocation,
          dropOffLocation: widget.dropOffLocation,
          startDate: widget.startDate,
          endDate: widget.endDate,
          bookingStatus: 'active',
          paymentStatus: 'completed',
          paymentId: verifyRes['paymentId'],
          createdAt: DateTime.now(),
          rentalStatus: "",
        );

        final bookingResult = await bookingProvider.createBooking(booking);

        if (bookingResult is Map<String, dynamic> &&
            bookingResult['success'] == true) {
          if (!mounted) return;

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
        } else {
          throw Exception('Booking creation failed');
        }
      } else {
        print(Exception('Payment verification failed'));
        throw Exception('Payment verification failed');
      }
    } catch (e) {
      if (!mounted) return;
      print('Error: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Failed: ${response.message ?? 'Unknown error'}'),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    setState(() {
      _isProcessing = false;
    });
  }

  void _openRazorpayCheckout() async {
    try {
      final userProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = userProvider.user;

      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      final paymentService = PaymentService();
      final orderResponse = await paymentService.createRazorpayOrder(
        amount: _calculateFinalAmount(),
        currency: widget.currency,
      );

      if (orderResponse['success'] != true ||
          orderResponse['orderId'] == null) {
        throw Exception('Failed to create order');
      }

      currentOrderId = orderResponse['orderId'];

      var options = {
        'key': 'rzp_test_S8W9WfUPHAiIA9',
        'amount': (_calculateFinalAmount() * 100).toInt(), // Amount in paise
        'name': 'Car Rent App',
        'description': 'Car Booking Payment',
        'order_id': currentOrderId,
        'currency': 'INR',
        'prefill': {
          'name': currentUser.name,
          'email': currentUser.email,
          'contact': currentUser.phoneNumber ?? '',
        },
        'theme': {'color': '#2E7D57'}
      };

      _razorpay.open(options);
    } catch (e) {
      if (!mounted) return;

      print("error in _openRazorpayCheckout: ${e.toString()}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: CustomAppBar(
        title: 'Complete Payment',
        iconButton: IconButton(
          icon: const Icon(Icons.more_horiz, color: textPrimary),
          onPressed: () {
            _showOptionsMenu(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  // Booking Card
                  BookingCard(
                    booking: booking,
                    car: widget.car,
                  ),

                  const SizedBox(height: 20),

                  // Payment Summary Card
                  _buildPaymentSummary(),

                  const SizedBox(height: 20),

                  // Payment Methods Info
                  _buildPaymentMethodsInfo(),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // Bottom Payment Section
          _buildBottomPaymentSection(),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FA)],
        ),
        borderRadius: BorderRadius.circular(20),
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
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: Color(0xFF4CAF50),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Payment Summary',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSummaryRow(
            'Rental Duration',
            '$_durationInDays ${_durationInDays == 1 ? 'Day' : 'Days'}',
            icon: Icons.calendar_today,
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(
            'Price per day',
            '₹${widget.car.originalPrice.toStringAsFixed(0)}',
            icon: Icons.payments_outlined,
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey.shade300,
                  Colors.grey.shade200,
                  Colors.grey.shade300,
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(
            'Total Amount',
            '₹${_totalAmount.toStringAsFixed(0)}',
            isTotal: true,
            icon: Icons.account_balance_wallet,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isTotal = false,
    IconData? icon,
  }) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: isTotal ? 20 : 16,
            color: isTotal ? const Color(0xFF4CAF50) : const Color(0xFF9CA3AF),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 15,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
              color:
                  isTotal ? const Color(0xFF1A1A1A) : const Color(0xFF6B7280),
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 20 : 15,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal ? const Color(0xFF4CAF50) : const Color(0xFF1A1A1A),
            letterSpacing: isTotal ? -0.5 : 0,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodsInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF0EA5E9).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0EA5E9).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.info_outline,
              color: Color(0xFF0EA5E9),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Pay securely using Cards, UPI, Wallets & Net Banking',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF075985),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPaymentSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Terms and Conditions Checkbox
              GestureDetector(
                onTap: () {
                  setState(() {
                    _agreedToTerms = !_agreedToTerms;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _agreedToTerms
                        ? const Color(0xFF4CAF50).withValues(alpha: 0.05)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _agreedToTerms
                          ? const Color(0xFF4CAF50).withValues(alpha: 0.3)
                          : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _agreedToTerms
                              ? const Color(0xFF4CAF50)
                              : Colors.white,
                          border: Border.all(
                            color: _agreedToTerms
                                ? const Color(0xFF4CAF50)
                                : Colors.grey.shade400,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: _agreedToTerms
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF374151),
                              height: 1.4,
                            ),
                            children: [
                              TextSpan(text: 'I agree to the '),
                              TextSpan(
                                text: 'Terms and Conditions',
                                style: TextStyle(
                                  color: Color(0xFF4CAF50),
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(
                                  color: Color(0xFF4CAF50),
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Razorpay Payment Button
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: (_isProcessing || !_agreedToTerms)
                      ? null
                      : _openRazorpayCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    disabledBackgroundColor: const Color(0xFFE5E7EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.lock_outline,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pay ₹${_totalAmount.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const Text(
                                  'via Razorpay',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 12),

              // Secure Payment Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.verified_user,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '100% Secure Payment • Powered by Razorpay',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text('Help & Support'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to help screen
                },
              ),
              ListTile(
                leading: const Icon(Icons.receipt_long),
                title: const Text('View Booking Details'),
                onTap: () {
                  Navigator.pop(context);
                  // Show booking details
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share'),
                onTap: () {
                  Navigator.pop(context);
                  // Share booking
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
