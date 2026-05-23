import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vibyuk/core/error/failures.dart';

/// A use case that takes [Params] and returns [Either<Failure, Type>].
abstract interface class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// A use case that takes no parameters.
abstract interface class NoParamUseCase<Type> {
  Future<Either<Failure, Type>> call();
}

/// A use case that returns a Stream.
abstract interface class StreamUseCase<Type, Params> {
  Stream<Either<Failure, Type>> call(Params params);
}

/// Sentinel type for use cases that require no parameters.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}

/// Standard pagination parameters.
class PaginationParams extends Equatable {
  final int page;
  final int perPage;

  const PaginationParams({
    this.page = 1,
    this.perPage = 20,
  });

  @override
  List<Object?> get props => [page, perPage];
}
