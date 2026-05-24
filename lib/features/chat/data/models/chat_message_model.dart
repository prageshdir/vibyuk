import 'package:vibyuk/features/chat/domain/entities/chat_message_entity.dart';

class ChatMessageModel {
  const ChatMessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    this.senderAvatarUrl,
    required this.type,
    this.text,
    this.mediaUrl,
    this.fileName,
    this.fileSize,
    this.bookingId,
    required this.status,
    required this.isMe,
    required this.createdAt,
    this.editedAt,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String? senderAvatarUrl;
  final MessageType type;
  final String? text;
  final String? mediaUrl;
  final String? fileName;
  final int? fileSize;
  final String? bookingId;
  final MessageStatus status;
  final bool isMe;
  final DateTime createdAt;
  final DateTime? editedAt;

  factory ChatMessageModel.fromJson(Map<String, dynamic> j) =>
      ChatMessageModel(
        id: j['id'] as String,
        conversationId: j['conversation_id'] as String,
        senderId: j['sender_id'] as String,
        senderName: j['sender_name'] as String,
        senderAvatarUrl: j['sender_avatar_url'] as String?,
        type: MessageType.values.firstWhere(
          (t) => t.name == j['type'],
          orElse: () => MessageType.text,
        ),
        text: j['text'] as String?,
        mediaUrl: j['media_url'] as String?,
        fileName: j['file_name'] as String?,
        fileSize: j['file_size'] as int?,
        bookingId: j['booking_id'] as String?,
        status: MessageStatus.values.firstWhere(
          (s) => s.name == j['status'],
          orElse: () => MessageStatus.sent,
        ),
        isMe: j['is_me'] as bool? ?? false,
        createdAt: DateTime.parse(j['created_at'] as String),
        editedAt: j['edited_at'] != null
            ? DateTime.parse(j['edited_at'] as String)
            : null,
      );

  ChatMessageEntity toEntity() => ChatMessageEntity(
        id: id,
        conversationId: conversationId,
        senderId: senderId,
        senderName: senderName,
        senderAvatarUrl: senderAvatarUrl,
        type: type,
        text: text,
        mediaUrl: mediaUrl,
        fileName: fileName,
        fileSize: fileSize,
        bookingId: bookingId,
        status: status,
        isMe: isMe,
        createdAt: createdAt,
        editedAt: editedAt,
      );
}
