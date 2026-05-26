import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/events/domain/entities/event_entity.dart';
import 'package:vibyuk/features/events/domain/entities/event_form_data.dart';
import 'package:vibyuk/features/events/domain/entities/ticket_type_entity.dart';
import 'package:vibyuk/features/events/domain/usecases/create_event_usecase.dart';
import 'package:vibyuk/features/events/domain/usecases/update_event_usecase.dart';

// ---------------------------------------------------------------------------
// Events
// ---------------------------------------------------------------------------

sealed class EventFormEvent extends Equatable {
  const EventFormEvent();
}

final class EventFormInitialized extends EventFormEvent {
  final EventEntity? existing;
  const EventFormInitialized({this.existing});

  @override
  List<Object?> get props => [existing];
}

final class EventFormDataUpdated extends EventFormEvent {
  final EventFormData formData;
  const EventFormDataUpdated({required this.formData});

  @override
  List<Object?> get props => [formData];
}

final class EventFormStepChanged extends EventFormEvent {
  final int step;
  const EventFormStepChanged({required this.step});

  @override
  List<Object?> get props => [step];
}

final class EventFormTicketTypeAdded extends EventFormEvent {
  final TicketTypeFormData ticketType;
  const EventFormTicketTypeAdded({required this.ticketType});

  @override
  List<Object?> get props => [ticketType];
}

final class EventFormTicketTypeRemoved extends EventFormEvent {
  final int index;
  const EventFormTicketTypeRemoved({required this.index});

  @override
  List<Object?> get props => [index];
}

final class EventFormTicketTypeUpdated extends EventFormEvent {
  final int index;
  final TicketTypeFormData ticketType;
  const EventFormTicketTypeUpdated({required this.index, required this.ticketType});

  @override
  List<Object?> get props => [index, ticketType];
}

final class EventFormCoverImageSelected extends EventFormEvent {
  final String filePath;
  const EventFormCoverImageSelected({required this.filePath});

  @override
  List<Object?> get props => [filePath];
}

final class EventFormSubmitted extends EventFormEvent {
  const EventFormSubmitted();

  @override
  List<Object?> get props => [];
}

// ---------------------------------------------------------------------------
// States
// ---------------------------------------------------------------------------

sealed class EventFormState extends Equatable {
  const EventFormState();
}

final class EventFormInitial extends EventFormState {
  const EventFormInitial();

  @override
  List<Object?> get props => [];
}

final class EventFormEditing extends EventFormState {
  final EventFormData data;
  final bool isSubmitting;
  final bool isEdit;

  const EventFormEditing({
    required this.data,
    this.isSubmitting = false,
    this.isEdit = false,
  });

  EventFormEditing copyWith({
    EventFormData? data,
    bool? isSubmitting,
    bool? isEdit,
  }) =>
      EventFormEditing(
        data: data ?? this.data,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        isEdit: isEdit ?? this.isEdit,
      );

  @override
  List<Object?> get props => [data, isSubmitting, isEdit];
}

final class EventFormSuccess extends EventFormState {
  final EventEntity event;
  final bool isEdit;

  const EventFormSuccess({required this.event, required this.isEdit});

  @override
  List<Object?> get props => [event, isEdit];
}

final class EventFormError extends EventFormState {
  final Failure failure;
  final EventFormData data;

  const EventFormError({required this.failure, required this.data});

  @override
  List<Object?> get props => [failure, data];
}

// ---------------------------------------------------------------------------
// BLoC
// ---------------------------------------------------------------------------

class EventFormBloc extends BaseBloc<EventFormEvent, EventFormState> {
  EventFormBloc({
    required CreateEventUseCase createEvent,
    required UpdateEventUseCase updateEvent,
  })  : _createEvent = createEvent,
        _updateEvent = updateEvent,
        super(const EventFormInitial()) {
    on<EventFormInitialized>(_onInitialized);
    on<EventFormDataUpdated>(_onDataUpdated);
    on<EventFormStepChanged>(_onStepChanged);
    on<EventFormTicketTypeAdded>(_onTicketTypeAdded);
    on<EventFormTicketTypeRemoved>(_onTicketTypeRemoved);
    on<EventFormTicketTypeUpdated>(_onTicketTypeUpdated);
    on<EventFormCoverImageSelected>(_onCoverImageSelected);
    on<EventFormSubmitted>(_onSubmitted);
  }

