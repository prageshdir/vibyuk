import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/influencer/domain/entities/influencer_campaign_entity.dart';
import 'package:vibyuk/features/influencer/domain/repositories/influencer_repository.dart';

class ApproveDeliverableUseCase
    extends UseCase<ContentDeliverableEntity, DeliverableActionParams> {
  final InfluencerRepository _repository;
  const ApproveDeliverableUseCase(this._repository);

  @override
  Future<Either<Failure, ContentDeliverableEntity>> call(
          DeliverableActionParams params) =>
      _repository.approveDeliverable(
        deliverableId: params.deliverableId,
        campaignId: params.campaignId,
      );
}

class RequestRevisionUseCase
    extends UseCase<ContentDeliverableEntity, RequestRevisionParams> {
  final InfluencerRepository _repository;
  const RequestRevisionUseCase(this._repository);

  @override
  Future<Either<Failure, ContentDeliverableEntity>> call(
          RequestRevisionParams params) =>
      _repository.requestRevision(
        deliverableId: params.deliverableId,
        campaignId: params.campaignId,
        note: params.note,
      );
}

class MarkPublishedUseCase
    extends UseCase<ContentDeliverableEntity, MarkPublishedParams> {
  final InfluencerRepository _repository;
  const MarkPublishedUseCase(this._repository);

  @override
  Future<Either<Failure, ContentDeliverableEntity>> call(
          MarkPublishedParams params) =>
      _repository.markDeliverablePublished(
        deliverableId: params.deliverableId,
        campaignId: params.campaignId,
        postUrl: params.postUrl,
      );
}

class DeliverableActionParams extends Equatable {
  final String deliverableId;
  final String campaignId;

  const DeliverableActionParams({
    required this.deliverableId,
    required this.campaignId,
  });

  @override
  List<Object?> get props => [deliverableId, campaignId];
}

class RequestRevisionParams extends Equatable {
  final String deliverableId;
  final String campaignId;
  final String note;

  const RequestRevisionParams({
    required this.deliverableId,
    required this.campaignId,
    required this.note,
  });

  @override
  List<Object?> get props => [deliverableId, campaignId, note];
}

class MarkPublishedParams extends Equatable {
  final String deliverableId;
  final String campaignId;
  final String postUrl;

  const MarkPublishedParams({
    required this.deliverableId,
    required this.campaignId,
    required this.postUrl,
  });

  @override
  List<Object?> get props => [deliverableId, campaignId, postUrl];
}
