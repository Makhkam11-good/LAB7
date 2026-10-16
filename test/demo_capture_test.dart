import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab5_product_preview/main.dart';

import 'widget_test.dart' show loadFonts;

void main() {
  setUpAll(loadFonts);
  testWidgets('capture real Flutter screens, themes and accessibility sizes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final s = AppStore(MemoryRepository())..onboarded = true;
    s.setProfile(const UserProfile('Alex Morgan', 'alex@narxoz.kz', 'Student'));
    s.toggleFavorite('headphones');
    s.toggleFavorite('watch');
    s.add(products[0], products[0].variants[0], 1);
    final order = s.placeOrder('Alex Morgan');
    s.add(products[0], products[0].variants[1], 1);
    s.add(products[3], products[3].variants[0], 1);
    await s.flush();
    Future<void> capture(
      String name,
      Widget screen, {
      bool dark = false,
      double scale = 1,
      Size size = const Size(390, 844),
    }) async {
      tester.view.physicalSize = size;
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      final key = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: novaTheme(dark ? Brightness.dark : Brightness.light),
            home: screen,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        for (final p in products) {
          await precacheImage(AssetImage(p.image), key.currentContext!);
        }
      });
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 2);
        final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!;
        final file = File('Screenshots/$name.png');
        await file.parent.create(recursive: true);
        await file.writeAsBytes(bytes.buffer.asUint8List());
        image.dispose();
      });
    }

    final pages = <String, Widget>{
      'onboarding': OnboardingScreen(store: s),
      'feed': RootScreen(store: s),
      'detail': DetailScreen(product: products[0], store: s),
      'favorites': Scaffold(
        appBar: AppBar(title: const Text('NOVA')),
        body: FavoritesScreen(store: s, onExplore: () {}),
      ),
      'bag': BagScreen(store: s),
      'checkout': CheckoutScreen(store: s),
      'receipt': ReceiptScreen(order: order),
      'orders': OrdersScreen(store: s),
      'profile': Scaffold(
        appBar: AppBar(title: const Text('NOVA')),
        body: ProfileScreen(store: s),
      ),
      'registration': const RegistrationScreen(),
      'gallery': const ComponentGallery(),
    };
    for (final entry in pages.entries) {
      await capture('${entry.key}-light', entry.value);
      await capture('${entry.key}-dark', entry.value, dark: true);
      await capture('${entry.key}-large-text', entry.value, scale: 2);
    }
    await capture(
      'detail-wide',
      DetailScreen(product: products[0], store: s),
      size: const Size(1440, 900),
    );
    tester.platformDispatcher.clearTextScaleFactorTestValue();
    // Code-native NOVA monogram. No additional generated imagery.
    await tester.runAsync(() async {
      Future<void> icon(String path, int size) async {
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);
        canvas.drawColor(const Color(0xFF20382E), BlendMode.src);
        canvas.translate(size * .26, size * .26);
        MarkPainter(const Color(0xFFD4E6AD))
            .paint(canvas, Size(size * .48, size * .48));
        final picture = recorder.endRecording();
        final image = await picture.toImage(size, size);
        final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!;
        await File(path).writeAsBytes(bytes.buffer.asUint8List());
        image.dispose();
        picture.dispose();
      }

      await icon('Screenshots/app-icon.png', 1024);
      for (final pair in {
        'mdpi': 48,
        'hdpi': 72,
        'xhdpi': 96,
        'xxhdpi': 144,
        'xxxhdpi': 192,
      }.entries) {
        await icon(
          'android/app/src/main/res/mipmap-${pair.key}/ic_launcher.png',
          pair.value,
        );
      }
      final content = await File(
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json',
      ).readAsString();
      final manifest = jsonDecode(content) as Map<String, dynamic>;
      for (final entry in manifest['images'] as List) {
        final filename = entry['filename'] as String?;
        if (filename == null) continue;
        final points = double.parse((entry['size'] as String).split('x').first);
        final scale = double.parse(
          (entry['scale'] as String).replaceAll('x', ''),
        );
        await icon(
          'ios/Runner/Assets.xcassets/AppIcon.appiconset/$filename',
          (points * scale).round(),
        );
      }
    });
  }, skip: !const bool.fromEnvironment('CAPTURE'));
}
