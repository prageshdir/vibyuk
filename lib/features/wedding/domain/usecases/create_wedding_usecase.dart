import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_entity.dart';
import 'package:vibyuk/features/wedding/domain/repositories/wedding_repository.dart';

class CreateWeddingUseCase extends UseCase<WeddingEntity, CreateWeddingParams> {
  const CreateWeddingUseCase(this._repository);
  final WeddingRepository _repository;

  @override
  Future<Either<Failure, WeddingEntity>> call(CreateWeddingParams params) =>
      _repository.createWedding({
        'your_name': params.yourName,
        'partner_name': params.partnerName,
        'wedding_date': params.weddingDate.toIso8601String(),
        'total_budget': params.totalBudget,
        'estimated_guest_count': params.estimatedGuestCount,
        if (params.venueName != null) 'venue_name': params.venueName,
        if (params.theme != null) 'theme': params.theme,
      });
}

class CreateWeddingParams extends Equatable {
  const CreateWeddingParams({
    required this.yourName,
    required this.partnerName,
    required this.weddingDate,
    required this.totalBudget,
    required this.estimatedGuestCount,
    this.venueName,
    this.theme,
  });

  final String yourName;
  final String partnerName;
  final DateTime weddingDate;
  final double totalBudget;
  final int estimatedGuestCount;
  final String? venueName;
  final String? theme;

  @override
  List<Object?> get props => [
        yourName,
        partnerName,
        weddingDate,
        totalBudget,
        estimatedGuestCount,
        venueName,
        theme,
      ];
}
