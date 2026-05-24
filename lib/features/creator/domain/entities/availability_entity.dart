import 'package:equatable/equatable.dart';

enum DayAvailability { available, busy, unavailable }

class AvailabilityEntity extends Equatable {
  final String creatorId;
  final Map<DateTime, DayAvailability> calendar;
  final List<TimeSlotEntity> defaultWeeklySlots;
  final List<DateTime> blockedDates;

  const AvailabilityEntity({
    required this.creatorId,
    required this.calendar,
    required this.defaultWeeklySlots,
    required this.blockedDates,
  });

  DayAvailability statusFor(DateTime date) {
    final key = DateTime(date.year, date.month, date.day);
    return calendar[key] ?? DayAvailability.available;
  }

  @override
  List<Object?> get props => [creatorId, calendar, defaultWeeklySlots, blockedDates];
}

class TimeSlotEntity extends Equatable {
  final int weekday; // 1=Monday … 7=Sunday
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;

  const TimeSlotEntity({
    required this.weekday,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
  });

  String get displayStart =>
      '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';

  String get displayEnd =>
      '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';

  @override
  List<Object?> get props => [weekday, startHour, startMinute, endHour, endMinute];
}
