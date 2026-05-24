import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_negotiation_message_entity.dart';
import 'package:vibyuk/features/booking_engine/domain/usecases/negotiation/get_negotiation_messages_use_case.dart';

part 'negotiation_event.dart';
part 'negotiation_state.dart';

class NegotiationBloc extends BaseBloc<NegotiationEvent, NegotiationState> {
  NegotiationBloc({
    required GetNegotiationMessagesUseCase getMessages,
    required SendNegotiationMessageUseCase sendMessage,
  })  : _getMessages = getMessages,
        _sendMessage = sendMessage,
        super(const NegotiationInitialState()) {
    on<LoadNegotiationEvent>(_onLoad);
    on<SendNegotiationEvent>(_onSend);
  }

  final GetNegotiationMessagesUseCase _getMessages;
  final SendNegotiationMessageUseCase _sendMessage;

  Future<void> _onLoad(
      LoadNegotiationEvent event, Emitter<NegotiationState> emit) async {
    emit(const NegotiationLoadingState());
    final result =
        await _getMessages(NegotiationParams(bookingId: event.bookingId));
    result.fold(
      (f) => emit(NegotiationErrorState(failure: f)),
      (msgs) => emit(NegotiationLoadedState(messages: msgs)),
    );
  }

  Future<void> _onSend(
      SendNegotiationEvent event, Emitter<NegotiationState> emit) async {
    if (state is! NegotiationLoadedState) return;
    final current = state as NegotiationLoadedState;
    emit(current.copyWith(isSending: true));
    final result = await _sendMessage(SendNegotiationParams(
      bookingId: event.bookingId,
      type: event.type,
      message: event.message,
      offeredPrice: event.offeredPrice,
      currency: event.currency,
    ));
    result.fold(
      (f) => emit(current.copyWith(sendError: f)),
      (msg) => emit(current.copyWith(
        messages: [...current.messages, msg],
      )),
    );
  }
}
