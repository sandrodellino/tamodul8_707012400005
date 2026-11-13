import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);

  void setTheme(ThemeMode mode) => emit(mode);

  void setSystem() => emit(ThemeMode.system);

  void setLight() => emit(ThemeMode.light);

  void setDark() => emit(ThemeMode.dark);

  void toggle() {
    if (state == ThemeMode.dark) {
      emit(ThemeMode.light);
      return;
    }

    emit(ThemeMode.dark);
  }
}
