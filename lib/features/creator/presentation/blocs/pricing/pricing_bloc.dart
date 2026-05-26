import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/base/use_case.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/creator/domain/entities/pricing_package_entity.dart';
import 'package:vibyuk/features/creator/domain/usecases/pricing/create_pricing_package_use_case.dart';
import 'package:vibyuk/features/creator/domain/usecases/pricing/delete_pricing_package_use_case.dart';
import 'package:vibyuk/features/creator/domain/usecases/pricing/get_pricing_packages_use_case.dart';
import 'package:vibyuk/features/creator/domain/usecases/pricing/update_pricing_package_use_case.dart';

part 'pricing_event.dart';
part 'pricing_state.dart';

class PricingBloc extends BaseBloc<PricingEvent, PricingState> {
  PricingBloc({
    required GetPricingPackagesUseCase getPackages,
    required CreatePricingPackageUseCase createPackage,
    required UpdatePricingPackageUseCase updatePackage,
    required DeletePricingPackageUseCase deletePackage,
  })  : _getPackages = getPackages,
        _createPackage = createPackage,
        _updatePackage = updatePackage,
        _deletePackage = deletePackage,
        super(const PricingInitialState()) {
    on<LoadPricingPackagesEvent>(_onLoad);
    on<CreatePricingPackageEvent>(_onCreate);
    on<UpdatePricingPackageEvent>(_onUpdate);
    on<DeletePricingPackageEvent>(_onDelete);
  }

  final GetPricingPackagesUseCase _getPackages;
  final CreatePricingPackageUseCase _createPackage;
  final UpdatePricingPackageUseCase _updatePackage;
  final DeletePricingPackageUseCase _deletePackage;

  Future<void> _onLoad(
      LoadPricingPackagesEvent event, Emitter<PricingState> emit) async {
    emit(const PricingLoadingState());
    final result = await _getPackages(NoParams());
    result.fold(
      (f) => emit(PricingErrorState(failure: f)),
      (packages) => emit(PricingLoadedState(packages: packages)),
    );
  }

  Future<void> _onCreate(
      CreatePricingPackageEvent event, Emitter<PricingState> emit) async {
    if (state is! PricingLoadedState) return;
    final current = state as PricingLoadedState;
    emit(current.copyWith(isSaving: true));
    final result = await _createPackage(PricingPackageParams(
      packageType: event.packageType,
      title: event.title,
      description: event.description,
      price: event.price,
      currency: event.currency,
      deliveryDays: event.deliveryDays,
      inclusions: event.inclusions,
      revisions: event.revisions,
    ));
    result.fold(
      (f) => emit(current.copyWith(isSaving: false, saveError: f)),
      (pkg) => emit(current.copyWith(
        packages: [...current.packages, pkg],
        isSaving: false,
        saveSuccess: true,
      )),
    );
  }

  Future<void> _onUpdate(
      UpdatePricingPackageEvent event, Emitter<PricingState> emit) async {
    if (state is! PricingLoadedState) return;
    final current = state as PricingLoadedState;
    emit(current.copyWith(isSaving: true));
    final result = await _updatePackage(UpdatePricingPackageParams(
      packageId: event.packageId,
      title: event.title,
      description: event.description,
      price: event.price,
      currency: event.currency,
      deliveryDays: event.deliveryDays,
      inclusions: event.inclusions,
      revisions: event.revisions,
      isActive: event.isActive,
    ));
    result.fold(
      (f) => emit(current.copyWith(isSaving: false, saveError: f)),
      (pkg) {
        final updated =
            current.packages.map((p) => p.id == pkg.id ? pkg : p).toList();
        emit(current.copyWith(packages: updated, isSaving: false, saveSuccess: true));
      },
    );
  }

  Future<void> _onDelete(
      DeletePricingPackageEvent event, Emitter<PricingState> emit) async {
    if (state is! PricingLoadedState) return;
    final current = state as PricingLoadedState;
    final optimistic =
        current.packages.where((p) => p.id != event.packageId).toList();
    emit(current.copyWith(packages: optimistic));
    final result =
        await _deletePackage(DeletePricingPackageParams(packageId: event.packageId));
    result.fold(
      (_) => emit(current), // rollback
      (_) => null,
    );
  }
}
