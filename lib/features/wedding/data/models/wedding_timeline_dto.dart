import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_timeline_entity.dart';

part 'wedding_timeline_dto.freezed.dart';
part 'wedding_timeline_dto.g.dart';

@freezed
class WeddingTimelineTaskDto with _$WeddingTimelineTaskDto {
  const factory WeddingTimelineTaskDto({
    required String id,
    @JsonKey(name: 'wedding_id') required String weddingId,
    required String title,
    String? description,
    required String phase,
    @JsonKey(name: 'due_date') required String dueDate,
    @JsonKey(name: 'completed_date') String? completedDate,
    @JsonKey(name: 'is_completed') @Default(false) bool isCompleted,
    @JsonKey(name: 'vendor_id') String? vendorId,
    @Default(2) int priority,
  }) = _WeddingTimelineTaskDto;

  factory WeddingTimelineTaskDto.fromJson(Map<String, dynamic> json) =>
      _$WeddingTimelineTaskDtoFromJson(json);

  factory WeddingTimelineTaskDto.fromEntity(WeddingTimelineTaskEntity e) =>
      WeddingTimelineTaskDto(
        id: e.id,
        weddingId: e.weddingId,
        title: e.title,
        description: e.description,
        phase: e.phase.name,
        dueDate: e.dueDate.toIso8601String(),
        completedDate: e.completedDate?.toIso8601String(),
        isCompleted: e.isCompleted,
        vendorId: e.vendorId,
        priority: e.priority,
      );
}

extension WeddingTimelineTaskDtoX on WeddingTimelineTaskDto {
  WeddingTimelineTaskEntity toEntity() => WeddingTimelineTaskEntity(
        id: id,
        weddingId: weddingId,
        title: title,
        description: description,
        phase: _parsePhase(phase),
        dueDate: DateTime.parse(dueDate),
        completedDate:
            completedDate != null ? DateTime.parse(completedDate!) : null,
        isCompleted: isCompleted,
        vendorId: vendorId,
        priority: priority,
      );

  TimelinePhase _parsePhase(String p) => switch (p) {
        'booking' => TimelinePhase.booking,
        'confirmed' => TimelinePhase.confirmed,
        'preparation' => TimelinePhase.preparation,
        'day_of' || 'dayOf' => TimelinePhase.dayOf,
        'post_wedding' || 'postWedding' => TimelinePhase.postWedding,
        _ => TimelinePhase.planning,
      };
}

@freezed
class WeddingTimelineDto with _$WeddingTimelineDto {
  const factory WeddingTimelineDto({
    @JsonKey(name: 'wedding_id') required String weddingId,
    @Default([]) List<WeddingTimelineTaskDto> tasks,
  }) = _WeddingTimelineDto;

  factory WeddingTimelineDto.fromJson(Map<String, dynamic> json) =>
      _$WeddingTimelineDtoFromJson(json);

  factory WeddingTimelineDto.fromEntity(WeddingTimelineEntity e) =>
      WeddingTimelineDto(
        weddingId: e.weddingId,
        tasks: e.tasks.map(WeddingTimelineTaskDto.fromEntity).toList(),
      );
}

extension WeddingTimelineDtoX on WeddingTimelineDto {
  WeddingTimelineEntity toEntity() => WeddingTimelineEntity(
        weddingId: weddingId,
        tasks: tasks.map((t) => t.toEntity()).toList(),
      );
}
