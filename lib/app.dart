import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'data/repository.dart';
import 'state/app_store.dart';
import 'screens/root_screen.dart';
import 'screens/onboarding_screen.dart';

class NovaApp extends StatefulWidget {
  const NovaApp({super.key, this.store});
  final AppStore? store;
  @override
  State<NovaApp> createState() => _NovaAppState();
}

class _NovaAppState extends State<NovaApp> {
  late final AppStore store =
      widget.store ?? (AppStore(MemoryRepository())..onboarded = true);
  @override
  void dispose() {
    if (widget.store == null) store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: store,
    builder: (context, _) => MaterialApp(
      title: 'NOVA — Everyday, elevated.',
      debugShowCheckedModeBanner: false,
      theme: novaTheme(Brightness.light),
      darkTheme: novaTheme(Brightness.dark),
      themeMode: store.themeMode,
      home: store.onboarded
          ? RootScreen(store: store)
          : OnboardingScreen(store: store),
    ),
  );
}
