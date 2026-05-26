part of 'contract_bloc.dart';

sealed class ContractEvent extends Equatable {
  const ContractEvent();
}

class LoadContractEvent extends ContractEvent {
  const LoadContractEvent({required this.bookingId});
  final String bookingId;
  @override
  List<Object?> get props => [bookingId];
}

class SignContractEvent extends ContractEvent {
  const SignContractEvent({required this.bookingId});
  final String bookingId;
  @override
  List<Object?> get props => [bookingId];
}
