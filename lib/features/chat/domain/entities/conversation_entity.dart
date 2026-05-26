import 'package:equatable/equatable.dart';

enum ConversationParticipantRole { business, creator }

class ConversationEntity extends Equatable {
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

  const ConversationEntity({
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

  bool get hasUnread => unreadCount > 0;

  @override
  List<Object?> get props => [
        id, otherUserId, otherUserName, otherUserAvatarUrl, otherUserRole,
        lastMessage, lastMessageAt, unreadCount, isOnline, bookingId,
        campaignId, createdAt,
      ];
}
