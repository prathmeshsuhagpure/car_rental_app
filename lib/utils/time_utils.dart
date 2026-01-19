import 'dart:async';
import 'package:flutter/material.dart';

class TimeUtils {
  // Helper method to add hours to TimeOfDay
  static TimeOfDay addHoursToTimeOfDay(TimeOfDay time, int hours) {
    final now = DateTime.now();
    final dateTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final newDateTime = dateTime.add(Duration(hours: hours));
    return TimeOfDay(hour: newDateTime.hour, minute: newDateTime.minute);
  }

  // Helper method to get month name
  static String getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  // Format date for display
  static String formatDate(DateTime date) {
    return "${getMonthName(date.month)} ${date.day}, ${date.year}";
  }

  // Format time for display
  static String formatTime(TimeOfDay time, BuildContext context) {
    return time.format(context);
  }
}

class TimerHelper {
  Timer? _timer;
  int _remainingMinutes;
  int _remainingSeconds;
  final VoidCallback onTimeUp;
  final VoidCallback onTick;

  TimerHelper({
    required int initialMinutes,
    required int initialSeconds,
    required this.onTimeUp,
    required this.onTick,
  })  : _remainingMinutes = initialMinutes,
        _remainingSeconds = initialSeconds;

  int get remainingMinutes => _remainingMinutes;
  int get remainingSeconds => _remainingSeconds;

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
      } else if (_remainingMinutes > 0) {
        _remainingMinutes--;
        _remainingSeconds = 59;
      } else {
        timer.cancel();
        onTimeUp();
        return;
      }
      onTick();
    });
  }

  void dispose() {
    _timer?.cancel();
  }
}