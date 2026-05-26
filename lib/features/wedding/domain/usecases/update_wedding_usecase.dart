import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_entity.dart';
import 'package:vibyuk/features/wedding/domain/repositories/wedding_repository.dart';

class UpdateWeddingUseCase extends UseCase<WeddingEntity, UpdateWeddingParams> {
  const UpdateWeddingUseCase(this._repository);
  final WeddingRepository _repository;

  @override
  Future<Either<Failure, WeddingEntity>> call(UpdateWeddingParams params) {
    final data = <String, dynamic>{
      if (params.yourName != null) 'your_name': params.yourName,
      if (params.partnerName != null) 'partner_name': params.partnerName,
      if (params.weddingDate != null)
        'wedding_date': params.weddingDate!.toIso8601String(),
      if (params.totalBudget != null) 'total_budget': params.totalBudget,
      if (params.estimatedGuestCount != null)
        'estimated_guest_count': params.estimatedGuestCount,
      if (params.venueName != null) 'venue_name': params.venueName,
      if (params.theme != null) 'theme': params.theme,
    };
    return _repository.updateWedding(params.weddingId, data);
  }
}

class UpdateWeddingParams extends Equatable {
  const UpdateWeddingParams({
    required this.weddingId,
    this.yourName,
    this.partnerName,
    this.weddingDate,
    this.totalBudget,
    this.estimatedGuestCount,
    this.venueName,
    this.theme,
  });

  final String weddingId;
  final String? yourName;
  final String? partnerName;
  final DateTime? weddingDate;
  final double? totalBudget;
  final int? estimatedGuestCount;
  final String? venueName;
  final String? theme;

  @override
  List<Object?> get props => [
        weddingId,
        yourName,
        partnerName,
        weddingDate,
        totalBudget,
        estimatedGuestCount,
        venueName,
        theme,
      ];
}
