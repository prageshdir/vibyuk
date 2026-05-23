import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/error/failures.dart';

/// Base state for all BLoCs in the app.
sealed class BaseState extends Equatable {
  const BaseState();
}

final class InitialState extends BaseState {
  const InitialState();

  @override
  List<Object?> get props => [];
}

final class LoadingState extends BaseState {
  const LoadingState();

  @override
  List<Object?> get props => [];
}

final class SuccessState<T> extends BaseState {
  final T data;

  const SuccessState(this.data);

  @override
  List<Object?> get props => [data];
}

final class ErrorState extends BaseState {
  final Failure failure;

  const ErrorState(this.failure);

  String get message => failure.message;

  @override
  List<Object?> get props => [failure];
}

final class EmptyState extends BaseState {
  const EmptyState();

  @override
  List<Object?> get props => [];
}
