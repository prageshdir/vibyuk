import 'package:equatable/equatable.dart';

enum WeddingStatus { planning, confirmed, completed }

class WeddingEntity extends Equatable {
  const WeddingEntity({
    required this.id,
    required this.userId,
    required this.yourName,
    required this.partnerName,
    required this.weddingDate,
    required this.totalBudget,
    required this.estimatedGuestCount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.venueName,
    this.theme,
    this.actualGuestCount = 0,
  });

  final String id;
  final String userId;
  final String yourName;
  final String partnerName;
  final DateTime weddingDate;
  final double totalBudget;
  final int estimatedGuestCount;
  final int actualGuestCount;
  final WeddingStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? venueName;
  final String? theme;

  int get daysUntilWedding =>
      weddingDate.difference(DateTime.now()).inDays.clamp(0, 99999);

  String get coupleNames => '$yourName & $partnerName';

  @override
  List<Object?> get props => [
        id,
        userId,
        yourName,
        partnerName,
        weddingDate,
        totalBudget,
        estimatedGuestCount,
        actualGuestCount,
        status,
        venueName,
        theme,
        createdAt,
        updatedAt,
      ];
}
