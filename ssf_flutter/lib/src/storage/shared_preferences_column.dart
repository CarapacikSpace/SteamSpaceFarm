import 'package:shared_preferences/shared_preferences.dart';

abstract base class const SharedPreferencesColumn<T extends Object>({
  required final SharedPreferencesAsync sharedPreferences,

  required final String key,
}) {
  Future<T?> read();

  Future<void> set(T value);
}

final class const SharedPreferencesColumnString({required super.sharedPreferences, required super.key})
    extends SharedPreferencesColumn<String> {
  @override
  Future<String?> read() => sharedPreferences.getString(key);

  @override
  Future<void> set(String value) async {
    await sharedPreferences.setString(key, value);
  }
}
