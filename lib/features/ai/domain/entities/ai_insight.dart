import 'package:equatable/equatable.dart';

enum InsightType { opportunity, warning, achievement, trend, recommendation }
enum InsightPriority { low, medium, high, critical }

class AiInsight extends Equatable {
  final String id;
  final InsightType type;
  final InsightPriority priority;
  final String title;
  final String description;
  final String? actionLabel;
  final String? actionRoute;
  final Map<String, dynamic>? metadata;
  final double? impactScore;
  final bool isDismissed;
  final DateTime createdAt;
  final DateTime? expiresAt;

  const AiInsight({
    required this.id,
    required this.type,
    required this.priority,
    required this.title,
    required this.description,
    this.actionLabel,
    this.actionRoute,
    this.metadata,
    this.impactScore,
    this.isDismissed = false,
    required this.createdAt,
    this.expiresAt,
  });

  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);

  AiInsight copyWith({
    String? id,
    InsightType? type,
    InsightPriority? priority,
    String? title,
    String? description,
    String? actionLabel,
    String? actionRoute,
    Map<String, dynamic>? metadata,
    double? impactScore,
    bool? isDismissed,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return AiInsight(
      id: id ?? this.id,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      title: title ?? this.title,
      description: description ?? this.description,
      actionLabel: actionLabel ?? this.actionLabel,
      actionRoute: actionRoute ?? this.actionRoute,
      metadata: metadata ?? this.metadata,
      impactScore: impactScore ?? this.impactScore,
      isDismissed: isDismissed ?? this.isDismissed,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        priority,
        title,
        description,
        actionLabel,
        actionRoute,
        metadata,
        impactScore,
        isDismissed,
        createdAt,
        expiresAt,
      ];
}
