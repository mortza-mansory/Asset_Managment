import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final GetStorage _box = GetStorage();

  ThemeBloc() : super(LightThemeState()) {
    on<ToggleThemeEvent>(_onToggleTheme);
    on<LoadThemeEvent>(_onLoadTheme);
  }

  Future<void> _onToggleTheme(ToggleThemeEvent event, Emitter emit) async {
    final isDark = state is DarkThemeState;
    final newState = isDark ? LightThemeState() : DarkThemeState();

    _box.write('isDark', !isDark);

    emit(newState);
  }

  Future<void> _onLoadTheme(LoadThemeEvent event, Emitter emit) async {
    final isDark = _box.read('isDark') ?? false;

    emit(isDark ? DarkThemeState() : LightThemeState());
  }
}

// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'theme_event.dart';
// import 'theme_state.dart';
//
// class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
//   ThemeBloc() : super(LightThemeState()) {
//     on<ToggleThemeEvent>(_onToggleTheme);
//     on<LoadThemeEvent>(_onLoadTheme);
//   }
//
//   Future<void> _onToggleTheme(ToggleThemeEvent event, Emitter emit) async {
//     final isDark = state is DarkThemeState;
//     final newState = isDark ? LightThemeState() : DarkThemeState();
//
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('isDark', !isDark);
//
//     emit(newState);
//   }
//
//   Future<void> _onLoadTheme(LoadThemeEvent event, Emitter emit) async {
//     final prefs = await SharedPreferences.getInstance();
//     final isDark = prefs.getBool('isDark') ?? false;
//
//     emit(isDark ? DarkThemeState() : LightThemeState());
//   }
// }
