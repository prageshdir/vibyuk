import 'package:equatable/equatable.dart';

enum DisputeStatus { open, inReview, resolvedBuyer, resolvedSeller, closed, escalated }
enum DisputeType { payment, noShow, qualityIssue, cancellation, misconduct, fraud }
enum DisputeResolution { favorBuyer, favorSeller, splitRefund, closeNoAction }

class DisputeParty extends Equatable {
  final String userId;
  final String fullName;
  final String? avatarUrl;
  final String role;

  const DisputeParty({
    required this.userId,
    required this.fullName,
    this.avatarUrl,
    required this.role,
  });

  @override
  List<Object?> get props => [userId, fullName, avatarUrl, role];
}

class DisputeEvidenceItem extends Equatable {
  final String id;
  final String type;
  final String url;
  final String description;
  final String submittedByUserId;
  final DateTime submittedAt;

  const DisputeEvidenceItem({
    required this.id,
    required this.type,
    required this.url,
    required this.description,
    required this.submittedByUserId,
    required this.submittedAt,
  });

  @override
  List<Object?> get props => [id, type, url, description, submittedByUserId, submittedAt];
}

class DisputeMessage extends Equatable {
  final String id;
  final String senderId;
  final String senderName;
  final bool isAdmin;
  final String content;
  final DateTime sentAt;

  const DisputeMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.isAdmin,
    required this.content,
    required this.sentAt,
  });

  @override
  List<Object?> get props => [id, senderId, senderName, isAdmin, content, sentAt];
}

class AdminDispute extends Equatable {
  final String id;
  final String bookingId;
  final DisputeType type;
  final DisputeStatus status;
  final String title;
  final String description;
  final DisputeParty buyer;
  final DisputeParty seller;
  final double bookingAmount;
  final double? refundAmount;
  final String currency;
  final String? assignedModeratorId;
  final String? assignedModeratorName;
  final List<DisputeEvidenceItem> evidence;
  final List<DisputeMessage> messages;
  final DisputeResolution? resolution;
  final String? resolutionNote;
  final int priority;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;

  const AdminDispute({
    required this.id,
    required this.bookingId,
    required this.type,
    required this.status,
    required this.title,
    required this.description,
    required this.buyer,
    required this.seller,
    required this.bookingAmount,
    this.refundAmount,
    this.currency = 'INR',
    this.assignedModeratorId,
    this.assignedModeratorName,
    required this.evidence,
    required this.messages,
    this.resolution,
    this.resolutionNote,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
    this.resolvedAt,
  });

  bool get isOpen => status == DisputeStatus.open;
  bool get isInReview => status == DisputeStatus.inReview;
  bool get isResolved =>
      status == DisputeStatus.resolvedBuyer ||
      status == DisputeStatus.resolvedSeller ||
      status == DisputeStatus.closed;
  bool get isHighPriority => priority >= 3;
  int get daysSinceOpened => DateTime.now().difference(createdAt).inDays;

  AdminDispute copyWith({
    DisputeStatus? status,
    String? assignedModeratorId,
    String? assignedModeratorName,
    DisputeResolution? resolution,
    String? resolutionNote,
    double? refundAmount,
    List<DisputeMessage>? messages,
    DateTime? resolvedAt,
  }) {
    return AdminDispute(
      id: id, bookingId: bookingId, type: type,
      status: status ?? this.status, title: title, description: description,
      buyer: buyer, seller: seller, bookingAmount: bookingAmount,
      refundAmount: refundAmount ?? this.refundAmount, currency: currency,
      assignedModeratorId: assignedModeratorId ?? this.assignedModeratorId,
      assignedModeratorName: assignedModeratorName ?? this.assignedModeratorName,
      evidence: evidence,
      messages: messages ?? this.messages,
      resolution: resolution ?? this.resolution,
      resolutionNote: resolutionNote ?? this.resolutionNote,
      priority: priority, createdAt: createdAt,
      updatedAt: DateTime.now(), resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  @override
  List<Object?> get props => [
        id, bookingId, type, status, title, description, buyer, seller,
        bookingAmount, refundAmount, currency, assignedModeratorId,
        assignedModeratorName, evidence, messages, resolution, resolutionNote,
        priority, createdAt, updatedAt, resolvedAt,
      ];
}
