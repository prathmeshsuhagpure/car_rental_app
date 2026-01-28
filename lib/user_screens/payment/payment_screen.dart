import 'package:car_rent_app/user_screens/payment/payment_methods.dart';
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
      rentalStatus: "",
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
