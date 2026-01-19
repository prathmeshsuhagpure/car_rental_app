import 'package:car_rent_app/utils/time_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DateTimeSelectionService extends ChangeNotifier {
  // Singleton pattern - uncommented and fixed
  static final DateTimeSelectionService _instance = DateTimeSelectionService._internal();
  factory DateTimeSelectionService() => _instance;
  DateTimeSelectionService._internal() :
        _tripStartDate = DateTime.now(),
        _tripStartTime = TimeOfDay.now(),
        _tripEndDate = DateTime.now().add(const Duration(days: 1)),
        _tripEndTime = TimeOfDay.now();

  DateTime _tripStartDate;
  TimeOfDay _tripStartTime;
  DateTime _tripEndDate;
  TimeOfDay _tripEndTime;

  // Alternative constructor for testing or specific initialization
  DateTimeSelectionService.withInitialValues({
    DateTime? initialStartDate,
    TimeOfDay? initialStartTime,
    DateTime? initialEndDate,
    TimeOfDay? initialEndTime,
  }) : _tripStartDate = initialStartDate ?? DateTime.now(),
        _tripStartTime = initialStartTime ?? TimeOfDay.now(),
        _tripEndDate = initialEndDate ?? DateTime.now().add(const Duration(days: 1)),
        _tripEndTime = initialEndTime ?? TimeOfDay.now();

  // Getters
  DateTime get tripStartDate => _tripStartDate;
  DateTime get tripEndDate => _tripEndDate;
  TimeOfDay get tripStartTime => _tripStartTime;
  TimeOfDay get tripEndTime => _tripEndTime;

  // Add public setters if needed
  set tripStartDate(DateTime date) {
    _tripStartDate = date;
    notifyListeners();
  }

  set tripStartTime(TimeOfDay time) {
    _tripStartTime = time;
    notifyListeners();
  }

  set tripEndDate(DateTime date) {
    _tripEndDate = date;
    notifyListeners();
  }

  set tripEndTime(TimeOfDay time) {
    _tripEndTime = time;
    notifyListeners();
  }

  // Get combined DateTime objects
  DateTime get startDateTime => DateTime(
    _tripStartDate.year,
    _tripStartDate.month,
    _tripStartDate.day,
    _tripStartTime.hour,
    _tripStartTime.minute,
  );

  DateTime get endDateTime => DateTime(
    _tripEndDate.year,
    _tripEndDate.month,
    _tripEndDate.day,
    _tripEndTime.hour,
    _tripEndTime.minute,
  );

  // Check if dates are valid
  bool get isValidDateRange => endDateTime.isAfter(startDateTime);

  // Get duration of the trip
  String get durationFormatted {
    Duration tripDuration = endDateTime.difference(startDateTime);
    final totalMinutes = tripDuration.inMinutes;
    final days = totalMinutes ~/ (24 * 60);
    final hours = (totalMinutes % (24 * 60)) ~/ 60;
    //final minutes = totalMinutes % 60;

    final parts = <String>[];
    if (days > 0) parts.add('$days day${days > 1 ? 's' : ''}');
    if (hours > 0) parts.add('$hours hour${hours > 1 ? 's' : ''}');
    //if (minutes > 0) parts.add('$minutes minute${minutes > 1 ? 's' : ''}');

    return parts.isNotEmpty ? parts.join(' and ') : '0 minutes';
  }

  // Update start date and time
  void updateStartDateTime(DateTime date, TimeOfDay time) {
    _tripStartDate = date;
    _tripStartTime = time;

    // Auto-adjust end date if it becomes invalid
    final newStartDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    if (!newStartDateTime.isBefore(endDateTime)) {
      final adjustedEndDateTime = newStartDateTime.add(const Duration(hours: 4));
      _tripEndDate = adjustedEndDateTime;
      _tripEndTime = TimeOfDay.fromDateTime(adjustedEndDateTime);
    }

    notifyListeners();
  }

  // Update end date and time
  void updateEndDateTime(DateTime date, TimeOfDay time) {
    final newEndDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    if (newEndDateTime.isAfter(startDateTime)) {
      _tripEndDate = date;
      _tripEndTime = time;
      notifyListeners();
    }
  }

  // Reset to default values
  void reset() {
    _tripStartDate = DateTime.now();
    _tripEndDate = DateTime.now().add(const Duration(hours: 4));
    _tripStartTime = TimeOfDay.now();
    _tripEndTime = TimeUtils.addHoursToTimeOfDay(TimeOfDay.now(), 4);
    notifyListeners();
  }

  // Show date picker with custom theme
  Future<DateTime?> showCustomDatePicker(BuildContext context, {
    required DateTime initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    return await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate ?? DateTime.now(),
      lastDate: lastDate ?? DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF059669),
              onPrimary: Colors.white,
              surface: Color(0xFF1E293B),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
  }

  // Show time picker with custom theme
  Future<TimeOfDay?> showCustomTimePicker(BuildContext context, {
    required TimeOfDay initialTime,
  }) async {
    return await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF059669),
              onPrimary: Colors.white,
              surface: Color(0xFF1E293B),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
  }

  // Combined date and time selection for start
  Future<bool> selectStartDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showCustomDatePicker(
      context,
      initialDate: _tripStartDate,
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showCustomTimePicker(
        context,
        initialTime: _tripStartTime,
      );

      if (pickedTime != null) {
        updateStartDateTime(pickedDate, pickedTime);
        HapticFeedback.lightImpact();
        return true;
      }
    }
    return false;
  }

  // Combined date and time selection for end
  Future<bool> selectEndDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showCustomDatePicker(
      context,
      initialDate: _tripEndDate,
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showCustomTimePicker(
        context,
        initialTime: _tripEndTime,
      );

      if (pickedTime != null) {
        final newEndDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        if (newEndDateTime.isAfter(startDateTime)) {
          updateEndDateTimeFromCombined(newEndDateTime);
          HapticFeedback.lightImpact();
          return true;
        } else {
          // Show error - end time must be after start time
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Trip end must be after trip start.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return false;
        }
      }
    }
    return false;
  }

  void updateEndDateTimeFromCombined(DateTime newEndDateTime) {
    _tripEndDate = newEndDateTime;
    _tripEndTime = TimeOfDay.fromDateTime(newEndDateTime);
    notifyListeners();
  }


  // Utility method to format date and time for display
  String formatDateTime(DateTime date, TimeOfDay time) {
    try {
      final String formattedDate = "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
      final String formattedTime = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
      return "$formattedDate at $formattedTime";
    } catch (e) {
      print('Error formatting date time: $e');
      return 'Invalid Date';
    }
  }

  // Get formatted start date time
  String get formattedStartDateTime => formatDateTime(_tripStartDate, _tripStartTime);

  // Get formatted end date time
  String get formattedEndDateTime => formatDateTime(_tripEndDate, _tripEndTime);
}

// Fixed extension - now returns the singleton instance
extension DateTimeServiceExtension on BuildContext {
  DateTimeSelectionService get dateTimeService => DateTimeSelectionService();
}