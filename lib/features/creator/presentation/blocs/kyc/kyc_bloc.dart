import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/creator/domain/entities/kyc_entity.dart';
import 'package:vibyuk/features/creator/domain/usecases/kyc/get_kyc_status_use_case.dart';
import 'package:vibyuk/features/creator/domain/usecases/kyc/submit_kyc_use_case.dart';

part 'kyc_event.dart';
part 'kyc_state.dart';

class KycBloc extends BaseBloc<KycEvent, KycState> {
  KycBloc({
    required GetKycStatusUseCase getKycStatus,
    required SubmitKycUseCase submitKyc,
  })  : _getKycStatus = getKycStatus,
        _submitKyc = submitKyc,
        super(const KycInitialState()) {
    on<LoadKycStatusEvent>(_onLoad);
    on<SubmitKycEvent>(_onSubmit);
  }

  final GetKycStatusUseCase _getKycStatus;
  final SubmitKycUseCase _submitKyc;

  Future<void> _onLoad(
      LoadKycStatusEvent event, Emitter<KycState> emit) async {
    emit(const KycLoadingState());
    final result = await _getKycStatus(NoParams());
    result.fold(
      (f) => emit(KycErrorState(failure: f)),
      (k) => emit(KycLoadedState(kyc: k)),
    );
  }

  Future<void> _onSubmit(
      SubmitKycEvent event, Emitter<KycState> emit) async {
    if (state is! KycLoadedState) return;
    final current = state as KycLoadedState;
    emit(current.copyWith(isSubmitting: true));
    final result = await _submitKyc(SubmitKycParams(
      documentType: event.documentType,
      documentFrontPath: event.documentFrontPath,
      documentBackPath: event.documentBackPath,
      selfiePath: event.selfiePath,
    ));
    result.fold(
      (f) => emit(current.copyWith(isSubmitting: false, submitError: f)),
      (k) => emit(KycLoadedState(kyc: k, submitSuccess: true)),
    );
  }
}
