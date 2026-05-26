import 'package:vibyuk/features/chat/domain/entities/conversation_entity.dart';

class ConversationModel {
  const ConversationModel({
    required this.id,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatarUrl,
    required this.otherUserRole,
    this.lastMessage,
    this.lastMessageAt,
    required this.unreadCount,
    required this.isOnline,
    this.bookingId,
    this.campaignId,
    required this.createdAt,
  });

  final String id;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserAvatarUrl;
  final ConversationParticipantRole otherUserRole;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final bool isOnline;
  final String? bookingId;
  final String? campaignId;
  final DateTime createdAt;

  factory ConversationModel.fromJson(Map<String, dynamic> j) =>
      ConversationModel(
        id: j['id'] as String,
        otherUserId: j['other_user_id'] as String,
        otherUserName: j['other_user_name'] as String,
        otherUserAvatarUrl: j['other_user_avatar_url'] as String?,
        otherUserRole: ConversationParticipantRole.values.firstWhere(
          (r) => r.name == j['other_user_role'],
          orElse: () => ConversationParticipantRole.creator,
        ),
        lastMessage: j['last_message'] as String?,
        lastMessageAt: j['last_message_at'] != null
            ? DateTime.parse(j['last_message_at'] as String)
            : null,
        unreadCount: j['unread_count'] as int? ?? 0,
        isOnline: j['is_online'] as bool? ?? false,
        bookingId: j['booking_id'] as String?,
        campaignId: j['campaign_id'] as String?,
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  ConversationEntity toEntity() => ConversationEntity(
        id: id,
        otherUserId: otherUserId,
        otherUserName: otherUserName,
        otherUserAvatarUrl: otherUserAvatarUrl,
        otherUserRole: otherUserRole,
        lastMessage: lastMessage,
        lastMessageAt: lastMessageAt,
        unreadCount: unreadCount,
        isOnline: isOnline,
        bookingId: bookingId,
        campaignId: campaignId,
        createdAt: createdAt,
      );
}
