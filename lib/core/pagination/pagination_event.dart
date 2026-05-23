import 'package:equatable/equatable.dart';

sealed class PaginationEvent extends Equatable {
  const PaginationEvent();
}

final class FetchFirstPage<T> extends PaginationEvent {
  const FetchFirstPage();

  @override
  List<Object?> get props => [];
}

final class FetchNextPage<T> extends PaginationEvent {
  const FetchNextPage();

  @override
  List<Object?> get props => [];
}

final class RefreshPage<T> extends PaginationEvent {
  const RefreshPage();

  @override
  List<Object?> get props => [];
}
