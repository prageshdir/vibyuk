import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/features/admin/domain/entities/admin_verification.dart';
import 'package:vibyuk/features/admin/domain/usecases/admin_verification_usecases.dart';

part 'admin_verification_event.dart';
part 'admin_verification_state.dart';

class AdminVerificationBloc
    extends BaseBloc<AdminVerificationEvent, AdminVerificationState> {
  final GetVerificationsUseCase _getVerifications;
  final GetVerificationDetailUseCase _getVerificationDetail;
  final ReviewVerificationUseCase _reviewVerification;

  AdminVerificationBloc({
    required GetVerificationsUseCase getVerifications,
    required GetVerificationDetailUseCase getVerificationDetail,
    required ReviewVerificationUseCase reviewVerification,
  })  : _getVerifications = getVerifications,
        _getVerificationDetail = getVerificationDetail,
        _reviewVerification = reviewVerification,
        super(const AdminVerificationState()) {
    on<AdminVerificationFetch>(_onFetch);
    on<AdminVerificationLoadMore>(_onLoadMore);
    on<AdminVerificationStatusFilterChanged>(_onStatusFilterChanged);
    on<AdminVerificationTypeFilterChanged>(_onTypeFilterChanged);
    on<AdminVerificationSelect>(_onSelect);
    on<AdminVerificationReview>(_onReview);
  }

  Future<void> _onFetch(
    AdminVerificationFetch event,
    Emitter<AdminVerificationState> emit,
  ) async {
    emit(state.copyWith(
      status: AdminVerificationStatus.loading,
      verifications: event.refresh ? [] : state.verifications,
      currentPage: event.refresh ? 0 : state.currentPage,
    ));

    final result = await _getVerifications(GetVerificationsParams(
      page: 1,
      statusFilter: state.statusFilter,
      typeFilter: state.typeFilter,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: AdminVerificationStatus.error,
        errorMessage: failure.message,
      )),
      (page) => emit(state.copyWith(
        status: AdminVerificationStatus.loaded,
        verifications: page.items,
        currentPage: 1,
        hasMore: page.hasNextPage,
      )),
    );
  }

  Future<void> _onLoadMore(
    AdminVerificationLoadMore event,
    Emitter<AdminVerificationState> emit,
  ) async {
    if (!state.hasMore ||
        state.status == AdminVerificationStatus.loadingMore) {
      return;
    }
    emit(state.copyWith(status: AdminVerificationStatus.loadingMore));

    final result = await _getVerifications(GetVerificationsParams(
      page: state.currentPage + 1,
      statusFilter: state.statusFilter,
      typeFilter: state.typeFilter,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: AdminVerificationStatus.loaded,
        errorMessage: failure.message,
      )),
      (page) => emit(state.copyWith(
        status: AdminVerificationStatus.loaded,
        verifications: [...state.verifications, ...page.items],
        currentPage: state.currentPage + 1,
        hasMore: page.hasNextPage,
      )),
    );
  }

  Future<void> _onStatusFilterChanged(
    AdminVerificationStatusFilterChanged event,
    Emitter<AdminVerificationState> emit,
  ) async {
    emit(state.copyWith(statusFilter: () => event.status));
    add(AdminVerificationFetch(refresh: true));
  }

  Future<void> _onTypeFilterChanged(
    AdminVerificationTypeFilterChanged event,
    Emitter<AdminVerificationState> emit,
  ) async {
    emit(state.copyWith(typeFilter: () => event.type));
    add(AdminVerificationFetch(refresh: true));
  }

  Future<void> _onSelect(
    AdminVerificationSelect event,
    Emitter<AdminVerificationState> emit,
  ) async {
    final result = await _getVerificationDetail(
      VerificationIdParams(verificationId: event.verificationId),
    );
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (v) => emit(state.copyWith(selectedVerification: v)),
    );
  }

  Future<void> _onReview(
    AdminVerificationReview event,
    Emitter<AdminVerificationState> emit,
  ) async {
    emit(state.copyWith(isReviewing: true));
    final result = await _reviewVerification(ReviewVerificationParams(
      verificationId: event.verificationId,
      decision: event.decision,
      note: event.note,
      rejectionReason: event.rejectionReason,
    ));
    result.fold(
      (failure) => emit(state.copyWith(
        isReviewing: false,
        errorMessage: failure.message,
      )),
      (updated) => emit(state.copyWith(
        isReviewing: false,
        selectedVerification: updated,
        verifications: state.verifications
            .map((v) => v.id == updated.id ? updated : v)
            .toList(),
        reviewSuccess: 'Verification reviewed successfully',
      )),
    );
  }
}
