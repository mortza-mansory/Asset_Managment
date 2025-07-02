import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeState(false)) {
    on<ThemeEvent>((event, emit) {
      emit(ThemeState(event.isDarkMode));
    });
  }

  void toggleTheme() {
    add(ThemeEvent(!state.isDarkMode));
  }
}