  final CreateEventUseCase _createEvent;
  final UpdateEventUseCase _updateEvent;

  // Holds the event id when editing so we can call UpdateEventUseCase.
  String? _editingEventId;

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  EventFormData _fromEntity(EventEntity entity) => EventFormData(
        title: entity.title,
        description: entity.description,
        category: entity.category,
        startDate: entity.startDate,
        endDate: entity.endDate,
        venueName: entity.venueName,
        venueAddress: entity.venueAddress ?? '',
        isOnline: entity.isOnline,
        streamUrl: entity.streamUrl ?? '',
        existingCoverUrl: entity.coverImageUrl,
        ticketTypes: entity.ticketTypes
            .map(
              (t) => TicketTypeFormData(
                id: t.id,
                name: t.name,
                tier: t.tier,
                price: t.price,
                quantity: t.totalQuantity,
                maxPerOrder: t.maxPerOrder,
                perks: t.perks,
                saleEndDate: t.saleEndDate,
              ),
            )
            .toList(),
      );

  EventFormEditing _currentEditing() {
    final s = state;
    if (s is EventFormEditing) return s;
    return const EventFormEditing(data: EventFormData());
  }

  // -------------------------------------------------------------------------
  // Handlers
  // -------------------------------------------------------------------------

  void _onInitialized(
    EventFormInitialized event,
    Emitter<EventFormState> emit,
  ) {
    if (event.existing != null) {
      _editingEventId = event.existing!.id;
      emit(EventFormEditing(
        data: _fromEntity(event.existing!),
        isEdit: true,
      ));
    } else {
      _editingEventId = null;
      emit(const EventFormEditing(data: EventFormData()));
    }
  }

  void _onDataUpdated(
    EventFormDataUpdated event,
    Emitter<EventFormState> emit,
  ) {
    final current = _currentEditing();
    emit(current.copyWith(data: event.formData));
  }

  void _onStepChanged(
    EventFormStepChanged event,
    Emitter<EventFormState> emit,
  ) {
    final current = _currentEditing();
    emit(current.copyWith(data: current.data.copyWith(currentStep: event.step)));
  }

  void _onTicketTypeAdded(
    EventFormTicketTypeAdded event,
    Emitter<EventFormState> emit,
  ) {
    final current = _currentEditing();
    final updated = [...current.data.ticketTypes, event.ticketType];
    emit(current.copyWith(data: current.data.copyWith(ticketTypes: updated)));
  }

  void _onTicketTypeRemoved(
    EventFormTicketTypeRemoved event,
    Emitter<EventFormState> emit,
  ) {
    final current = _currentEditing();
    final updated = [...current.data.ticketTypes]..removeAt(event.index);
    emit(current.copyWith(data: current.data.copyWith(ticketTypes: updated)));
  }

  void _onTicketTypeUpdated(
    EventFormTicketTypeUpdated event,
    Emitter<EventFormState> emit,
  ) {
    final current = _currentEditing();
    final updated = [...current.data.ticketTypes]..[event.index] = event.ticketType;
    emit(current.copyWith(data: current.data.copyWith(ticketTypes: updated)));
  }

  void _onCoverImageSelected(
    EventFormCoverImageSelected event,
    Emitter<EventFormState> emit,
  ) {
    final current = _currentEditing();
    emit(current.copyWith(
      data: current.data.copyWith(coverImagePath: event.filePath),
    ));
  }

  Future<void> _onSubmitted(
    EventFormSubmitted event,
    Emitter<EventFormState> emit,
  ) async {
    final current = _currentEditing();
    if (!current.data.canSubmit) return;

    emit(current.copyWith(isSubmitting: true));

    final isEdit = current.isEdit && _editingEventId != null;

    final result = isEdit
        ? await _updateEvent(
            UpdateEventParams(
              eventId: _editingEventId!,
              formData: current.data,
            ),
          )
        : await _createEvent(CreateEventParams(current.data));

    result.fold(
      (failure) => emit(EventFormError(failure: failure, data: current.data)),
      (entity) => emit(EventFormSuccess(event: entity, isEdit: isEdit)),
    );
  }
}
