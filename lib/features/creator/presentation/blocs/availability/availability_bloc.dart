import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/creator/domain/entities/availability_entity.dart';
import 'package:vibyuk/features/creator/domain/usecases/availability/block_dates_use_case.dart';
import 'package:vibyuk/features/creator/domain/usecases/availability/get_availability_use_case.dart';
import 'package:vibyuk/features/creator/domain/usecases/availability/update_day_availability_use_case.dart';
import 'package:vibyuk/features/creator/domain/usecases/availability/update_weekly_slots_use_case.dart';

part 'availability_event.dart';
part 'availability_state.dart';

class AvailabilityBloc extends BaseBloc<AvailabilityEvent, AvailabilityState> {
  AvailabilityBloc({
    required GetAvailabilityUseCase getAvailability,
    required UpdateDayAvailabilityUseCase updateDay,
    required UpdateWeeklySlotsUseCase updateSlots,
    required BlockDatesUseCase blockDates,
  })  : _getAvailability = getAvailability,
        _updateDay = updateDay,
        _updateSlots = updateSlots,
        _blockDates = blockDates,
        super(const AvailabilityInitialState()) {
    on<LoadAvailabilityEvent>(_onLoad);
    on<UpdateDayAvailabilityEvent>(_onUpdateDay);
    on<UpdateWeeklySlotsEvent>(_onUpdateSlots);
    on<BlockDatesEvent>(_onBlockDates);
  }

  final GetAvailabilityUseCase _getAvailability;
  final UpdateDayAvailabilityUseCase _updateDay;
  final UpdateWeeklySlotsUseCase _updateSlots;
  final BlockDatesUseCase _blockDates;

  DateTime _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);

  Future<void> _onLoad(
      LoadAvailabilityEvent event, Emitter<AvailabilityState> emit) async {
    emit(const AvailabilityLoadingState());
    final result = await _getAvailability(NoParams());
    result.fold(
      (f) => emit(AvailabilityErrorState(failure: f)),
      (a) => emit(AvailabilityLoadedState(
          availability: a, visibleMonth: _visibleMonth)),
    );
  }

  Future<void> _onUpdateDay(UpdateDayAvailabilityEvent event,
      Emitter<AvailabilityState> emit) async {
    if (state is! AvailabilityLoadedState) return;
    final current = state as AvailabilityLoadedState;
    // Optimistic update
    final newCal = Map<DateTime, DayAvailability>.from(current.availability.calendar);
    newCal[DateTime(event.date.year, event.date.month, event.date.day)] =
        event.status;
    final optimistic = AvailabilityEntity(
      creatorId: current.availability.creatorId,
      calendar: newCal,
      defaultWeeklySlots: current.availability.defaultWeeklySlots,
      blockedDates: current.availability.blockedDates,
    );
    emit(current.copyWith(availability: optimistic));
    await _updateDay(
        UpdateDayAvailabilityParams(date: event.date, status: event.status));
  }

  Future<void> _onUpdateSlots(
      UpdateWeeklySlotsEvent event, Emitter<AvailabilityState> emit) async {
    if (state is! AvailabilityLoadedState) return;
    final current = state as AvailabilityLoadedState;
    emit(current.copyWith(isSaving: true));
    final result = await _updateSlots(UpdateWeeklySlotsParams(slots: event.slots));
    result.fold(
      (f) => emit(current.copyWith(isSaving: false)),
      (a) => emit(AvailabilityLoadedState(
          availability: a,
          visibleMonth: current.visibleMonth,
          saveSuccess: true)),
    );
  }

  Future<void> _onBlockDates(
      BlockDatesEvent event, Emitter<AvailabilityState> emit) async {
    if (state is! AvailabilityLoadedState) return;
    final result = await _blockDates(BlockDatesParams(dates: event.dates));
    result.fold(
      (_) => null,
      (a) {
        if (state is AvailabilityLoadedState) {
          final current = state as AvailabilityLoadedState;
          emit(current.copyWith(availability: a));
        }
      },
    );
  }
}
