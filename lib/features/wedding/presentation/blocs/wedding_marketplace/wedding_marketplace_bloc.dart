import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_vendor_entity.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_venue_entity.dart';
import 'package:vibyuk/features/wedding/domain/usecases/get_venues_usecase.dart';
import 'package:vibyuk/features/wedding/domain/usecases/get_wedding_vendors_usecase.dart';

// ---------------------------------------------------------------------------
// Events
// ---------------------------------------------------------------------------

sealed class WeddingMarketplaceEvent extends Equatable {
  const WeddingMarketplaceEvent();
}

final class WeddingMarketplaceVendorsRequested extends WeddingMarketplaceEvent {
  final int page;
  const WeddingMarketplaceVendorsRequested({this.page = 1});

  @override
  List<Object?> get props => [page];
}

final class WeddingMarketplaceCategoryChanged extends WeddingMarketplaceEvent {
  final String? category;
  const WeddingMarketplaceCategoryChanged({this.category});

  @override
  List<Object?> get props => [category];
}

final class WeddingMarketplaceSearchChanged extends WeddingMarketplaceEvent {
  final String query;
  const WeddingMarketplaceSearchChanged({required this.query});

  @override
  List<Object?> get props => [query];
}

final class WeddingMarketplaceVenueToggled extends WeddingMarketplaceEvent {
  const WeddingMarketplaceVenueToggled();

  @override
  List<Object?> get props => [];
}

final class WeddingMarketplaceLoadMoreVendors extends WeddingMarketplaceEvent {
  const WeddingMarketplaceLoadMoreVendors();

  @override
  List<Object?> get props => [];
}

final class WeddingMarketplaceVenuesRequested extends WeddingMarketplaceEvent {
  final int page;
  const WeddingMarketplaceVenuesRequested({this.page = 1});

  @override
  List<Object?> get props => [page];
}

final class WeddingMarketplaceLoadMoreVenues extends WeddingMarketplaceEvent {
  const WeddingMarketplaceLoadMoreVenues();

  @override
  List<Object?> get props => [];
}

// ---------------------------------------------------------------------------
// States
// ---------------------------------------------------------------------------

sealed class WeddingMarketplaceState extends Equatable {
  const WeddingMarketplaceState();
}

final class WeddingMarketplaceInitial extends WeddingMarketplaceState {
  const WeddingMarketplaceInitial();

  @override
  List<Object?> get props => [];
}

final class WeddingMarketplaceLoading extends WeddingMarketplaceState {
  const WeddingMarketplaceLoading();

  @override
  List<Object?> get props => [];
}

final class WeddingMarketplaceLoaded extends WeddingMarketplaceState {
  final List<WeddingVendorEntity> vendors;
  final List<WeddingVenueEntity> venues;
  final bool showingVenues;
  final bool hasMoreVendors;
  final bool hasMoreVenues;
  final int vendorPage;
  final int venuePage;
  final String? selectedCategory;
  final String query;
  final bool isLoadingMore;

  const WeddingMarketplaceLoaded({
    required this.vendors,
    required this.venues,
    required this.showingVenues,
    required this.hasMoreVendors,
    required this.hasMoreVenues,
    required this.vendorPage,
    required this.venuePage,
    this.selectedCategory,
    this.query = '',
    this.isLoadingMore = false,
  });

  WeddingMarketplaceLoaded copyWith({
    List<WeddingVendorEntity>? vendors,
    List<WeddingVenueEntity>? venues,
    bool? showingVenues,
    bool? hasMoreVendors,
    bool? hasMoreVenues,
    int? vendorPage,
    int? venuePage,
    String? selectedCategory,
    String? query,
    bool? isLoadingMore,
  }) =>
      WeddingMarketplaceLoaded(
        vendors: vendors ?? this.vendors,
        venues: venues ?? this.venues,
        showingVenues: showingVenues ?? this.showingVenues,
        hasMoreVendors: hasMoreVendors ?? this.hasMoreVendors,
        hasMoreVenues: hasMoreVenues ?? this.hasMoreVenues,
        vendorPage: vendorPage ?? this.vendorPage,
        venuePage: venuePage ?? this.venuePage,
        selectedCategory: selectedCategory,
        query: query ?? this.query,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );

