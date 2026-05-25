import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/events/domain/entities/event_entity.dart';
import 'package:vibyuk/features/events/domain/entities/ticket_purchase_entity.dart';
import 'package:vibyuk/features/events/domain/usecases/purchase_tickets_usecase.dart';

// ---------------------------------------------------------------------------
// Events
// ---------------------------------------------------------------------------

sealed class TicketPurchaseEvent extends Equatable {
  const TicketPurchaseEvent();
}

final class TicketPurchaseEventLoaded extends TicketPurchaseEvent {
  final EventEntity event;
  const TicketPurchaseEventLoaded({required this.event});

  @override
  List<Object?> get props => [event];
}

final class TicketQuantityUpdated extends TicketPurchaseEvent {
  final String ticketTypeId;
  final int quantity;
  const TicketQuantityUpdated({required this.ticketTypeId, required this.quantity});

  @override
  List<Object?> get props => [ticketTypeId, quantity];
}

final class TicketPurchaseSubmitted extends TicketPurchaseEvent {
  final String paymentMethodId;
  const TicketPurchaseSubmitted({required this.paymentMethodId});

  @override
  List<Object?> get props => [paymentMethodId];
}

final class TicketPurchaseReset extends TicketPurchaseEvent {
  const TicketPurchaseReset();

  @override
  List<Object?> get props => [];
}

// ---------------------------------------------------------------------------
// States
// ---------------------------------------------------------------------------

sealed class TicketPurchaseState extends Equatable {
  const TicketPurchaseState();
}

final class TicketPurchaseInitial extends TicketPurchaseState {
  const TicketPurchaseInitial();

  @override
  List<Object?> get props => [];
}

final class TicketPurchaseReady extends TicketPurchaseState {
  final EventEntity event;
  final Map<String, int> quantities;
  final bool isProcessing;

  const TicketPurchaseReady({
    required this.event,
    required this.quantities,
    this.isProcessing = false,
  });

  double get totalAmount => event.ticketTypes
      .where((t) => (quantities[t.id] ?? 0) > 0)
      .fold(0.0, (sum, t) => sum + t.price * (quantities[t.id] ?? 0));

  int get totalTickets => quantities.values.fold(0, (s, q) => s + q);

  bool get canPurchase => totalTickets > 0 && !isProcessing;

  TicketPurchaseReady copyWith({
    EventEntity? event,
    Map<String, int>? quantities,
    bool? isProcessing,
  }) =>
      TicketPurchaseReady(
        event: event ?? this.event,
        quantities: quantities ?? this.quantities,
        isProcessing: isProcessing ?? this.isProcessing,
      );

  @override
  List<Object?> get props => [event, quantities, isProcessing];
}

final class TicketPurchaseSuccess extends TicketPurchaseState {
  final TicketPurchaseEntity purchase;
  const TicketPurchaseSuccess({required this.purchase});

  @override
  List<Object?> get props => [purchase];
}

final class TicketPurchaseError extends TicketPurchaseState {
  final Failure failure;
  final EventEntity event;
  final Map<String, int> quantities;

  const TicketPurchaseError({
    required this.failure,
    required this.event,
    required this.quantities,
  });

  @override
  List<Object?> get props => [failure, event, quantities];
}

// ---------------------------------------------------------------------------
// BLoC
// ---------------------------------------------------------------------------

class TicketPurchaseBloc
    extends BaseBloc<TicketPurchaseEvent, TicketPurchaseState> {
  TicketPurchaseBloc({required PurchaseTicketsUseCase purchaseTickets})
      : _purchaseTickets = purchaseTickets,
        super(const TicketPurchaseInitial()) {
    on<TicketPurchaseEventLoaded>(_onEventLoaded);
    on<TicketQuantityUpdated>(_onQuantityUpdated);
    on<TicketPurchaseSubmitted>(_onSubmitted);
    on<TicketPurchaseReset>(_onReset);
  }

  final PurchaseTicketsUseCase _purchaseTickets;

  void _onEventLoaded(
    TicketPurchaseEventLoaded event,
    Emitter<TicketPurchaseState> emit,
  ) {
    emit(TicketPurchaseReady(event: event.event, quantities: const {}));
  }

  void _onQuantityUpdated(
    TicketQuantityUpdated event,
    Emitter<TicketPurchaseState> emit,
  ) {
    final current = state;
    if (current is! TicketPurchaseReady) return;

    final updated = Map<String, int>.from(current.quantities);
    if (event.quantity <= 0) {
      updated.remove(event.ticketTypeId);
    } else {
      updated[event.ticketTypeId] = event.quantity;
    }

    emit(current.copyWith(quantities: updated));
  }

  Future<void> _onSubmitted(
    TicketPurchaseSubmitted event,
    Emitter<TicketPurchaseState> emit,
  ) async {
    final current = state;
    if (current is! TicketPurchaseReady) return;
    if (!current.canPurchase) return;

    emit(current.copyWith(isProcessing: true));

    // Build order lines from current quantities and event ticket types.
    final lines = current.event.ticketTypes
        .where((t) => (current.quantities[t.id] ?? 0) > 0)
        .map(
          (t) => TicketOrderLine(
            ticketTypeId: t.id,
            ticketTypeName: t.name,
            tier: t.tier,
            quantity: current.quantities[t.id]!,
            unitPrice: t.price,
            currency: t.currency,
          ),
        )
        .toList();

    final result = await _purchaseTickets(
      PurchaseTicketsParams(
        eventId: current.event.id,
        lines: lines,
        paymentMethodId: event.paymentMethodId,
      ),
    );

    result.fold(
      (failure) => emit(TicketPurchaseError(
        failure: failure,
        event: current.event,
        quantities: current.quantities,
      )),
      (purchase) => emit(TicketPurchaseSuccess(purchase: purchase)),
    );
  }

  void _onReset(
    TicketPurchaseReset event,
    Emitter<TicketPurchaseState> emit,
  ) {
    emit(const TicketPurchaseInitial());
  }
}
