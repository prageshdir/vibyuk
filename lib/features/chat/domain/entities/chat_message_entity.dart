import 'package:equatable/equatable.dart';

enum MessageType { text, image, file, audio, booking, system }
enum MessageStatus { sending, sent, delivered, read, failed }

class ChatMessageEntity extends Equatable {
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
  final int? durationSeconds;
  final String? bookingId;
  final MessageStatus status;
  final bool isMe;
  final DateTime createdAt;
  final DateTime? editedAt;

  const ChatMessageEntity({
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
    this.durationSeconds,
    this.bookingId,
    required this.status,
    required this.isMe,
    required this.createdAt,
    this.editedAt,
  });

  @override
  List<Object?> get props => [
        id, conversationId, senderId, senderName, senderAvatarUrl, type,
        text, mediaUrl, fileName, fileSize, durationSeconds, bookingId, status, isMe,
        createdAt, editedAt,
      ];
}
