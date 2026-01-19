import 'package:flutter/material.dart';
import '../utils/time_utils.dart';

class TripDateSelect extends StatelessWidget {
  final String title;
  final DateTime date;
  final TimeOfDay time;
  final VoidCallback onTap;

  const TripDateSelect({super.key,
    required this.title,
    required this.date,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[50],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "${TimeUtils.getMonthName(date.month)} ${date.day}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              time.format(context),
              style: const TextStyle(
                color: Color(0xFF0A5525),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}