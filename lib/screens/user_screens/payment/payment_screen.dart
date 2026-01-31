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
    this.booking,
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
  final BookingModel? booking;

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
    final diff = widget.endDate.difference(widget.startDate);
    return (diff.inHours / 24).ceil().clamp(1, 365) + 1;
  }

  double get rentalAmount {
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
      amount: (_calculateFinalAmount()).toDouble(),
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
    return rentalAmount * 0.18; // 18% GST
  }

  double _calculatePlatformFee() {
    return 99.0; // Fixed platform fee
  }

  double _securityDeposit() {
    return 5000.0;
  }

  double _calculateFinalAmount() {
    return rentalAmount +
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

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const UserHomeScreen()),
                (route) => false,
          );
        } else {
          throw Exception('Booking creation failed');
        }
      } else {
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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: Color(0xFF1A1A1A),
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Complete Payment',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.help_outline_rounded,
                size: 20,
                color: Colors.grey.shade700,
              ),
            ),
            onPressed: () => _showHelpDialog(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.blue.shade100,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.verified_user_rounded,
                            color: Colors.blue.shade700,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Secure Payment',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Your payment information is encrypted and secure',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  BookingCard(
                    booking: booking,
                    car: widget.car,
                    showPaymentSummary: true,
                  ),
                ],
              ),
            ),
          ),
          _buildBottomPaymentSection(),
        ],
      ),
    );
  }

  Widget _buildBottomPaymentSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
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
                    borderRadius: BorderRadius.circular(14),
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
                          Icons.check_rounded,
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
                              fontSize: 13,
                              color: Color(0xFF374151),
                              height: 1.5,
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
                          Icons.lock_outline_rounded,
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
                            'Pay ₹${_calculateFinalAmount().toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const Text(
                            'Secure Payment via Razorpay',
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '100% Secure Payment • SSL Encrypted',
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

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.help_outline_rounded,
                color: const Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Payment Help',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelpItem(
              'How is the total calculated?',
              'Rental amount + GST (18%) + Platform fee + Refundable security deposit',
            ),
            const SizedBox(height: 16),
            _buildHelpItem(
              'When will I get my deposit back?',
              'The security deposit will be refunded within 7 days after you return the car in good condition.',
            ),
            const SizedBox(height: 16),
            _buildHelpItem(
              'Is my payment secure?',
              'Yes, all payments are processed through Razorpay with bank-level encryption.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Got it',
              style: TextStyle(
                color: Color(0xFF4CAF50),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String question, String answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          answer,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}