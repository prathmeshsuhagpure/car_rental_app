/*
import 'package:car_rent_app/screens/payment/payment_methods.dart';
import 'package:flutter/material.dart';
import '../../models/booking_model.dart';
import '../../models/car_model.dart';
import '../../models/user_model.dart';
import '../../utils/theme.dart';
import '../../widgets/booking_card.dart';
import '../../widgets/custom_app_bar.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    super.key,
    required this.car,
    required this.user,
    required this.startDate,
    required this.endDate,
    required this.pickUpLocation,
    required this.dropOffLocation,
  });

  final Car car;
  final User user;
  final DateTime startDate;
  final DateTime endDate;
  final String pickUpLocation;
  final String dropOffLocation;

  @override
  PaymentScreenState createState() => PaymentScreenState();
}

class PaymentScreenState extends State<PaymentScreen> {
  late BookingModel booking;

  // Calculate total amount based on number of days
  double _calculateTotalAmount() {
    final days = widget.endDate.difference(widget.startDate).inDays;
    return widget.car.originalPrice * (days == 0 ? 1 : days); // Minimum 1 day
  }

  @override
  void initState() {
    super.initState();
    booking = BookingModel(
      id: "",
      carId: widget.car.id,
      userId: widget.user.id,
      startDate: widget.startDate,
      endDate: widget.endDate,
      pickUpLocation: widget.pickUpLocation,
      dropOffLocation: widget.dropOffLocation,
      amount: _calculateTotalAmount(),
      paymentId: '',
      paymentStatus: 'pending',
      bookingStatus: 'pending',
      createdAt: DateTime.now(),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = widget.car.originalPrice * booking.durationInDays;
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        title: 'Complete Payment',
        iconButton: IconButton(
          icon: const Icon(Icons.more_horiz, color: textPrimary),
          onPressed: () {},
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            BookingCard(
              car: widget.car,
              booking: booking,
              onCancel: (booking) async {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Cancelled booking ${booking.id}'),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 1),
                  ),
                );
                Navigator.pop(context);
              },
              onPay: (booking) async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentMethodsScreen(
                      amount: totalAmount,
                      // Use booking.amount instead of booking.totalAmount
                      currency: 'INR',
                      carId: widget.car.id,
                      startDate: booking.startDate,
                      endDate: booking.endDate,
                      pickUpLocation: widget.pickUpLocation.isNotEmpty
                          ? widget.pickUpLocation
                          : "Default Pickup Location",
                      dropOffLocation: widget.dropOffLocation.isNotEmpty
                          ? widget.dropOffLocation
                          : "Default Drop off Location",
                      carName: widget.car.name,
                      // Use widget.car.name instead of booking.carName
                      rating: widget.car.rating,
                    ),
                  ),
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Redirecting to payment methods'),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
*/
import 'package:flutter/material.dart';
import 'package:car_rent_app/screens/payment/payment_methods.dart';
import '../../models/booking_model.dart';
import '../../models/car_model.dart';
import '../../models/user_model.dart';
import '../../utils/theme.dart';
import '../../widgets/booking_card.dart';
import '../../widgets/custom_app_bar.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    super.key,
    required this.car,
    required this.user,
    required this.startDate,
    required this.endDate,
    required this.pickUpLocation,
    required this.dropOffLocation,
  });

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
      id: '', // backend will replace
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
      createdAt: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        title: 'Complete Payment',
        iconButton: IconButton(
          icon: const Icon(Icons.more_horiz, color: textPrimary),
          onPressed: () {},
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            BookingCard(
              booking: booking,
              car: widget.car,
              onCancel: (_) async {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Booking cancelled'),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 1),
                  ),
                );
                Navigator.pop(context);
              },
              onPay: (_) async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PaymentMethodsScreen(
                      amount: _totalAmount,
                      currency: 'INR',
                      carId: booking.carId,
                      startDate: booking.startDate,
                      endDate: booking.endDate,
                      pickUpLocation: booking.pickUpLocation.isNotEmpty
                          ? booking.pickUpLocation
                          : 'Default Pickup Location',
                      dropOffLocation: booking.dropOffLocation.isNotEmpty
                          ? booking.dropOffLocation
                          : 'Default Drop-off Location',
                      carName: widget.car.name,
                      rating: widget.car.rating,
                    ),
                  ),
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Redirecting to payment methods'),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
