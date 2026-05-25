import 'package:vibyuk/features/ai/domain/entities/ai_campaign.dart';

class AiCampaignStepModel extends AiCampaignStep {
  const AiCampaignStepModel({
    required super.id,
    required super.title,
    required super.description,
    required super.stepType,
    required super.scheduledDate,
    super.assignedCreatorId,
    super.assignedCreatorName,
    required super.estimatedCost,
    super.status,
    required super.orderIndex,
  });

  factory AiCampaignStepModel.fromJson(Map<String, dynamic> json) {
    return AiCampaignStepModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      stepType: CampaignStepType.values.firstWhere(
        (e) => e.name == json['step_type'],
        orElse: () => CampaignStepType.content,
      ),
      scheduledDate: DateTime.parse(json['scheduled_date'] as String),
      assignedCreatorId: json['assigned_creator_id'] as String?,
      assignedCreatorName: json['assigned_creator_name'] as String?,
      estimatedCost: (json['estimated_cost'] as num).toDouble(),
      status: CampaignStepStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => CampaignStepStatus.pending,
      ),
      orderIndex: json['order_index'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'step_type': stepType.name,
      'scheduled_date': scheduledDate.toIso8601String(),
      'assigned_creator_id': assignedCreatorId,
      'assigned_creator_name': assignedCreatorName,
      'estimated_cost': estimatedCost,
      'status': status.name,
      'order_index': orderIndex,
    };
  }
}

class AiCampaignModel extends AiCampaign {
  const AiCampaignModel({
    required super.id,
    required super.title,
    required super.objective,
    required super.targetAudience,
    required super.budget,
    super.currency,
    required super.startDate,
    required super.endDate,
    required super.steps,
    required super.estimatedRoi,
    required super.estimatedReach,
    super.status,
    super.aiSummary,
    required super.generatedAt,
  });

  factory AiCampaignModel.fromJson(Map<String, dynamic> json) {
    return AiCampaignModel(
      id: json['id'] as String,
      title: json['title'] as String,
      objective: json['objective'] as String,
      targetAudience: json['target_audience'] as String,
      budget: (json['budget'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'GBP',
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      steps: (json['steps'] as List)
          .map((s) => AiCampaignStepModel.fromJson(s as Map<String, dynamic>))
          .toList(),
      estimatedRoi: (json['estimated_roi'] as num).toDouble(),
      estimatedReach: (json['estimated_reach'] as num).toDouble(),
      status: CampaignStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => CampaignStatus.draft,
      ),
      aiSummary: json['ai_summary'] as String?,
      generatedAt: DateTime.parse(json['generated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'objective': objective,
      'target_audience': targetAudience,
      'budget': budget,
      'currency': currency,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'steps': (steps as List<AiCampaignStepModel>)
          .map((s) => s.toJson())
          .toList(),
      'estimated_roi': estimatedRoi,
      'estimated_reach': estimatedReach,
      'status': status.name,
      'ai_summary': aiSummary,
      'generated_at': generatedAt.toIso8601String(),
    };
  }
}