  @override
  List<Object?> get props => [
        vendors,
        venues,
        showingVenues,
        hasMoreVendors,
        hasMoreVenues,
        vendorPage,
        venuePage,
        selectedCategory,
        query,
        isLoadingMore,
      ];
}

final class WeddingMarketplaceError extends WeddingMarketplaceState {
  final Failure failure;
  const WeddingMarketplaceError({required this.failure});

  @override
  List<Object?> get props => [failure];
}

// ---------------------------------------------------------------------------
// BLoC
// ---------------------------------------------------------------------------

class WeddingMarketplaceBloc
    extends BaseBloc<WeddingMarketplaceEvent, WeddingMarketplaceState> {
  WeddingMarketplaceBloc({
    required GetWeddingVendorsUseCase getVendors,
    required GetVenuesUseCase getVenues,
  })  : _getVendors = getVendors,
        _getVenues = getVenues,
        super(const WeddingMarketplaceInitial()) {
    on<WeddingMarketplaceVendorsRequested>(_onVendorsRequested);
    on<WeddingMarketplaceCategoryChanged>(_onCategoryChanged);
    on<WeddingMarketplaceSearchChanged>(_onSearchChanged);
    on<WeddingMarketplaceVenueToggled>(_onVenueToggled);
    on<WeddingMarketplaceLoadMoreVendors>(_onLoadMoreVendors);
    on<WeddingMarketplaceVenuesRequested>(_onVenuesRequested);
    on<WeddingMarketplaceLoadMoreVenues>(_onLoadMoreVenues);
  }

  final GetWeddingVendorsUseCase _getVendors;
  final GetVenuesUseCase _getVenues;

  String? _category;
  String _query = '';

  Future<void> _onVendorsRequested(
    WeddingMarketplaceVendorsRequested event,
    Emitter<WeddingMarketplaceState> emit,
  ) async {
    if (event.page == 1) emit(const WeddingMarketplaceLoading());
    final result = await _getVendors(GetWeddingVendorsParams(
      page: event.page,
      category: _category,
      query: _query.isEmpty ? null : _query,
    ));
    result.fold(
      (f) => emit(WeddingMarketplaceError(failure: f)),
      (page) => emit(WeddingMarketplaceLoaded(
        vendors: page.items,
        venues: const [],
        showingVenues: false,
        hasMoreVendors: page.currentPage < page.totalPages,
        hasMoreVenues: false,
        vendorPage: page.currentPage,
        venuePage: 1,
        selectedCategory: _category,
        query: _query,
      )),
    );
  }

  Future<void> _onCategoryChanged(
    WeddingMarketplaceCategoryChanged event,
    Emitter<WeddingMarketplaceState> emit,
  ) async {
    _category = event.category;
    emit(const WeddingMarketplaceLoading());
    final result = await _getVendors(GetWeddingVendorsParams(
      page: 1,
      category: _category,
      query: _query.isEmpty ? null : _query,
    ));
    result.fold(
      (f) => emit(WeddingMarketplaceError(failure: f)),
      (page) => emit(WeddingMarketplaceLoaded(
        vendors: page.items,
        venues: const [],
        showingVenues: false,
        hasMoreVendors: page.currentPage < page.totalPages,
        hasMoreVenues: false,
        vendorPage: 1,
        venuePage: 1,
        selectedCategory: _category,
        query: _query,
      )),
    );
  }

  Future<void> _onSearchChanged(
    WeddingMarketplaceSearchChanged event,
    Emitter<WeddingMarketplaceState> emit,
  ) async {
    _query = event.query;
    emit(const WeddingMarketplaceLoading());
    final result = await _getVendors(GetWeddingVendorsParams(
      page: 1,
      category: _category,
      query: _query.isEmpty ? null : _query,
    ));
    result.fold(
      (f) => emit(WeddingMarketplaceError(failure: f)),
      (page) {
        final current = state;
        final venues =
            current is WeddingMarketplaceLoaded ? current.venues : <WeddingVenueEntity>[];
        emit(WeddingMarketplaceLoaded(
          vendors: page.items,
          venues: venues,
          showingVenues: false,
          hasMoreVendors: page.currentPage < page.totalPages,
          hasMoreVenues: false,
          vendorPage: 1,
          venuePage: 1,
          selectedCategory: _category,
          query: _query,
        ));
      },
    );
  }

  Future<void> _onVenueToggled(
    WeddingMarketplaceVenueToggled event,
    Emitter<WeddingMarketplaceState> emit,
  ) async {
    final current = state;
    if (current is! WeddingMarketplaceLoaded) return;

    final nowShowingVenues = !current.showingVenues;
    emit(current.copyWith(showingVenues: nowShowingVenues));

    if (nowShowingVenues && current.venues.isEmpty) {
      final result = await _getVenues(GetVenuesParams(page: 1));
      result.fold(
        (f) => emit(WeddingMarketplaceError(failure: f)),
        (page) {
          final s = state;
          if (s is WeddingMarketplaceLoaded) {
            emit(s.copyWith(
              venues: page.items,
              hasMoreVenues: page.currentPage < page.totalPages,
              venuePage: 1,
            ));
          }
        },
      );
    }
  }

  Future<void> _onLoadMoreVendors(
    WeddingMarketplaceLoadMoreVendors event,
    Emitter<WeddingMarketplaceState> emit,
  ) async {
    final current = state;
    if (current is! WeddingMarketplaceLoaded || !current.hasMoreVendors) return;

    emit(current.copyWith(isLoadingMore: true));
    final nextPage = current.vendorPage + 1;
    final result = await _getVendors(GetWeddingVendorsParams(
      page: nextPage,
      category: _category,
      query: _query.isEmpty ? null : _query,
    ));
    result.fold(
      (f) => emit(WeddingMarketplaceError(failure: f)),
      (page) {
        final s = state;
        if (s is WeddingMarketplaceLoaded) {
          emit(s.copyWith(
            vendors: [...s.vendors, ...page.items],
            hasMoreVendors: page.currentPage < page.totalPages,
            vendorPage: page.currentPage,
            isLoadingMore: false,
          ));
        }
      },
    );
  }

  Future<void> _onVenuesRequested(
    WeddingMarketplaceVenuesRequested event,
    Emitter<WeddingMarketplaceState> emit,
  ) async {
    emit(const WeddingMarketplaceLoading());
    final result = await _getVenues(GetVenuesParams(page: event.page));
    result.fold(
      (f) => emit(WeddingMarketplaceError(failure: f)),
      (page) {
        final current = state;
        final vendors = current is WeddingMarketplaceLoaded
            ? current.vendors
            : <WeddingVendorEntity>[];
        emit(WeddingMarketplaceLoaded(
          vendors: vendors,
          venues: page.items,
          showingVenues: true,
          hasMoreVendors: false,
          hasMoreVenues: page.currentPage < page.totalPages,
          vendorPage: 1,
          venuePage: page.currentPage,
          selectedCategory: _category,
          query: _query,
        ));
      },
    );
  }

  Future<void> _onLoadMoreVenues(
    WeddingMarketplaceLoadMoreVenues event,
    Emitter<WeddingMarketplaceState> emit,
  ) async {
    final current = state;
    if (current is! WeddingMarketplaceLoaded || !current.hasMoreVenues) return;

    emit(current.copyWith(isLoadingMore: true));
    final nextPage = current.venuePage + 1;
    final result = await _getVenues(GetVenuesParams(page: nextPage));
    result.fold(
      (f) => emit(WeddingMarketplaceError(failure: f)),
      (page) {
        final s = state;
        if (s is WeddingMarketplaceLoaded) {
          emit(s.copyWith(
            venues: [...s.venues, ...page.items],
            hasMoreVenues: page.currentPage < page.totalPages,
            venuePage: page.currentPage,
            isLoadingMore: false,
          ));
        }
      },
    );
  }
}
