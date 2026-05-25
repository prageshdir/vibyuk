import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_contract_entity.dart';
import 'package:vibyuk/features/booking_engine/domain/usecases/contract/get_contract_use_case.dart';

part 'contract_event.dart';
part 'contract_state.dart';

class ContractBloc extends BaseBloc<ContractEvent, ContractState> {
  ContractBloc({
    required GetContractUseCase getContract,
    required SignContractUseCase signContract,
  })  : _getContract = getContract,
        _signContract = signContract,
        super(const ContractInitialState()) {
    on<LoadContractEvent>(_onLoad);
    on<SignContractEvent>(_onSign);
  }

  final GetContractUseCase _getContract;
  final SignContractUseCase _signContract;

  Future<void> _onLoad(
      LoadContractEvent event, Emitter<ContractState> emit) async {
    emit(const ContractLoadingState());
    final result =
        await _getContract(BookingIdParams(bookingId: event.bookingId));
    result.fold(
      (f) => emit(ContractErrorState(failure: f)),
      (c) => emit(ContractLoadedState(contract: c)),
    );
  }

  Future<void> _onSign(
      SignContractEvent event, Emitter<ContractState> emit) async {
    if (state is! ContractLoadedState) return;
    final current = state as ContractLoadedState;
    emit(current.copyWith(isSigning: true));
    final result =
        await _signContract(BookingIdParams(bookingId: event.bookingId));
    result.fold(
      (f) => emit(current.copyWith(signError: f)),
      (c) => emit(ContractLoadedState(contract: c, signSuccess: true)),
    );
  }
}
