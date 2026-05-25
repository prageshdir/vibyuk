import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_package_entity.dart';
import 'package:vibyuk/features/wedding/domain/usecases/build_custom_package_usecase.dart';
import 'package:vibyuk/features/wedding/domain/usecases/get_wedding_packages_usecase.dart';
import 'package:vibyuk/core/base/use_case.dart';

// ---------------------------------------------------------------------------
// Events
// ---------------------------------------------------------------------------

sealed class PackageBuilderEvent extends Equatable {
  const PackageBuilderEvent();
}

final class PackageBuilderLoadRequested extends PackageBuilderEvent {
  const PackageBuilderLoadRequested();

  @override
  List<Object?> get props => [];
}

final class PackageBuilderVendorToggled extends PackageBuilderEvent {
  final String vendorId;
  const PackageBuilderVendorToggled({required this.vendorId});

  @override
  List<Object?> get props => [vendorId];
}

final class PackageBuilderCustomPackageSubmitted extends PackageBuilderEvent {
  final String weddingId;
  final String? customName;
  const PackageBuilderCustomPackageSubmitted({
    required this.weddingId,
    this.customName,
  });

  @override
  List<Object?> get props => [weddingId, customName];
}

// ---------------------------------------------------------------------------
// States
// ---------------------------------------------------------------------------

sealed class PackageBuilderState extends Equatable {
  const PackageBuilderState();
}

final class PackageBuilderInitial extends PackageBuilderState {
  const PackageBuilderInitial();

  @override
  List<Object?> get props => [];
}

final class PackageBuilderLoading extends PackageBuilderState {
  const PackageBuilderLoading();

  @override
  List<Object?> get props => [];
}

final class PackageBuilderLoaded extends PackageBuilderState {
  final List<WeddingPackageEntity> packages;
  final Set<String> selectedVendorIds;
  final bool isSubmitting;

  const PackageBuilderLoaded({
    required this.packages,
    required this.selectedVendorIds,
    this.isSubmitting = false,
  });

  PackageBuilderLoaded copyWith({
    List<WeddingPackageEntity>? packages,
    Set<String>? selectedVendorIds,
    bool? isSubmitting,
  }) =>
      PackageBuilderLoaded(
        packages: packages ?? this.packages,
        selectedVendorIds: selectedVendorIds ?? this.selectedVendorIds,
        isSubmitting: isSubmitting ?? this.isSubmitting,
      );

  @override
  List<Object?> get props => [packages, selectedVendorIds, isSubmitting];
}

final class PackageBuilderError extends PackageBuilderState {
  final Failure failure;
  const PackageBuilderError({required this.failure});

  @override
  List<Object?> get props => [failure];
}

final class PackageBuilderSuccess extends PackageBuilderState {
  final WeddingPackageEntity package;
  const PackageBuilderSuccess({required this.package});

  @override
  List<Object?> get props => [package];
}

// ---------------------------------------------------------------------------
// BLoC
// ---------------------------------------------------------------------------

class PackageBuilderBloc
    extends BaseBloc<PackageBuilderEvent, PackageBuilderState> {
  PackageBuilderBloc({
    required GetWeddingPackagesUseCase getPackages,
    required BuildCustomPackageUseCase buildPackage,
  })  : _getPackages = getPackages,
        _buildPackage = buildPackage,
        super(const PackageBuilderInitial()) {
    on<PackageBuilderLoadRequested>(_onLoadRequested);
    on<PackageBuilderVendorToggled>(_onVendorToggled);
    on<PackageBuilderCustomPackageSubmitted>(_onCustomPackageSubmitted);
  }

  final GetWeddingPackagesUseCase _getPackages;
  final BuildCustomPackageUseCase _buildPackage;

  Future<void> _onLoadRequested(
    PackageBuilderLoadRequested event,
    Emitter<PackageBuilderState> emit,
  ) async {
    emit(const PackageBuilderLoading());
    final result = await _getPackages(const PaginationParams());
    result.fold(
      (f) => emit(PackageBuilderError(failure: f)),
      (page) => emit(PackageBuilderLoaded(
        packages: page.items,
        selectedVendorIds: const {},
      )),
    );
  }

  Future<void> _onVendorToggled(
    PackageBuilderVendorToggled event,
    Emitter<PackageBuilderState> emit,
  ) {
    final current = state;
    if (current is! PackageBuilderLoaded) return Future.value();

    final updated = Set<String>.from(current.selectedVendorIds);
    if (updated.contains(event.vendorId)) {
      updated.remove(event.vendorId);
    } else {
      updated.add(event.vendorId);
    }
    emit(current.copyWith(selectedVendorIds: updated));
    return Future.value();
  }

  Future<void> _onCustomPackageSubmitted(
    PackageBuilderCustomPackageSubmitted event,
    Emitter<PackageBuilderState> emit,
  ) async {
    final current = state;
    if (current is! PackageBuilderLoaded) return;
    if (current.selectedVendorIds.isEmpty) return;

    emit(current.copyWith(isSubmitting: true));
    final result = await _buildPackage(BuildPackageParams(
      weddingId: event.weddingId,
      vendorIds: current.selectedVendorIds.toList(),
      customName: event.customName,
    ));
    result.fold(
      (f) => emit(PackageBuilderError(failure: f)),
      (pkg) => emit(PackageBuilderSuccess(package: pkg)),
    );
  }
}
