import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
part 'theme_event.dart';
part 'theme_state.dart';
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(const ThemeState(isDarkMode: false)) {
    on<ToggleThemeEvent>(_onToggleTheme);
  }
  Future<void> _onToggleTheme(
      ToggleThemeEvent event,
      Emitter<ThemeState> emit,
      ) async {
    emit(ThemeState(isDarkMode: !state.isDarkMode));
  }
}