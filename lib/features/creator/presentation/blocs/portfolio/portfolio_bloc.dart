import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/entities/paginated_result.dart';
import 'package:vibyuk/features/creator/domain/entities/portfolio_item_entity.dart';
import 'package:vibyuk/features/creator/domain/usecases/portfolio/add_portfolio_item_use_case.dart';
import 'package:vibyuk/features/creator/domain/usecases/portfolio/delete_portfolio_item_use_case.dart';
import 'package:vibyuk/features/creator/domain/usecases/portfolio/get_portfolio_use_case.dart';
import 'package:vibyuk/features/creator/domain/usecases/portfolio/reorder_portfolio_use_case.dart';
import 'package:vibyuk/features/creator/domain/usecases/portfolio/update_portfolio_item_use_case.dart';

part 'portfolio_event.dart';
part 'portfolio_state.dart';

class PortfolioBloc extends BaseBloc<PortfolioEvent, PortfolioState> {
  PortfolioBloc({
    required GetPortfolioUseCase getPortfolio,
    required AddPortfolioItemUseCase addItem,
    required UpdatePortfolioItemUseCase updateItem,
    required DeletePortfolioItemUseCase deleteItem,
    required ReorderPortfolioUseCase reorderPortfolio,
  })  : _getPortfolio = getPortfolio,
        _addItem = addItem,
        _updateItem = updateItem,
        _deleteItem = deleteItem,
        _reorderPortfolio = reorderPortfolio,
        super(const PortfolioInitialState()) {
    on<LoadPortfolioEvent>(_onLoad);
    on<LoadMorePortfolioEvent>(_onLoadMore);
    on<AddPortfolioItemEvent>(_onAdd);
    on<UpdatePortfolioItemEvent>(_onUpdate);
    on<DeletePortfolioItemEvent>(_onDelete);
    on<ReorderPortfolioEvent>(_onReorder);
  }

  final GetPortfolioUseCase _getPortfolio;
  final AddPortfolioItemUseCase _addItem;
  final UpdatePortfolioItemUseCase _updateItem;
  final DeletePortfolioItemUseCase _deleteItem;
  final ReorderPortfolioUseCase _reorderPortfolio;

  int _currentPage = 1;
  static const int _pageSize = 20;

  Future<void> _onLoad(
      LoadPortfolioEvent event, Emitter<PortfolioState> emit) async {
    emit(const PortfolioLoadingState());
    _currentPage = 1;
    final result = await _getPortfolio(
        GetPortfolioParams(page: _currentPage, pageSize: _pageSize));
    result.fold(
      (f) => emit(PortfolioErrorState(failure: f)),
      (r) => emit(PortfolioLoadedState(
        items: r.items,
        hasMore: r.hasNextPage,
        currentPage: _currentPage,
      )),
    );
  }

  Future<void> _onLoadMore(
      LoadMorePortfolioEvent event, Emitter<PortfolioState> emit) async {
    if (state is! PortfolioLoadedState) return;
    final current = state as PortfolioLoadedState;
    if (!current.hasMore || current.isLoadingMore) return;
    emit(current.copyWith(isLoadingMore: true));
    final result = await _getPortfolio(
        GetPortfolioParams(page: _currentPage + 1, pageSize: _pageSize));
    result.fold(
      (_) => emit(current.copyWith(isLoadingMore: false)),
      (r) {
        _currentPage++;
        emit(current.copyWith(
          items: [...current.items, ...r.items],
          hasMore: r.hasNextPage,
          currentPage: _currentPage,
          isLoadingMore: false,
        ));
      },
    );
  }

  Future<void> _onAdd(
      AddPortfolioItemEvent event, Emitter<PortfolioState> emit) async {
    if (state is! PortfolioLoadedState) return;
    final current = state as PortfolioLoadedState;
    emit(current.copyWith(isUploading: true));
    final result = await _addItem(AddPortfolioItemParams(
      title: event.title,
      description: event.description,
      mediaType: event.mediaType,
      filePath: event.filePath,
      tags: event.tags,
      isFeatured: event.isFeatured,
    ));
    result.fold(
      (f) => emit(current.copyWith(isUploading: false, uploadError: f)),
      (item) => emit(current.copyWith(
        items: [item, ...current.items],
        isUploading: false,
        uploadSuccess: true,
      )),
    );
  }

  Future<void> _onUpdate(
      UpdatePortfolioItemEvent event, Emitter<PortfolioState> emit) async {
    if (state is! PortfolioLoadedState) return;
    final current = state as PortfolioLoadedState;
    final result = await _updateItem(UpdatePortfolioItemParams(
      itemId: event.itemId,
      title: event.title,
      description: event.description,
      tags: event.tags,
      isFeatured: event.isFeatured,
    ));
    result.fold(
      (_) => null,
      (updated) {
        final items = current.items
            .map((i) => i.id == updated.id ? updated : i)
            .toList();
        emit(current.copyWith(items: items));
      },
    );
  }

  Future<void> _onDelete(
      DeletePortfolioItemEvent event, Emitter<PortfolioState> emit) async {
    if (state is! PortfolioLoadedState) return;
    final current = state as PortfolioLoadedState;
    final optimistic =
        current.items.where((i) => i.id != event.itemId).toList();
    emit(current.copyWith(items: optimistic));
    final result =
        await _deleteItem(DeletePortfolioItemParams(itemId: event.itemId));
    result.fold(
      (_) => emit(current), // rollback
      (_) => null,
    );
  }

  Future<void> _onReorder(
      ReorderPortfolioEvent event, Emitter<PortfolioState> emit) async {
    if (state is! PortfolioLoadedState) return;
    final current = state as PortfolioLoadedState;
    final reordered = event.orderedIds
        .map((id) => current.items.firstWhere((i) => i.id == id))
        .toList();
    emit(current.copyWith(items: reordered));
    await _reorderPortfolio(ReorderPortfolioParams(orderedIds: event.orderedIds));
  }
}
