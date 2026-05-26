part of 'contract_bloc.dart';

sealed class ContractState extends Equatable {
  const ContractState();
}

class ContractInitialState extends ContractState {
  const ContractInitialState();
  @override
  List<Object?> get props => [];
}

class ContractLoadingState extends ContractState {
  const ContractLoadingState();
  @override
  List<Object?> get props => [];
}

class ContractLoadedState extends ContractState {
  const ContractLoadedState({
    required this.contract,
    this.isSigning = false,
    this.signError,
    this.signSuccess = false,
  });

  final BookingContractEntity contract;
  final bool isSigning;
  final Failure? signError;
  final bool signSuccess;

  ContractLoadedState copyWith({
    BookingContractEntity? contract,
    bool? isSigning,
    Failure? signError,
    bool? signSuccess,
  }) =>
      ContractLoadedState(
        contract: contract ?? this.contract,
        isSigning: isSigning ?? false,
        signError: signError,
        signSuccess: signSuccess ?? false,
      );

  @override
  List<Object?> get props => [contract, isSigning, signError, signSuccess];
}

class ContractErrorState extends ContractState {
  const ContractErrorState({required this.failure});
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}
