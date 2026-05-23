import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/logging/app_logger.dart';

abstract class BaseBloc<Event, State> extends Bloc<Event, State> {
  BaseBloc(super.initialState) {
    AppLogger.debug('BLoC created: $runtimeType');
  }

  @override
  void onEvent(Event event) {
    super.onEvent(event);
    AppLogger.logBlocEvent(runtimeType.toString(), event.runtimeType.toString());
  }

  @override
  void onChange(Change<State> change) {
    super.onChange(change);
    AppLogger.logBlocState(runtimeType.toString(), change.nextState.runtimeType.toString());
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    AppLogger.error(
      'BLoC error in $runtimeType',
      error: error,
      stackTrace: stackTrace,
    );
    super.onError(error, stackTrace);
  }

  @override
  Future<void> close() {
    AppLogger.debug('BLoC closed: $runtimeType');
    return super.close();
  }
}

abstract class BaseCubit<State> extends Cubit<State> {
  BaseCubit(super.initialState) {
    AppLogger.debug('Cubit created: $runtimeType');
  }

  @override
  void onChange(Change<State> change) {
    super.onChange(change);
    AppLogger.logBlocState(runtimeType.toString(), change.nextState.runtimeType.toString());
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    AppLogger.error('Cubit error in $runtimeType', error: error, stackTrace: stackTrace);
    super.onError(error, stackTrace);
  }
}
