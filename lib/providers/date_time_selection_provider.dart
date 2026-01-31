import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DateTimeSelectionProvider extends ChangeNotifier {
  static final DateTimeSelectionProvider _instance =
  DateTimeSelectionProvider._internal();
  factory DateTimeSelectionProvider() => _instance;
  DateTimeSelectionProvider._internal() {
    final now = DateTime.now();

    _tripStartDate = now;
    _tripStartTime = TimeOfDay.fromDateTime(now);

    final end = now.add(minimumTripDuration);
    _tripEndDate = end;
    _tripEndTime = TimeOfDay.fromDateTime(end);
  }

  static const Duration minimumTripDuration = Duration(hours: 24);

  late DateTime _tripStartDate;
  late TimeOfDay _tripStartTime;
  late DateTime _tripEndDate;
  late TimeOfDay _tripEndTime;

  DateTime get tripStartDate => _tripStartDate;
  TimeOfDay get tripStartTime => _tripStartTime;
  DateTime get tripEndDate => _tripEndDate;
  TimeOfDay get tripEndTime => _tripEndTime;

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

  bool get isValidDateRange =>
      endDateTime.isAfter(startDateTime.add(minimumTripDuration));

  void updateStartDateTime(DateTime date, TimeOfDay time) {
    _tripStartDate = date;
    _tripStartTime = time;

    final newStart = startDateTime;

    // Auto-fix end if it violates minimum duration
    if (endDateTime.isBefore(newStart.add(minimumTripDuration))) {
      final adjustedEnd = newStart.add(minimumTripDuration);
      _tripEndDate = adjustedEnd;
      _tripEndTime = TimeOfDay.fromDateTime(adjustedEnd);
    }

    notifyListeners();
  }

  void updateEndDateTime(DateTime date, TimeOfDay time) {
    final newEnd = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    if (newEnd.isBefore(startDateTime.add(minimumTripDuration))) {
      return;
    }

    _tripEndDate = date;
    _tripEndTime = time;
    notifyListeners();
  }

  Future<DateTime?> showCustomDatePicker(
      BuildContext context, {
        required DateTime initialDate,
        DateTime? firstDate,
        DateTime? lastDate,
      }) async {
    return showDatePicker(
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

  Future<TimeOfDay?> showCustomTimePicker(
      BuildContext context, {
        required TimeOfDay initialTime,
      }) async {
    return showTimePicker(
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

  Future<bool> selectStartDateTime(BuildContext context) async {
    final pickedDate = await showCustomDatePicker(
      context,
      initialDate: _tripStartDate,
    );

    if (pickedDate == null) return false;

    final pickedTime = await showCustomTimePicker(
      context,
      initialTime: _tripStartTime,
    );

    if (pickedTime == null) return false;

    updateStartDateTime(pickedDate, pickedTime);
    HapticFeedback.lightImpact();
    return true;
  }

  Future<bool> selectEndDateTime(BuildContext context) async {
    final pickedDate = await showCustomDatePicker(
      context,
      initialDate: _tripEndDate,
      firstDate: _tripStartDate,
    );

    if (pickedDate == null) return false;

    final pickedTime = await showCustomTimePicker(
      context,
      initialTime: _tripEndTime,
    );

    if (pickedTime == null) return false;

    final newEnd = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    if (newEnd.isBefore(startDateTime.add(minimumTripDuration))) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Trip must be at least 24 hours long.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }

    updateEndDateTime(pickedDate, pickedTime);
    HapticFeedback.lightImpact();
    return true;
  }

  String formatDateTime(DateTime date, TimeOfDay time) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year} at "
        "${time.hour.toString().padLeft(2, '0')}:"
        "${time.minute.toString().padLeft(2, '0')}";
  }

  String get formattedStartDateTime =>
      formatDateTime(_tripStartDate, _tripStartTime);

  String get formattedEndDateTime =>
      formatDateTime(_tripEndDate, _tripEndTime);
}

