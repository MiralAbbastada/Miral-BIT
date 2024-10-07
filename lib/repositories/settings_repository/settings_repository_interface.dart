abstract interface class SettingsRepositoryInterface{
  bool isCorrectDataSelected();
  Future<bool> setCorrectDataSelected(bool enabled);
}