import 'package:shared_preferences/shared_preferences.dart';

abstract class DataRepository {
  Future<String?> read();
  Future<void> write(String data);
}

class PreferencesRepository implements DataRepository {
  PreferencesRepository(this.preferences);
  final SharedPreferences preferences;
  @override
  Future<String?> read() async => preferences.getString('nova_state_v2');
  @override
  Future<void> write(String data) async {
    if (!await preferences.setString('nova_state_v2', data)) {
      throw StateError('Storage rejected write');
    }
  }
}

class MemoryRepository implements DataRepository {
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String data) async {
    value = data;
  }
}
