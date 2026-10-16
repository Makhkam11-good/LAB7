import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab5_product_preview/main.dart';

Future<void> loadFonts() async {
  final manifest =
      jsonDecode(await rootBundle.loadString('FontManifest.json')) as List;
  for (final entry in manifest) {
    final loader = FontLoader(entry['family'] as String);
    for (final font in entry['fonts'] as List) {
      loader.addFont(rootBundle.load(font['asset'] as String));
    }
    await loader.load();
  }
}

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void viewport(WidgetTester t, Size size, double scale) {
  t.view.physicalSize = size;
  t.view.devicePixelRatio = 1;
  t.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
}

Widget harness(Widget page, {bool dark = false}) => MaterialApp(
  theme: novaTheme(dark ? Brightness.dark : Brightness.light),
  home: Material(child: page),
);
AppStore ready() => AppStore(MemoryRepository())..onboarded = true;
void main() {
  setUpAll(loadFonts);
  test('filtering matches tags and category, sorting uses numeric prices', () {
    expect(filterProducts(query: 'noise').single.id, 'headphones');
    expect(filterProducts(category: 'Audio').length, 2);
    expect(filterProducts(query: 'camera', category: 'Audio'), isEmpty);
    expect(filterProducts(sort: 'Price: low to high').first.id, 'speaker');
    expect(filterProducts(sort: 'Price: high to low').first.id, 'camera');
  });
  test(
    'variant stock, exact totals, immutable orders and durable restoration',
    () async {
      final repo = MemoryRepository();
      final s = AppStore(repo);
      final p = products.first;
      expect(s.add(p, p.variants[2], 1), false);
      expect(s.add(p, p.variants[0], 2), true);
      expect(s.add(p, p.variants[1], 1), true);
      expect(s.cart.length, 2);
      expect(s.subtotal, 74700);
      expect(s.add(p, p.variants[1], 3), false);
      s.toggleFavorite(p.id);
      s.setTheme(ThemeMode.dark);
      s.completeOnboarding();
      s.setProfile(const UserProfile('Alex', 'alex@uni.kz', 'Student'));
      final order = s.placeOrder('Alex');
      expect(order.total, 74700);
      expect(s.cart, isEmpty);
      expect(s.available(p, p.variants[0]), 6);
      expect(s.add(p, p.variants[0], 7), false);
      expect(s.add(p, p.variants[0], 1), true);
      expect(order.items.first.quantity, 2);
      await s.flush();
      final restored = AppStore(repo);
      await restored.load();
      expect(restored.orders.single.total, 74700);
      expect(restored.cartCount, 1);
      expect(restored.favorites, contains(p.id));
      expect(restored.themeMode, ThemeMode.dark);
      expect(restored.profile!.name, 'Alex');
      expect(restored.onboarded, true);
      await restored.load();
      expect(restored.orders.length, 1, reason: 'Reload must be idempotent');
    },
  );
  test('corrupt saved state and failed writes remain recoverable', () async {
    final repo = MemoryRepository()..value = 'broken';
    final s = AppStore(repo);
    await s.load();
    expect(s.storageError, isNotNull);
    expect(s.cart, isEmpty);
    s.toggleFavorite('camera');
    await s.flush();
    expect(s.storageError, isNull);
    expect(jsonDecode(repo.value!)['favorites'], ['camera']);
    final fail = FailingRepository();
    final store = AppStore(fail);
    store.toggleFavorite('camera');
    await store.flush();
    expect(store.storageError, isNotNull);
    fail.fail = false;
    store.retrySave();
    await store.flush();
    expect(store.storageError, isNull);
  });
  testWidgets(
    'onboarding, full object navigation, two back paths and retained state',
    (t) async {
      viewport(t, const Size(900, 1100), 1);
      final s = AppStore(MemoryRepository());
      await t.pumpWidget(NovaApp(store: s));
      await t.pumpAndSettle();
      expect(find.text('Less, but\nbetter.'), findsOneWidget);
      await t.tap(find.text('Continue'));
      await t.pumpAndSettle();
      await t.tap(find.text('Continue'));
      await t.pumpAndSettle();
      await t.tap(find.text('Explore NOVA'));
      await t.pumpAndSettle();
      expect(s.onboarded, true);
      await t.enterText(find.byType(TextField), 'Focus');
      await t.pumpAndSettle();
      await tapVisible(t, find.text('Focus Camera'));
      expect(
        identical(
          t.widget<DetailScreen>(find.byType(DetailScreen)).product,
          products[1],
        ),
        true,
      );
      await t.tap(find.byTooltip('Save Focus Camera'));
      await t.pumpAndSettle();
      await t.tap(find.textContaining('Add to Cart'));
      await t.pumpAndSettle();
      expect(s.cartCount, 1);
      await t.tap(find.byType(BackButton));
      await t.pumpAndSettle();
      expect(
        t.widget<TextField>(find.byType(TextField)).controller!.text,
        'Focus',
      );
      await t.tap(find.text('Favorites'));
      await t.pumpAndSettle();
      await tapVisible(t, find.text('Focus Camera'));
      await tapVisible(t, find.text('Back to collection'));
      expect(
        t
            .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
            .currentIndex,
        1,
      );
      expect(s.favorites, contains('camera'));
      expect(t.takeException(), isNull);
    },
  );
  testWidgets(
    'form validates live, blocks terms, selects role and updates profile',
    (t) async {
      viewport(t, const Size(700, 1200), 1);
      final s = ready();
      await t.pumpWidget(NovaApp(store: s));
      await t.pumpAndSettle();
      await t.tap(find.text('Profile'));
      await t.pumpAndSettle();
      await tapVisible(t, find.text('Create your profile'));
      await tapVisible(t, find.text('Create profile'));
      expect(find.text('Your full name is required.'), findsOneWidget);
      expect(
        find.text('Please accept the Terms and Conditions.'),
        findsOneWidget,
      );
      await t.enterText(find.byKey(const Key('full-name')), 'Alex Student');
      await t.enterText(find.byKey(const Key('email')), 'invalid');
      await t.enterText(find.byKey(const Key('password')), '123');
      await t.pumpAndSettle();
      expect(find.text('Use at least 6 characters.'), findsOneWidget);
      expect(
        find.text('Enter a valid email, e.g. name@narxoz.kz.'),
        findsOneWidget,
      );
      await t.enterText(find.byKey(const Key('email')), 'alex@narxoz.kz');
      await t.enterText(find.byKey(const Key('password')), 'secret123');
      await t.enterText(
        find.widgetWithText(TextFormField, 'Confirm password'),
        'secret123',
      );
      await t.enterText(find.byKey(const Key('password')), 'changed123');
      await t.pumpAndSettle();
      expect(find.text('Passwords must match exactly.'), findsOneWidget);
      await t.enterText(
        find.widgetWithText(TextFormField, 'Confirm password'),
        'changed123',
      );
      await tapVisible(t, find.text('Create profile'));
      expect(s.profile, isNull);
      await tapVisible(t, find.byType(CheckboxListTile));
      await tapVisible(t, find.byType(DropdownButtonFormField<String>));
      await t.tap(find.text('Developer').last);
      await t.pumpAndSettle();
      await tapVisible(t, find.text('Create profile'));
      expect(s.profile!.role, 'Developer');
      expect(find.text('Alex Student'), findsOneWidget);
      expect(t.takeException(), isNull);
      await s.flush();
      expect(
        (s.repository as MemoryRepository).value,
        isNot(contains('changed123')),
      );
    },
  );
  testWidgets(
    'bag to checkout creates a receipt and clears only purchased lines',
    (t) async {
      viewport(t, const Size(390, 844), 1);
      final s = ready();
      s.add(products[0], products[0].variants[0], 2);
      await s.flush();
      await t.pumpWidget(harness(BagScreen(store: s)));
      await t.pumpAndSettle();
      await t.tap(find.text('Continue to demo checkout'));
      await t.pumpAndSettle();
      await t.tap(find.text('Place demo order'));
      await t.pumpAndSettle();
      expect(s.orders, isEmpty);
      await t.enterText(find.byKey(const Key('checkout-name')), 'Alex');
      await t.enterText(find.byKey(const Key('checkout-email')), 'alex@uni.kz');
      await t.tap(find.text('Place demo order'));
      await t.pumpAndSettle();
      expect(find.byType(ReceiptScreen), findsOneWidget);
      expect(s.orders.single.total, 49800);
      expect(s.cartCount, 0);
      expect(t.takeException(), isNull);
    },
  );
  for (final size in [
    const Size(280, 568),
    const Size(320, 568),
    const Size(390, 844),
    const Size(640, 360),
    const Size(768, 1024),
    const Size(1440, 900),
  ]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('all layouts ${size.width}x${size.height} at text $scale', (
        t,
      ) async {
        viewport(t, size, scale);
        final s = ready();
        s.add(products[0], products[0].variants[0], 1);
        final order = s.placeOrder('Alex');
        s.add(products[1], products[1].variants[0], 1);
        s.toggleFavorite('headphones');
        await s.flush();
        for (final page in <Widget>[
          OnboardingScreen(store: s),
          RootScreen(store: s),
          DetailScreen(product: products[0], store: s),
          FavoritesScreen(store: s, onExplore: () {}),
          BagScreen(store: s),
          CheckoutScreen(store: s),
          ReceiptScreen(order: order),
          OrdersScreen(store: s),
          ProfileScreen(store: s),
          const RegistrationScreen(),
          const ComponentGallery(),
        ]) {
          await t.pumpWidget(harness(page, dark: scale == 2));
          await t.pumpAndSettle();
          expect(
            t.takeException(),
            isNull,
            reason: '${page.runtimeType} at $size scale $scale',
          );
        }
        await t.pumpWidget(
          harness(const RegistrationScreen(), dark: scale == 2),
        );
        await t.pumpAndSettle();
        await tapVisible(t, find.text('Create profile'));
        expect(find.text('Your full name is required.'), findsOneWidget);
        t.view.viewInsets = FakeViewPadding(bottom: size.height * .35);
        addTearDown(t.view.resetViewInsets);
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
        t.view.resetViewInsets();
        await t.pumpWidget(
          harness(DetailScreen(product: products[0], store: s)),
        );
        await t.pumpAndSettle();
        final action = find.textContaining('Add to Cart');
        final before = t.getRect(action);
        await t.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
        await t.pumpAndSettle();
        expect(
          t.getRect(action),
          before,
          reason: 'The action stays pinned while content scrolls',
        );
      });
    }
  }
}

class FailingRepository implements DataRepository {
  bool fail = true;
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String data) async {
    if (fail) throw StateError('disk unavailable');
    value = data;
  }
}
