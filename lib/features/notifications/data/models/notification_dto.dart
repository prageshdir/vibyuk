import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vibyuk/core/notifications/models/push_notification_model.dart';
import 'package:vibyuk/features/notifications/domain/entities/notification_entity.dart';

part 'notification_dto.freezed.dart';
part 'notification_dto.g.dart';

@freezed
class NotificationDto with _$NotificationDto {
  const NotificationDto._();

  const factory NotificationDto({
    required String id,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'deep_link') String? deepLink,
    @JsonKey(name: 'received_at') required DateTime receivedAt,
    @JsonKey(name: 'is_read') @Default(false) bool isRead,
    @JsonKey(name: 'group_key') String? groupKey,
  }) = _NotificationDto;

  factory NotificationDto.fromJson(Map<String, dynamic> json) =>
      _$NotificationDtoFromJson(json);

  NotificationEntity toEntity() => NotificationEntity(
        id: id,
        title: title,
        body: body,
        type: NotificationType.values.firstWhere(
          (t) => t.name == type,
          orElse: () => NotificationType.general,
        ),
        data: data,
        imageUrl: imageUrl,
        deepLink: deepLink,
        receivedAt: receivedAt,
        isRead: isRead,
        groupKey: groupKey,
      );

  static NotificationDto fromEntity(NotificationEntity entity) =>
      NotificationDto(
        id: entity.id,
        title: entity.title,
        body: entity.body,
        type: entity.type.name,
        data: entity.data,
        imageUrl: entity.imageUrl,
        deepLink: entity.deepLink,
        receivedAt: entity.receivedAt,
        isRead: entity.isRead,
        groupKey: entity.groupKey,
      );
}
