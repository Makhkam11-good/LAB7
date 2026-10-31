import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab5_product_preview/nova.dart';

import 'widget_test.dart' show loadFonts, viewport, ready;

Future<void> launch(WidgetTester tester, AppStore store) async {
  await tester.pumpWidget(NovaApp(store: store));
  await tester.pumpAndSettle();
}

Future<void> swipeAway(WidgetTester tester, String id) async {
  final target = find.byKey(ValueKey(id));
  await tester.ensureVisible(target);
  await tester.drag(target, const Offset(-1000, 0));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadFonts);

  testWidgets('lazy list and two-column grid share data and toggle in AppBar', (
    t,
  ) async {
    viewport(t, const Size(390, 900), 1);
    final store = ready();
    store.catalog.addAll(
      List.generate(120, (index) => arrivalProduct(index + 1)),
    );
    await launch(t, store);
    final list = t.widget<ListView>(
      find.byKey(const PageStorageKey('catalog-list')),
    );
    expect(list.childrenDelegate, isA<SliverChildBuilderDelegate>());
    expect(find.byType(CatalogTile).evaluate().length, lessThan(20));
    await t.tap(find.byTooltip('Show grid'));
    await t.pumpAndSettle();
    final grid = t.widget<GridView>(find.byType(GridView));
    expect(
      (grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount)
          .crossAxisCount,
      2,
    );
    expect(grid.childrenDelegate, isA<SliverChildBuilderDelegate>());
    expect(find.byType(CatalogTile).evaluate().length, lessThan(20));
    expect(store.catalog.length, 124);
    await t.tap(find.byTooltip('Show list'));
    await t.pumpAndSettle();
    expect(find.byType(GridView), findsNothing);
    expect(t.takeException(), isNull);
  });

  testWidgets(
    'refresh waits 1500ms and shows newest existing items without adding',
    (t) async {
      viewport(t, const Size(390, 900), 1);
      final store = ready();
      store.catalog.addAll([arrivalProduct(2), arrivalProduct(10)]);
      final originalIds = store.catalog.map((p) => p.id).toList();
      await launch(t, store);
      await t.tap(find.byTooltip('Sort products'));
      await t.pumpAndSettle();
      await t.tap(find.text('Price: low to high'));
      await t.pumpAndSettle();
      final refresh = t
          .widget<RefreshIndicator>(find.byType(RefreshIndicator))
          .onRefresh;
      final pending = refresh();
      await refresh();
      await t.pump(const Duration(milliseconds: 1499));
      expect(store.catalog.length, 6);
      await t.pump(const Duration(milliseconds: 1));
      await pending;
      await t.pumpAndSettle();
      expect(store.catalog.map((p) => p.id), originalIds);
      expect(store.arrivalSerial, 0);
      expect(
        t.widgetList<CatalogTile>(find.byType(CatalogTile)).first.product.id,
        'arrival-10',
      );
      // Exercise the real overscroll gesture in the other view mode.
      await t.tap(find.byTooltip('Show grid'));
      await t.pumpAndSettle();
      await t.drag(find.byType(GridView), const Offset(0, 450));
      await t.pump(const Duration(milliseconds: 400));
      await t.pump(const Duration(milliseconds: 1500));
      await t.pumpAndSettle();
      expect(store.catalog.map((p) => p.id), originalIds);
      expect(
        t.widgetList<CatalogTile>(find.byType(CatalogTile)).first.product.id,
        'arrival-10',
      );
      expect(store.catalog.map((p) => p.id).toSet().length, 6);
      expect(t.takeException(), isNull);
    },
  );

  testWidgets(
    'right-to-left delete uses stable keys and UNDO restores exact index',
    (t) async {
      viewport(t, const Size(390, 900), 1);
      final store = ready();
      await launch(t, store);
      final dismissible = t.widget<Dismissible>(
        find.byKey(const ValueKey('camera')),
      );
      expect(dismissible.direction, DismissDirection.endToStart);
      expect(dismissible.background, isA<Container>());
      final gesture = await t.startGesture(
        t.getCenter(find.byKey(const ValueKey('camera'))),
      );
      await gesture.moveBy(const Offset(-40, 0));
      await t.pump();
      await gesture.moveBy(const Offset(-80, 0));
      await t.pump(const Duration(milliseconds: 150));
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('camera')),
          matching: find.byIcon(Icons.delete),
        ),
        findsOneWidget,
      );
      expect(
        ((dismissible.background! as Container).decoration! as BoxDecoration)
            .color,
        const Color(0xFFB3261E),
      );
      await gesture.cancel();
      await t.pumpAndSettle();
      await t.drag(
        find.byKey(const ValueKey('headphones')),
        const Offset(350, 0),
      );
      await t.pumpAndSettle();
      expect(store.catalog.length, 4);
      await swipeAway(t, 'camera');
      expect(store.catalog.map((p) => p.id), [
        'headphones',
        'speaker',
        'watch',
      ]);
      expect(find.text('UNDO'), findsOneWidget);
      await t.tap(find.text('UNDO'));
      await t.pumpAndSettle();
      expect(store.catalog.map((p) => p.id), products.map((p) => p.id));
      // Filtered deletion uses the backing-list index, not the visible index.
      await t.enterText(find.byType(TextField), 'speaker');
      await t.pumpAndSettle();
      await swipeAway(t, 'speaker');
      await t.tap(find.text('UNDO'));
      await t.pumpAndSettle();
      expect(store.catalog[2].id, 'speaker');
      expect(t.takeException(), isNull);
    },
  );

  testWidgets(
    'empty state restores seeds and remains pull-to-refresh enabled',
    (t) async {
      viewport(t, const Size(390, 900), 1);
      final store = ready();
      await launch(t, store);
      for (final product in products) {
        await swipeAway(t, product.id);
      }
      expect(find.text('Catalog is Empty'), findsOneWidget);
      await t.tap(find.text('Restore catalog'));
      await t.pumpAndSettle();
      expect(store.catalog.map((p) => p.id), products.map((p) => p.id));
      expect(find.text('UNDO'), findsNothing);
      for (final product in products) {
        await swipeAway(t, product.id);
      }
      await t.drag(
        find.byKey(const ValueKey('catalog-empty-scroll')),
        const Offset(0, 450),
      );
      await t.pump(const Duration(milliseconds: 400));
      await t.pump(const Duration(milliseconds: 1500));
      await t.pumpAndSettle();
      expect(store.catalog, isEmpty);
      expect(find.text('Catalog is Empty'), findsOneWidget);
      expect(t.takeException(), isNull);
    },
  );

  testWidgets(
    'grid deletion and undo preserve the list mode and detail object',
    (t) async {
      viewport(t, const Size(390, 900), 1);
      final store = ready();
      store.catalog.insert(0, arrivalProduct(1));
      await launch(t, store);
      await t.tap(find.byTooltip('Show grid'));
      await t.pumpAndSettle();
      await swipeAway(t, 'arrival-1');
      await t.tap(find.text('UNDO'));
      await t.pumpAndSettle();
      await t.tap(find.text('Studio Headphones · Edit 1'));
      await t.pumpAndSettle();
      expect(
        t.widget<DetailScreen>(find.byType(DetailScreen)).product,
        same(store.catalog.first),
      );
      await t.tap(find.textContaining('Add to Cart'));
      await t.pumpAndSettle();
      expect(store.cart.values.single.product.id, 'arrival-1');
      await t.tap(find.byType(BackButton));
      await t.pumpAndSettle();
      expect(find.byType(GridView), findsOneWidget);
      expect(t.takeException(), isNull);
    },
  );

  testWidgets('refresh after disposal is safe', (t) async {
    viewport(t, const Size(390, 900), 1);
    final store = ready();
    await launch(t, store);
    final pending = t
        .widget<RefreshIndicator>(find.byType(RefreshIndicator))
        .onRefresh();
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(milliseconds: 1500));
    await pending;
    expect(store.catalog.length, 4);
    expect(t.takeException(), isNull);
  });

  test(
    'catalog order, removals and generated-product cart survive reload',
    () async {
      final repository = MemoryRepository();
      final store = AppStore(repository);
      final arrival = arrivalProduct(++store.arrivalSerial);
      store.catalog
        ..removeAt(1)
        ..insert(0, arrival);
      store.saveCatalog();
      store.toggleFavorite(arrival.id);
      store.add(arrival, arrival.variants.first, 1);
      await store.flush();
      final restored = AppStore(repository);
      await restored.load();
      expect(restored.storageError, isNull);
      expect(restored.catalog.map((p) => p.id), [
        'arrival-1',
        'headphones',
        'speaker',
        'watch',
      ]);
      expect(restored.arrivalSerial, 1);
      expect(restored.favorites, contains('arrival-1'));
      expect(restored.subtotal, arrival.priceCents);
    },
  );

  for (final size in [
    const Size(280, 568),
    const Size(320, 568),
    const Size(390, 844),
    const Size(640, 360),
    const Size(1440, 900),
  ]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets(
        'two-column catalog at $size and text $scale has no overflow',
        (t) async {
          viewport(t, size, scale);
          await launch(t, ready());
          await t.tap(find.byTooltip('Show grid'));
          await t.pumpAndSettle();
          expect(t.takeException(), isNull);
          await t.drag(find.byType(GridView), const Offset(0, -1000));
          await t.pumpAndSettle();
          expect(t.takeException(), isNull);
        },
      );
    }
  }
}
