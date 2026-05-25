import 'package:vibyuk/features/ai/domain/entities/ai_insight.dart';

class AiInsightModel extends AiInsight {
  const AiInsightModel({
    required super.id,
    required super.type,
    required super.priority,
    required super.title,
    required super.description,
    super.actionLabel,
    super.actionRoute,
    super.metadata,
    super.impactScore,
    super.isDismissed,
    required super.createdAt,
    super.expiresAt,
  });

  factory AiInsightModel.fromJson(Map<String, dynamic> json) {
    return AiInsightModel(
      id: json['id'] as String,
      type: InsightType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => InsightType.recommendation,
      ),
      priority: InsightPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => InsightPriority.medium,
      ),
      title: json['title'] as String,
      description: json['description'] as String,
      actionLabel: json['action_label'] as String?,
      actionRoute: json['action_route'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      impactScore: json['impact_score'] != null
          ? (json['impact_score'] as num).toDouble()
          : null,
      isDismissed: json['is_dismissed'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'priority': priority.name,
        'title': title,
        'description': description,
        'action_label': actionLabel,
        'action_route': actionRoute,
        'metadata': metadata,
        'impact_score': impactScore,
        'is_dismissed': isDismissed,
        'created_at': createdAt.toIso8601String(),
        'expires_at': expiresAt?.toIso8601String(),
      };
}
