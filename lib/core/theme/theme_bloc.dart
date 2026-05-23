import 'package:flutter/material.dart';
import 'package:vibyuk/core/base/base_bloc.dart';

// Events
sealed class ThemeEvent {
  const ThemeEvent();
}

final class ToggleTheme extends ThemeEvent {
  const ToggleTheme();
}

final class SetTheme extends ThemeEvent {
  final ThemeMode mode;
  const SetTheme(this.mode);
}

// State
final class ThemeState {
  final ThemeMode mode;
  const ThemeState(this.mode);

  bool get isDark => mode == ThemeMode.dark;
  bool get isLight => mode == ThemeMode.light;
  bool get isSystem => mode == ThemeMode.system;

  ThemeState copyWith({ThemeMode? mode}) => ThemeState(mode ?? this.mode);
}

// BLoC
class ThemeBloc extends BaseBloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(const ThemeState(ThemeMode.system)) {
    on<ToggleTheme>(_onToggle);
    on<SetTheme>(_onSet);
  }

  void _onToggle(ToggleTheme event, Emitter<ThemeState> emit) {
    final next = state.isDark ? ThemeMode.light : ThemeMode.dark;
    emit(ThemeState(next));
  }

  void _onSet(SetTheme event, Emitter<ThemeState> emit) {
    emit(ThemeState(event.mode));
  }
}
