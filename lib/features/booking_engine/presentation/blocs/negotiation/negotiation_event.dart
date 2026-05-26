part of 'negotiation_bloc.dart';

sealed class NegotiationEvent extends Equatable {
  const NegotiationEvent();
}

class LoadNegotiationEvent extends NegotiationEvent {
  const LoadNegotiationEvent({required this.bookingId});
  final String bookingId;
  @override
  List<Object?> get props => [bookingId];
}

class SendNegotiationEvent extends NegotiationEvent {
  const SendNegotiationEvent({
    required this.bookingId,
    required this.type,
    this.message,
    this.offeredPrice,
    this.currency,
  });
  final String bookingId;
  final NegotiationMessageType type;
  final String? message;
  final double? offeredPrice;
  final String? currency;
  @override
  List<Object?> get props =>
      [bookingId, type, message, offeredPrice, currency];
}
