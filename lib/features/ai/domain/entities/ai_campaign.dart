import 'package:equatable/equatable.dart';

enum CampaignStatus { draft, active, paused, completed, cancelled }
enum CampaignStepType { content, outreach, event, social, email, paid }
enum CampaignStepStatus { pending, inProgress, completed, skipped }

class AiCampaignStep extends Equatable {
  final String id;
  final String title;
  final String description;
  final CampaignStepType stepType;
  final DateTime scheduledDate;
  final String? assignedCreatorId;
  final String? assignedCreatorName;
  final double estimatedCost;
  final CampaignStepStatus status;
  final int orderIndex;

  const AiCampaignStep({
    required this.id,
    required this.title,
    required this.description,
    required this.stepType,
    required this.scheduledDate,
    this.assignedCreatorId,
    this.assignedCreatorName,
    required this.estimatedCost,
    this.status = CampaignStepStatus.pending,
    required this.orderIndex,
  });

  AiCampaignStep copyWith({
    String? id,
    String? title,
    String? description,
    CampaignStepType? stepType,
    DateTime? scheduledDate,
    String? assignedCreatorId,
    String? assignedCreatorName,
    double? estimatedCost,
    CampaignStepStatus? status,
    int? orderIndex,
  }) {
    return AiCampaignStep(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      stepType: stepType ?? this.stepType,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      assignedCreatorId: assignedCreatorId ?? this.assignedCreatorId,
      assignedCreatorName: assignedCreatorName ?? this.assignedCreatorName,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      status: status ?? this.status,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        stepType,
        scheduledDate,
        assignedCreatorId,
        assignedCreatorName,
        estimatedCost,
        status,
        orderIndex,
      ];
}

class AiCampaign extends Equatable {
  final String id;
  final String title;
  final String objective;
  final String targetAudience;
  final double budget;
  final String currency;
  final DateTime startDate;
  final DateTime endDate;
  final List<AiCampaignStep> steps;
  final double estimatedRoi;
  final double estimatedReach;
  final CampaignStatus status;
  final String? aiSummary;
  final DateTime generatedAt;

  const AiCampaign({
    required this.id,
    required this.title,
    required this.objective,
    required this.targetAudience,
    required this.budget,
    this.currency = 'INR',
    required this.startDate,
    required this.endDate,
    required this.steps,
    required this.estimatedRoi,
    required this.estimatedReach,
    this.status = CampaignStatus.draft,
    this.aiSummary,
    required this.generatedAt,
  });

  double get totalStepCost => steps.fold(0, (sum, s) => sum + s.estimatedCost);
  int get completedSteps =>
      steps.where((s) => s.status == CampaignStepStatus.completed).length;
  double get progressPercent =>
      steps.isEmpty ? 0 : completedSteps / steps.length;

  AiCampaign copyWith({
    String? id,
    String? title,
    String? objective,
    String? targetAudience,
    double? budget,
    String? currency,
    DateTime? startDate,
    DateTime? endDate,
    List<AiCampaignStep>? steps,
    double? estimatedRoi,
    double? estimatedReach,
    CampaignStatus? status,
    String? aiSummary,
    DateTime? generatedAt,
  }) {
    return AiCampaign(
      id: id ?? this.id,
      title: title ?? this.title,
      objective: objective ?? this.objective,
      targetAudience: targetAudience ?? this.targetAudience,
      budget: budget ?? this.budget,
      currency: currency ?? this.currency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      steps: steps ?? this.steps,
      estimatedRoi: estimatedRoi ?? this.estimatedRoi,
      estimatedReach: estimatedReach ?? this.estimatedReach,
      status: status ?? this.status,
      aiSummary: aiSummary ?? this.aiSummary,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        objective,
        targetAudience,
        budget,
        currency,
        startDate,
        endDate,
        steps,
        estimatedRoi,
        estimatedReach,
        status,
        aiSummary,
        generatedAt,
      ];
}
