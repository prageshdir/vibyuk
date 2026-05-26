import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/creator/domain/entities/bank_account_entity.dart';
import 'package:vibyuk/features/creator/domain/usecases/bank_account/get_bank_account_use_case.dart';
import 'package:vibyuk/features/creator/domain/usecases/bank_account/save_bank_account_use_case.dart';

// ---------------------------------------------------------------------------
// Events
// ---------------------------------------------------------------------------

sealed class BankAccountEvent extends Equatable {
  const BankAccountEvent();
}

final class LoadBankAccountEvent extends BankAccountEvent {
  const LoadBankAccountEvent();
  @override
  List<Object?> get props => [];
}

final class SaveBankAccountEvent extends BankAccountEvent {
  final String accountHolderName;
  final String accountNumber;
  final String ifscCode;
  final String bankName;

  const SaveBankAccountEvent({
    required this.accountHolderName,
    required this.accountNumber,
    required this.ifscCode,
    required this.bankName,
  });

  @override
  List<Object?> get props =>
      [accountHolderName, accountNumber, ifscCode, bankName];
}

// ---------------------------------------------------------------------------
// States
// ---------------------------------------------------------------------------

sealed class BankAccountState extends Equatable {
  const BankAccountState();
}

final class BankAccountInitialState extends BankAccountState {
  const BankAccountInitialState();
  @override
  List<Object?> get props => [];
}

final class BankAccountLoadingState extends BankAccountState {
  const BankAccountLoadingState();
  @override
  List<Object?> get props => [];
}

final class BankAccountLoadedState extends BankAccountState {
  final BankAccountEntity? account;
  final bool isSaving;
  final bool saveSuccess;

  const BankAccountLoadedState({
    this.account,
    this.isSaving = false,
    this.saveSuccess = false,
  });

  BankAccountLoadedState copyWith({
    BankAccountEntity? account,
    bool? isSaving,
    bool? saveSuccess,
  }) =>
      BankAccountLoadedState(
        account: account ?? this.account,
        isSaving: isSaving ?? this.isSaving,
        saveSuccess: saveSuccess ?? this.saveSuccess,
      );

  @override
  List<Object?> get props => [account, isSaving, saveSuccess];
}

final class BankAccountErrorState extends BankAccountState {
  final Failure failure;
  const BankAccountErrorState(this.failure);
  @override
  List<Object?> get props => [failure];
}

// ---------------------------------------------------------------------------
// BLoC
// ---------------------------------------------------------------------------

class BankAccountBloc extends BaseBloc<BankAccountEvent, BankAccountState> {
  BankAccountBloc({
    required GetBankAccountUseCase getBankAccount,
    required SaveBankAccountUseCase saveBankAccount,
  })  : _getBankAccount = getBankAccount,
        _saveBankAccount = saveBankAccount,
        super(const BankAccountInitialState()) {
    on<LoadBankAccountEvent>(_onLoad);
    on<SaveBankAccountEvent>(_onSave);
  }

  final GetBankAccountUseCase _getBankAccount;
  final SaveBankAccountUseCase _saveBankAccount;

  Future<void> _onLoad(
    LoadBankAccountEvent event,
    Emitter<BankAccountState> emit,
  ) async {
    emit(const BankAccountLoadingState());
    final result = await _getBankAccount(const NoParams());
    result.fold(
      (failure) => emit(BankAccountErrorState(failure)),
      (account) => emit(BankAccountLoadedState(account: account)),
    );
  }

  Future<void> _onSave(
    SaveBankAccountEvent event,
    Emitter<BankAccountState> emit,
  ) async {
    final current = state;
    if (current is BankAccountLoadedState) {
      emit(current.copyWith(isSaving: true, saveSuccess: false));
    }
    final result = await _saveBankAccount(SaveBankAccountParams(
      accountHolderName: event.accountHolderName,
      accountNumber: event.accountNumber,
      ifscCode: event.ifscCode,
      bankName: event.bankName,
    ));
    result.fold(
      (failure) => emit(BankAccountErrorState(failure)),
      (account) => emit(BankAccountLoadedState(
        account: account,
        isSaving: false,
        saveSuccess: true,
      )),
    );
  }
}
