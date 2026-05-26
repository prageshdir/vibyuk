part of 'portfolio_bloc.dart';

sealed class PortfolioState extends Equatable {
  const PortfolioState();
}

class PortfolioInitialState extends PortfolioState {
  const PortfolioInitialState();
  @override
  List<Object?> get props => [];
}

class PortfolioLoadingState extends PortfolioState {
  const PortfolioLoadingState();
  @override
  List<Object?> get props => [];
}

class PortfolioLoadedState extends PortfolioState {
  const PortfolioLoadedState({
    required this.items,
    required this.hasMore,
    required this.currentPage,
    this.isLoadingMore = false,
    this.isUploading = false,
    this.uploadError,
    this.uploadSuccess = false,
  });

  final List<PortfolioItemEntity> items;
  final bool hasMore;
  final int currentPage;
  final bool isLoadingMore;
  final bool isUploading;
  final Failure? uploadError;
  final bool uploadSuccess;

  PortfolioLoadedState copyWith({
    List<PortfolioItemEntity>? items,
    bool? hasMore,
    int? currentPage,
    bool? isLoadingMore,
    bool? isUploading,
    Failure? uploadError,
    bool? uploadSuccess,
  }) =>
      PortfolioLoadedState(
        items: items ?? this.items,
        hasMore: hasMore ?? this.hasMore,
        currentPage: currentPage ?? this.currentPage,
        isLoadingMore: isLoadingMore ?? false,
        isUploading: isUploading ?? false,
        uploadError: uploadError,
        uploadSuccess: uploadSuccess ?? false,
      );

  @override
  List<Object?> get props =>
      [items, hasMore, currentPage, isLoadingMore, isUploading, uploadError, uploadSuccess];
}

class PortfolioErrorState extends PortfolioState {
  const PortfolioErrorState({required this.failure});
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}
