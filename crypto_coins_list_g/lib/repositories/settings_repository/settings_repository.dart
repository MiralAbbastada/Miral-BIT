import 'package:crypto_coins_list/repositories/settings_repository/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository implements SettingsRepositoryInterface {

  SettingsRepository({required this.preferences});

  final SharedPreferences preferences;

  static const _isCorrectDataSelected = 'correct_data_selected';


  @override
  bool isCorrectDataSelected() {
    final enabled = preferences.getBool(_isCorrectDataSelected);
    return enabled ?? false;
  }

  @override
  Future<bool> setCorrectDataSelected(bool enabled) async => await preferences.setBool(_isCorrectDataSelected, enabled);

}