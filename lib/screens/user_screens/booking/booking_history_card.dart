import 'package:flutter/material.dart';
import '../../../models/booking_model.dart';

class BookingHistoryCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback? onTap;
  final VoidCallback? onCancelBooking;
  final VoidCallback? onPayNow;

  const BookingHistoryCard({
    super.key,
    required this.booking,
    this.onTap,
    this.onCancelBooking,
    this.onPayNow,
  });

  @override
  Widget build(BuildContext context) {
    final car = booking.car;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Booking Id #${booking.id.substring(0, 6).toUpperCase()}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildStatusChip(),
                ],
              ),

              const SizedBox(height: 12),

              // CAR INFO
              Row(
                children: [
                  Container(
                    width: 80,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: car != null && car.images.isNotEmpty
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        car.images.first,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                        const Icon(Icons.directions_car),
                      ),
                    )
                        : const Icon(Icons.directions_car),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${car?.brand} ${car?.model}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (car != null)
                          Text(
                            '${car.transmission} • ${car.fuelType} • ${car.seats} seats',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${booking.amount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        '${booking.durationInDays} day(s)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // LOCATIONS
              _buildLocationRow(
                icon: Icons.location_on,
                color: Colors.green,
                label: 'Pickup',
                value: booking.pickUpLocation,
              ),
              const SizedBox(height: 8),
              _buildLocationRow(
                icon: Icons.location_on,
                color: Colors.red,
                label: 'Drop-off',
                value: booking.dropOffLocation,
              ),

              const SizedBox(height: 16),

              // DATES
              Row(
                children: [
                  _buildDateColumn('Start Date', booking.formattedStartDate),
                  _buildDateColumn('End Date', booking.formattedEndDate),
                ],
              ),

              const SizedBox(height: 12),

              // PAYMENT + ACTIONS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildPaymentStatusChip(),
                  _buildActionButtons(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- UI HELPERS ----------

  Widget _buildLocationRow({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 12, color: Colors.grey)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateColumn(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    if (booking.isActive) return _chip('Active', Colors.blue);
    if (booking.isCompleted) return _chip('Status: Completed', Colors.green);
    if (booking.isCancelled) return _chip('Cancelled', Colors.red);
    return _chip('Pending', Colors.orange);
  }

  Widget _buildPaymentStatusChip() {
    if (booking.isPaid) return _chip('Paid', Colors.green);
    if (booking.isPaymentFailed) return _chip('Failed', Colors.red);
    return _chip('Payment Pending', Colors.orange);
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final buttons = <Widget>[];

    if (booking.isPending && onCancelBooking != null) {
      buttons.add(
        TextButton(
          onPressed: onCancelBooking,
          child: const Text('Cancel',
              style: TextStyle(fontSize: 12)),
        ),
      );
    }

    if (booking.isPaymentPending && onPayNow != null) {
      buttons.add(
        ElevatedButton(
          onPressed: onPayNow,
          child: const Text('Pay Now',
              style: TextStyle(fontSize: 12)),
        ),
      );
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    return Row(children: buttons);
  }
}
