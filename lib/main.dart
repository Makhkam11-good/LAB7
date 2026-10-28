import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/repository.dart';
import 'state/app_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DataRepository repository;
  bool storageUnavailable = false;
  try {
    repository = PreferencesRepository(await SharedPreferences.getInstance());
  } catch (_) {
    repository = MemoryRepository();
    storageUnavailable = true;
  }
  final store = AppStore(repository);
  await store.load();
  if (storageUnavailable) {
    store.storageError =
        'Local storage is unavailable. Changes will last for this session.';
  }
  runApp(NovaApp(store: store));
}
