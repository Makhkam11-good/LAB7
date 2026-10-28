import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/product.dart';
import '../models/commerce.dart';
import '../data/catalog.dart';
import '../data/repository.dart';

class AppStore extends ChangeNotifier {
  AppStore(this.repository);
  final DataRepository repository;
  final Set<String> favorites = {};
  final Map<String, CartItem> cart = {};
  final List<DemoOrder> orders = [];
  final List<Product> catalog = [...products];
  int arrivalSerial = 0;
  UserProfile? profile;
  ThemeMode themeMode = ThemeMode.system;
  bool onboarded = false;
  String? storageError;
  Future<void> _writes = Future.value();
  int get cartCount => cart.values.fold(0, (sum, i) => sum + i.quantity);
  int get subtotal =>
      cart.values.fold(0, (sum, i) => sum + i.product.priceCents * i.quantity);
  int available(Product p, ProductVariant v) =>
      (v.stock -
              orders
                  .expand((o) => o.items)
                  .where((i) => i.productId == p.id && i.variantId == v.id)
                  .fold(0, (sum, i) => sum + i.quantity))
          .clamp(0, 99)
          .toInt();
  Future<void> load() async {
    try {
      final raw = await repository.read();
      if (raw == null) return;
      final data = jsonDecode(raw) as Map<String, dynamic>;
      if (data['version'] != 2) {
        throw const FormatException('Unsupported state');
      }
      final restoredOrders = (data['orders'] as List)
          .map((o) => DemoOrder.fromJson(Map<String, dynamic>.from(o as Map)))
          .toList();
      for (final order in restoredOrders) {
        for (final item in order.items) {
          productById(item.productId);
          variantById(productById(item.productId), item.variantId);
          if (item.quantity < 1 || item.unitPrice < 0) {
            throw const FormatException('Invalid order');
          }
        }
      }
      final restoredCart = <String, CartItem>{};
      for (final value in data['cart'] as List) {
        final item = CartItem(
          value['product'] as String,
          value['variant'] as String,
          value['quantity'] as int,
        );
        final variant = item.variant;
        if (item.quantity < 1 || item.quantity > variant.stock) {
          throw const FormatException('Invalid cart');
        }
        restoredCart[item.key] = item;
      }
      final restoredProfile = data['profile'] == null
          ? null
          : UserProfile.fromJson(
              Map<String, dynamic>.from(data['profile'] as Map),
            );
      final restoredTheme = ThemeMode.values.byName(data['theme'] as String);
      final savedIds = (data['favorites'] as List).cast<String>().where((id) {
        try {
          productById(id);
          return true;
        } catch (_) {
          return false;
        }
      }).toSet();
      final restoredCatalog = data['catalog'] == null
          ? [...products]
          : (data['catalog'] as List).cast<String>().map(productById).toList();
      if (restoredCatalog.map((p) => p.id).toSet().length !=
          restoredCatalog.length) {
        throw const FormatException('Duplicate catalog IDs');
      }
      final restoredSerial = data['arrivalSerial'] as int? ?? 0;
      if (restoredSerial < 0) throw const FormatException('Invalid serial');
      orders
        ..clear()
        ..addAll(restoredOrders);
      cart
        ..clear()
        ..addAll(restoredCart);
      profile = restoredProfile;
      catalog
        ..clear()
        ..addAll(restoredCatalog);
      arrivalSerial = restoredSerial;
      favorites
        ..clear()
        ..addAll(savedIds);
      themeMode = restoredTheme;
      onboarded = data['onboarded'] == true;
      cart.removeWhere(
        (_, item) => item.quantity > available(item.product, item.variant),
      );
    } catch (_) {
      storageError =
          'Saved data could not be restored. You can start a fresh collection.';
    }
    notifyListeners();
  }

  Map<String, dynamic> _snapshot() => {
    'version': 2,
    'favorites': favorites.toList(),
    'cart': cart.values.map((i) => i.toJson()).toList(),
    'orders': orders.map((o) => o.toJson()).toList(),
    'profile': profile?.toJson(),
    'theme': themeMode.name,
    'onboarded': onboarded,
    'catalog': catalog.map((p) => p.id).toList(),
    'arrivalSerial': arrivalSerial,
  };
  void _save() {
    final snapshot = jsonEncode(_snapshot());
    _writes = _writes
        .then((_) => repository.write(snapshot))
        .then((_) {
          if (storageError != null) {
            storageError = null;
            notifyListeners();
          }
        })
        .catchError((Object error) {
          storageError =
              'Could not save your changes. Please retry in Profile.';
          notifyListeners();
        });
    notifyListeners();
  }

  Future<void> flush() => _writes;
  // FeedScreen performs mutations inside setState; shared state keeps both view
  // modes and tab revisits consistent and serializes changes to local storage.
  void saveCatalog() => _save();
  void retrySave() => _save();
  void completeOnboarding() {
    onboarded = true;
    _save();
  }

  void setTheme(ThemeMode value) {
    themeMode = value;
    _save();
  }

  void setProfile(UserProfile value) {
    profile = value;
    _save();
  }

  void toggleFavorite(String id) {
    if (!favorites.add(id)) favorites.remove(id);
    _save();
  }

  bool add(Product p, ProductVariant v, int quantity) {
    final key = '${p.id}:${v.id}';
    final next = (cart[key]?.quantity ?? 0) + quantity;
    if (quantity < 1 || next > available(p, v)) return false;
    cart[key] = CartItem(p.id, v.id, next);
    _save();
    return true;
  }

  bool changeQuantity(CartItem item, int quantity) {
    if (quantity < 0 || quantity > available(item.product, item.variant)) {
      return false;
    }
    if (quantity == 0) {
      cart.remove(item.key);
    } else {
      cart[item.key] = CartItem(item.productId, item.variantId, quantity);
    }
    _save();
    return true;
  }

  DemoOrder placeOrder(String name) {
    if (cart.isEmpty) throw StateError('Your bag is empty.');
    if (cart.values.any((i) => i.quantity > available(i.product, i.variant))) {
      throw StateError('A selected item is no longer available.');
    }
    final now = DateTime.now();
    final items = cart.values
        .map(
          (i) => OrderItem(
            productId: i.productId,
            variantId: i.variantId,
            title: i.product.title,
            finish: i.variant.name,
            image: i.product.image,
            unitPrice: i.product.priceCents,
            quantity: i.quantity,
          ),
        )
        .toList(growable: false);
    final order = DemoOrder(
      'NV-${now.microsecondsSinceEpoch.toRadixString(36).toUpperCase()}',
      now,
      items,
      name,
    );
    orders.insert(0, order);
    cart.clear();
    _save();
    return order;
  }
}
