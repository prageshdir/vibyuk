import 'package:vibyuk/features/creator/domain/entities/availability_entity.dart';

class AvailabilityModel {
  const AvailabilityModel({
    required this.creatorId,
    this.calendarEntries = const [],
    this.defaultWeeklySlots = const [],
    this.blockedDates = const [],
  });

  final String creatorId;
  final List<CalendarEntryModel> calendarEntries;
  final List<TimeSlotModel> defaultWeeklySlots;
  final List<String> blockedDates;

  factory AvailabilityModel.fromJson(Map<String, dynamic> json) =>
      AvailabilityModel(
        creatorId: json['creator_id'] as String,
        calendarEntries: (json['calendar'] as List?)
                ?.map((e) =>
                    CalendarEntryModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        defaultWeeklySlots: (json['weekly_slots'] as List?)
                ?.map((e) =>
                    TimeSlotModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        blockedDates: (json['blocked_dates'] as List?)?.cast<String>() ?? [],
      );

  AvailabilityEntity toEntity() {
    final Map<DateTime, DayAvailability> cal = {};
    for (final entry in calendarEntries) {
      cal[entry.date] = entry.status;
    }
    return AvailabilityEntity(
      creatorId: creatorId,
      calendar: cal,
      defaultWeeklySlots:
          defaultWeeklySlots.map((e) => e.toEntity()).toList(),
      blockedDates:
          blockedDates.map((d) => DateTime.parse(d)).toList(),
    );
  }
}

class CalendarEntryModel {
  const CalendarEntryModel({required this.date, required this.statusStr});

  final DateTime date;
  final String statusStr;

  DayAvailability get status => DayAvailability.values.firstWhere(
        (e) => e.name == statusStr,
        orElse: () => DayAvailability.available,
      );

  factory CalendarEntryModel.fromJson(Map<String, dynamic> json) =>
      CalendarEntryModel(
        date: DateTime.parse(json['date'] as String),
        statusStr: json['status'] as String? ?? 'available',
      );
}

class TimeSlotModel {
  const TimeSlotModel({
    required this.weekday,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
  });

  final int weekday;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;

  factory TimeSlotModel.fromJson(Map<String, dynamic> json) => TimeSlotModel(
        weekday: json['weekday'] as int,
        startHour: json['start_hour'] as int,
        startMinute: json['start_minute'] as int? ?? 0,
        endHour: json['end_hour'] as int,
        endMinute: json['end_minute'] as int? ?? 0,
      );

  TimeSlotEntity toEntity() => TimeSlotEntity(
        weekday: weekday,
        startHour: startHour,
        startMinute: startMinute,
        endHour: endHour,
        endMinute: endMinute,
      );
}
