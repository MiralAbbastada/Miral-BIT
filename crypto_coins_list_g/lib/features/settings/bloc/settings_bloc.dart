import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Events
abstract class SettingsEvent {}

class LoadSettings extends SettingsEvent {}

class ToggleDisplayValues extends SettingsEvent {
  final bool displayValues;
  ToggleDisplayValues(this.displayValues);
}

class UpdateTheme extends SettingsEvent {
  final Color newColor;
  UpdateTheme(this.newColor);
}

// States
abstract class SettingsState {
  const SettingsState();
}

class SettingsInitial extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final bool displayValues;
  final Color themeColor;
  final bool useNewTheme;

  SettingsLoaded({
    required this.displayValues,
    required this.themeColor,
    required this.useNewTheme,
  });

  SettingsLoaded copyWith({bool? displayValues, Color? themeColor, bool? useNewTheme}) {
    return SettingsLoaded(
      displayValues: displayValues ?? this.displayValues,
      themeColor: themeColor ?? this.themeColor,
      useNewTheme: useNewTheme ?? this.useNewTheme,
    );
  }
}

// Bloc
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SharedPreferences preferences;

  SettingsBloc({required this.preferences}) : super(SettingsInitial()) {
    on<LoadSettings>((event, emit) async {
      final displayValues = _loadDisplayValues();
      final themeColor = _loadThemeColor();
      final useNewTheme = _loadNewTheme();
      emit(SettingsLoaded(displayValues: displayValues, themeColor: themeColor, useNewTheme: useNewTheme));
    });

    on<ToggleDisplayValues>((event, emit) async {
      await _saveDisplayValues(event.displayValues);
      final currentState = state as SettingsLoaded;
      emit(currentState.copyWith(displayValues: event.displayValues));
    });

    on<UpdateTheme>((event, emit) async {
      await _saveThemeColor(event.newColor);
      final currentState = state as SettingsLoaded;
      emit(currentState.copyWith(themeColor: event.newColor));
    });

    on<ToggleTheme>((event, emit) async {
      await _saveNewTheme(event.useNewTheme);
      final currentState = state as SettingsLoaded;
      emit(currentState.copyWith(useNewTheme: event.useNewTheme));
    });
  }

  bool _loadDisplayValues() {
    return preferences.getBool('displayValues') ?? true;
  }

  Future<void> _saveDisplayValues(bool displayValues) async {
    await preferences.setBool('displayValues', displayValues);
    print('Display values saved: $displayValues'); // Для отладки
  }

  Future<void> _saveNewTheme(bool useNewTheme) async {
    await preferences.setBool('useNewTheme', useNewTheme); // обновляю shared preferences
    print('New theme saved: $useNewTheme');
  }

  Future<void> _saveThemeColor(Color color) async {
    await preferences.setInt('themeColor', color.value);
    print('Theme color saved: ${color.value}'); // Для отладки
  }

  Color _loadThemeColor() {
    final colorValue = preferences.getInt('themeColor') ?? Colors.blue.value;
    print('Loaded theme color: $colorValue');
    return Color(colorValue);
  }

  bool _loadNewTheme() {
    final useNewTheme = preferences.getBool('useNewTheme') ?? false;
    print('Loaded new theme setting: $useNewTheme');
    return useNewTheme;
  }
}

class ThemeUpdated extends SettingsState {
  final Color color;

  ThemeUpdated(this.color);
}

class ToggleTheme extends SettingsEvent {
  final bool useNewTheme;
  ToggleTheme(this.useNewTheme);
}