import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

// NOVA · Labs 5, 6, 7. Single-file edition, with explicit architectural sections.
// 01 — Bootstrap and design tokens
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

String money(int cents) =>
    '\$${(cents / 100).toStringAsFixed(cents % 100 == 0 ? 0 : 2)}';
String shortDate(DateTime date) =>
    '${['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][date.month - 1]} ${date.day}, ${date.year}';

class Palette extends ThemeExtension<Palette> {
  const Palette({
    required this.canvas,
    required this.surface,
    required this.ink,
    required this.muted,
    required this.line,
    required this.tint,
  });
  final Color canvas, surface, ink, muted, line, tint;
  static const light = Palette(
    canvas: Color(0xFFF5F6F0),
    surface: Colors.white,
    ink: Color(0xFF20382E),
    muted: Color(0xFF5E6F64),
    line: Color(0xFFDEE5D9),
    tint: Color(0xFFE7EEDC),
  );
  static const dark = Palette(
    canvas: Color(0xFF111D18),
    surface: Color(0xFF1D2C24),
    ink: Color(0xFFF0F4E9),
    muted: Color(0xFFADBDAF),
    line: Color(0xFF36473C),
    tint: Color(0xFF2C4031),
  );
  static Palette of(BuildContext context) =>
      Theme.of(context).extension<Palette>()!;
  @override
  Palette copyWith({
    Color? canvas,
    Color? surface,
    Color? ink,
    Color? muted,
    Color? line,
    Color? tint,
  }) => Palette(
    canvas: canvas ?? this.canvas,
    surface: surface ?? this.surface,
    ink: ink ?? this.ink,
    muted: muted ?? this.muted,
    line: line ?? this.line,
    tint: tint ?? this.tint,
  );
  @override
  Palette lerp(covariant Palette? other, double t) => other == null
      ? this
      : Palette(
          canvas: Color.lerp(canvas, other.canvas, t)!,
          surface: Color.lerp(surface, other.surface, t)!,
          ink: Color.lerp(ink, other.ink, t)!,
          muted: Color.lerp(muted, other.muted, t)!,
          line: Color.lerp(line, other.line, t)!,
          tint: Color.lerp(tint, other.tint, t)!,
        );
}

ThemeData novaTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final p = dark ? Palette.dark : Palette.light;
  final primary = dark ? const Color(0xFFD4E6AD) : const Color(0xFF20382E);
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    fontFamily: 'Roboto',
    extensions: [p],
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF526D43),
          brightness: brightness,
        ).copyWith(
          primary: primary,
          onPrimary: dark ? const Color(0xFF20382E) : Colors.white,
          surface: p.surface,
        ),
    scaffoldBackgroundColor: p.canvas,
    textTheme: ThemeData(
      brightness: brightness,
      fontFamily: 'Roboto',
    ).textTheme.apply(bodyColor: p.ink, displayColor: p.ink),
    appBarTheme: AppBarTheme(
      backgroundColor: p.canvas,
      foregroundColor: p.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    badgeTheme: BadgeThemeData(
      backgroundColor: p.ink,
      textColor: p.canvas,
      textStyle: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    ),
    dividerTheme: DividerThemeData(color: p.line, space: 1),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        minimumSize: const Size(0, 56),
        textStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        side: BorderSide(color: p.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      errorMaxLines: 3,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: p.line),
      ),
    ),
    chipTheme: ChipThemeData(
      side: BorderSide(color: p.line),
      backgroundColor: p.surface,
      selectedColor: p.tint,
      labelStyle: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: p.ink,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: p.ink,
      contentTextStyle: TextStyle(fontFamily: 'Roboto', color: p.canvas),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}

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

// 02 — Immutable catalog, cart and order models (all money uses integer cents)
class ProductVariant {
  const ProductVariant(this.id, this.name, this.color, this.stock);
  final String id, name;
  final Color color;
  final int stock;
}

class Product {
  const Product({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.image,
    required this.priceCents,
    required this.category,
    required this.rating,
    required this.tags,
    required this.variants,
    required this.specs,
  });
  final String id, title, subtitle, description, image, category;
  final int priceCents;
  final double rating;
  final List<String> tags;
  final List<ProductVariant> variants;
  final Map<String, String> specs;
  String get formattedPrice => money(priceCents);
}

const products = [
  Product(
    id: 'headphones',
    title: 'Studio Headphones',
    subtitle: 'A little less world. A little more you.',
    description: 'Find your own quiet. Rich, balanced sound meets a soft, considered fit. Studio is made for focused mornings, long journeys and the songs you keep coming back to.',
    image: 'assets/images/studio.png',
    priceCents: 24900,
    category: 'Audio',
    rating: 4.9,
    tags: ['Wireless', 'Noise cancelling', '40-hour battery'],
    variants: [
      ProductVariant('sage', 'Sage', Color(0xFF9BA48B), 8),
      ProductVariant('sand', 'Sand', Color(0xFFD8CEBB), 3),
      ProductVariant('ink', 'Ink', Color(0xFF343D37), 0),
    ],
    specs: {
      'Listening time': 'Up to 40 hours',
      'Connection': 'Bluetooth 5.3 / USB-C',
      'Weight': '245 g',
      'In the box': 'Headphones, case, charging cable',
    },
  ),
  Product(
    id: 'camera',
    title: 'Focus Camera',
    subtitle: 'Keep the little moments.',
    description: 'An everyday companion for your own way of seeing. A bright prime lens, intuitive controls and a small footprint let you spend less time adjusting and more time discovering.',
    image: 'assets/images/focus.png',
    priceCents: 69900,
    category: 'Photography',
    rating: 4.8,
    tags: ['24 MP', 'Compact', '4K video'],
    variants: [
      ProductVariant('graphite', 'Graphite', Color(0xFF414640), 5),
      ProductVariant('silver', 'Silver', Color(0xFFBBC0B7), 2),
    ],
    specs: {
      'Sensor': '24 megapixels',
      'Video': '4K at 30 fps',
      'Weight': '385 g',
      'In the box': 'Camera, strap, battery, USB-C cable',
    },
  ),
  Product(
    id: 'speaker',
    title: 'Room Speaker',
    subtitle: 'Good sound. Wherever you are.',
    description: 'Small footprint, room-filling sound. Warm bass and clear vocals in a tactile fabric finish. Carry a little atmosphere from a slow morning at home to an evening with friends.',
    image: 'assets/images/room.png',
    priceCents: 12900,
    category: 'Audio',
    rating: 4.7,
    tags: ['Portable', 'Bluetooth', 'Water resistant'],
    variants: [
      ProductVariant('charcoal', 'Charcoal', Color(0xFF50564F), 12),
      ProductVariant('olive', 'Olive', Color(0xFF848E70), 4),
    ],
    specs: {
      'Listening time': 'Up to 18 hours',
      'Protection': 'IPX5 splash resistant',
      'Weight': '620 g',
      'In the box': 'Speaker, USB-C cable',
    },
  ),
  Product(
    id: 'watch',
    title: 'Everyday Watch',
    subtitle: 'Make a little time for yourself.',
    description: 'Clean lines, a quiet dial and a comfortable everyday strap. A considered timepiece that brings a gentler rhythm to a busy day. An essential you will reach for again and again.',
    image: 'assets/images/everyday.png',
    priceCents: 15900,
    category: 'Lifestyle',
    rating: 4.9,
    tags: ['Minimal dial', 'Quartz', '2-year warranty'],
    variants: [
      ProductVariant('taupe', 'Taupe', Color(0xFFADA091), 7),
      ProductVariant('black', 'Black', Color(0xFF323630), 2),
    ],
    specs: {
      'Case': '38 mm brushed steel',
      'Movement': 'Quartz',
      'Strap': '20 mm, interchangeable',
      'In the box': 'Watch, presentation box',
    },
  ),
];
Product productById(String id) => products.firstWhere((p) => p.id == id);
ProductVariant variantById(Product p, String id) =>
    p.variants.firstWhere((v) => v.id == id);
List<Product> filterProducts({
  String query = '',
  String category = 'All',
  String sort = 'Curated',
}) {
  final result = products
      .where(
        (p) =>
            (category == 'All' || p.category == category) &&
            '${p.title} ${p.category} ${p.tags.join(' ')}'
                .toLowerCase()
                .contains(query.trim().toLowerCase()),
      )
      .toList();
  if (sort == 'Price: low to high') {
    result.sort((a, b) => a.priceCents.compareTo(b.priceCents));
  }
  if (sort == 'Price: high to low') {
    result.sort((a, b) => b.priceCents.compareTo(a.priceCents));
  }
  if (sort == 'Top rated') result.sort((a, b) => b.rating.compareTo(a.rating));
  return result;
}

class UserProfile {
  const UserProfile(this.name, this.email, this.role);
  final String name, email, role;
  Map<String, dynamic> toJson() => {'name': name, 'email': email, 'role': role};
  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    json['name'] as String,
    json['email'] as String,
    json['role'] as String,
  );
}

class CartItem {
  const CartItem(this.productId, this.variantId, this.quantity);
  final String productId, variantId;
  final int quantity;
  Product get product => productById(productId);
  ProductVariant get variant => variantById(product, variantId);
  String get key => '$productId:$variantId';
  Map<String, dynamic> toJson() => {
    'product': productId,
    'variant': variantId,
    'quantity': quantity,
  };
}

class OrderItem {
  const OrderItem({
    required this.productId,
    required this.variantId,
    required this.title,
    required this.finish,
    required this.image,
    required this.unitPrice,
    required this.quantity,
  });
  final String productId, variantId, title, finish, image;
  final int unitPrice, quantity;
  Map<String, dynamic> toJson() => {
    'product': productId,
    'variant': variantId,
    'title': title,
    'finish': finish,
    'image': image,
    'unitPrice': unitPrice,
    'quantity': quantity,
  };
  factory OrderItem.fromJson(Map<String, dynamic> j) => OrderItem(
    productId: j['product'] as String,
    variantId: j['variant'] as String,
    title: j['title'] as String,
    finish: j['finish'] as String,
    image: j['image'] as String,
    unitPrice: j['unitPrice'] as int,
    quantity: j['quantity'] as int,
  );
}

class DemoOrder {
  const DemoOrder(this.id, this.created, this.items, this.contactName);
  final String id, contactName;
  final DateTime created;
  final List<OrderItem> items;
  int get total => items.fold(0, (sum, i) => sum + i.unitPrice * i.quantity);
  Map<String, dynamic> toJson() => {
    'id': id,
    'created': created.toIso8601String(),
    'items': items.map((i) => i.toJson()).toList(),
    'contactName': contactName,
  };
  factory DemoOrder.fromJson(Map<String, dynamic> j) => DemoOrder(
    j['id'] as String,
    DateTime.parse(j['created'] as String),
    (j['items'] as List)
        .map((i) => OrderItem.fromJson(Map<String, dynamic>.from(i as Map)))
        .toList(),
    j['contactName'] as String,
  );
}

// 03 — Repository boundary and shared state. No passwords or payment data stored.
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

class AppStore extends ChangeNotifier {
  AppStore(this.repository);
  final DataRepository repository;
  final Set<String> favorites = {};
  final Map<String, CartItem> cart = {};
  final List<DemoOrder> orders = [];
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
      final savedIds = (data['favorites'] as List)
          .cast<String>()
          .where((id) => products.any((p) => p.id == id))
          .toSet();
      orders
        ..clear()
        ..addAll(restoredOrders);
      cart
        ..clear()
        ..addAll(restoredCart);
      profile = restoredProfile;
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

// 04 — Reusable components and adaptive layouts
void feedback(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
}

Future<T?> openPage<T>(BuildContext context, Widget page) => Navigator.push<T>(
  context,
  PageRouteBuilder<T>(
    pageBuilder: (_, animation, secondaryAnimation) => page,
    transitionDuration: motion(context, 380),
    reverseTransitionDuration: motion(context, 280),
    transitionsBuilder: (_, animation, secondaryAnimation, child) {
      final curve = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curve,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(.045, 0),
            end: Offset.zero,
          ).animate(curve),
          child: child,
        ),
      );
    },
  ),
);

class PageBody extends StatelessWidget {
  const PageBody({
    super.key,
    required this.child,
    this.maxWidth = 1120,
    this.controller,
  });
  final Widget child;
  final double maxWidth;
  final ScrollController? controller;
  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: SingleChildScrollView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: SizedBox(width: double.infinity, child: child),
        ),
      ),
    ),
  );
}

class Kicker extends StatelessWidget {
  const Kicker(this.text, {super.key, this.color});
  final String text;
  final Color? color;
  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.8,
      color: color ?? Palette.of(context).muted,
    ),
  );
}

class PageHeading extends StatelessWidget {
  const PageHeading(this.title, this.subtitle, {super.key});
  final String title, subtitle;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: TextStyle(
          fontSize: MediaQuery.textScalerOf(context).scale(1) > 1.3 ? 26 : 36,
          height: 1.12,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.3,
        ),
      ),
      const SizedBox(height: 12),
      Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          height: 1.6,
          color: Palette.of(context).muted,
        ),
      ),
    ],
  );
}

class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });
  final Widget child;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      color: p.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: p.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(padding: padding, child: child),
    );
  }
}

class Tag extends StatelessWidget {
  const Tag(this.text, {super.key, this.onImage = false});
  final String text;
  final bool onImage;
  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: onImage ? const Color(0xFFF6F7F1) : p.tint,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: onImage ? Palette.light.ink : p.ink,
        ),
      ),
    );
  }
}

class ProductImage extends StatelessWidget {
  const ProductImage(this.product, {super.key, this.ratio = 1});
  final Product product;
  final double ratio;
  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: ratio,
    child: Image.asset(
      product.image,
      fit: BoxFit.cover,
      semanticLabel: product.title,
      errorBuilder: (_, error, stack) => ColoredBox(
        color: Palette.of(context).tint,
        child: Center(
          child: Icon(
            Icons.image_outlined,
            size: 48,
            color: Palette.of(context).muted,
          ),
        ),
      ),
    ),
  );
}

class SaveButton extends StatelessWidget {
  const SaveButton({super.key, required this.product, required this.store});
  final Product product;
  final AppStore store;
  @override
  Widget build(BuildContext context) {
    final saved = store.favorites.contains(product.id);
    return Material(
      color: const Color(0xFFF6F7F1),
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: '${saved ? 'Unsave' : 'Save'} ${product.title}',
        isSelected: saved,
        onPressed: () {
          store.toggleFavorite(product.id);
          HapticFeedback.selectionClick();
        },
        icon: AnimatedSwitcher(
          duration: motion(context, 220),
          transitionBuilder: (child, animation) => ScaleTransition(
            scale: animation,
            child: FadeTransition(opacity: animation, child: child),
          ),
          child: Icon(
            saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            key: ValueKey(saved),
            color: Palette.light.ink,
            size: 21,
          ),
        ),
      ),
    );
  }
}

class PrimaryAction extends StatelessWidget {
  const PrimaryAction(
    this.label, {
    super.key,
    required this.onPressed,
    this.icon = Icons.arrow_forward_rounded,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData icon;
  @override
  Widget build(BuildContext context) => PressScale(
    child: FilledButton(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(child: Text(label, textAlign: TextAlign.center)),
          const SizedBox(width: 12),
          Icon(icon, size: 19),
        ],
      ),
    ),
  );
}

class StickyAction extends StatelessWidget {
  const StickyAction({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Container(
      decoration: BoxDecoration(
        color: p.canvas,
        border: Border(top: BorderSide(color: p.line)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Row(children: [Expanded(child: child)]),
            ),
          ),
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.action,
    required this.onAction,
  });
  final IconData icon;
  final String title, message, action;
  final VoidCallback onAction;
  @override
  Widget build(BuildContext context) => SurfaceCard(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Palette.of(context).tint,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 32),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: -.6,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: Palette.of(context).muted, height: 1.6),
        ),
        const SizedBox(height: 24),
        PrimaryAction(action, onPressed: onAction),
      ],
    ),
  );
}

class QuantityControl extends StatelessWidget {
  const QuantityControl({
    super.key,
    required this.value,
    required this.max,
    required this.onChanged,
    this.allowZero = false,
  });
  final int value, max;
  final ValueChanged<int> onChanged;
  final bool allowZero;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Palette.of(context).surface,
      border: Border.all(color: Palette.of(context).line),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Decrease quantity',
          onPressed: value > (allowZero ? 0 : 1)
              ? () => onChanged(value - 1)
              : null,
          icon: const Icon(Icons.remove_rounded, size: 18),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Semantics(
            label: 'Quantity $value',
            child: Text(
              '$value',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
        IconButton(
          tooltip: 'Increase quantity',
          onPressed: value < max ? () => onChanged(value + 1) : null,
          icon: const Icon(Icons.add_rounded, size: 18),
        ),
      ],
    ),
  );
}

// 05 — Motion and screens
Duration motion(BuildContext context, [int ms = 320]) =>
    MediaQuery.disableAnimationsOf(context)
    ? Duration.zero
    : Duration(milliseconds: ms);

class Reveal extends StatelessWidget {
  const Reveal({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: motion(context, 550),
    curve: Curves.easeOutCubic,
    builder: (_, v, child) => Opacity(
      opacity: v,
      child: Transform.translate(offset: Offset(0, 18 * (1 - v)), child: child),
    ),
    child: child,
  );
}

class NovaMark extends StatelessWidget {
  const NovaMark({super.key, this.size = 28});
  final double size;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: CustomPaint(painter: MarkPainter(Palette.of(context).ink)),
  );
}

class MarkPainter extends CustomPainter {
  MarkPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = size.width * .15
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(
      Path()
        ..moveTo(size.width * .17, size.height * .85)
        ..lineTo(size.width * .17, size.height * .15)
        ..lineTo(size.width * .83, size.height * .85)
        ..lineTo(size.width * .83, size.height * .15),
      p,
    );
  }

  @override
  bool shouldRepaint(MarkPainter oldDelegate) => oldDelegate.color != color;
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.store});
  final AppStore store;
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int step = 0;
  static const titles = [
    'Less, but\nbetter.',
    'Find your\neveryday icons.',
    'Make it\nyours.',
  ];
  static const copy = [
    'Thoughtfully chosen objects. A little more intention in every day.',
    'Save what speaks to you. Explore the details. Build a collection at your own pace.',
    'Your favorites, bag and profile stay on this device. Welcome to a more considered kind of shopping.',
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'NOVA',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 4,
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.store.completeOnboarding,
          child: const Text('Skip'),
        ),
        const SizedBox(width: 12),
      ],
    ),
    body: PageBody(
      maxWidth: 560,
      child: AnimatedSwitcher(
        duration: motion(context, 450),
        child: Column(
          key: ValueKey(step),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Stack(
                children: [
                  ProductImage(
                    products[step == 0
                        ? 0
                        : step == 1
                        ? 3
                        : 1],
                    ratio: 1.18,
                  ),
                  Positioned(
                    left: 20,
                    top: 20,
                    child: Tag('THE NOVA EDIT · 0${step + 1}', onImage: true),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            PageHeading(titles[step], copy[step]),
            const SizedBox(height: 24),
            Row(
              children: List.generate(
                3,
                (i) => AnimatedContainer(
                  duration: motion(context),
                  width: i == step ? 32 : 8,
                  height: 5,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: i == step
                        ? Palette.of(context).ink
                        : Palette.of(context).line,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    bottomNavigationBar: StickyAction(
      child: PrimaryAction(
        step == 2 ? 'Explore NOVA' : 'Continue',
        onPressed: () {
          HapticFeedback.selectionClick();
          if (step < 2) {
            setState(() => step++);
          } else {
            widget.store.completeOnboarding();
          }
        },
      ),
    ),
  );
}

class RootScreen extends StatefulWidget {
  const RootScreen({super.key, required this.store});
  final AppStore store;
  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController tabMotion = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
    value: 1,
  );
  @override
  void dispose() {
    tabMotion.dispose();
    super.dispose();
  }

  int tab = 0;
  void select(int value) {
    if (tab == value) return;
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    setState(() => tab = value);
    if (!MediaQuery.disableAnimationsOf(context)) tabMotion.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.store;
    final p = Palette.of(context);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 24,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            NovaMark(size: 22),
            SizedBox(width: 12),
            Text(
              'NOVA',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 4,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Shopping bag, ${s.cartCount} items',
            onPressed: () => openPage(context, BagScreen(store: s)),
            icon: Badge(
              isLabelVisible: s.cartCount > 0,
              label: AnimatedSwitcher(
                duration: motion(context),
                child: Text('${s.cartCount}', key: ValueKey(s.cartCount)),
              ),
              backgroundColor: p.ink,
              textColor: p.canvas,
              child: const Icon(Icons.shopping_bag_outlined),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          if (s.storageError != null)
            MaterialBanner(
              content: Text(s.storageError!),
              actions: [
                TextButton(onPressed: s.retrySave, child: const Text('Retry')),
              ],
            ),
          Expanded(
            child: FadeTransition(
              opacity: CurvedAnimation(
                parent: tabMotion,
                curve: Curves.easeOut,
              ),
              child: IndexedStack(
                index: tab,
                children: [
                  TickerMode(
                    enabled: tab == 0,
                    child: FeedScreen(store: s),
                  ),
                  TickerMode(
                    enabled: tab == 1,
                    child: FavoritesScreen(
                      store: s,
                      onExplore: () => select(0),
                    ),
                  ),
                  TickerMode(
                    enabled: tab == 2,
                    child: ProfileScreen(store: s),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: p.line)),
        ),
        child: BottomNavigationBar(
          currentIndex: tab,
          onTap: select,
          backgroundColor: p.canvas,
          elevation: 0,
          selectedItemColor: p.ink,
          unselectedItemColor: p.muted,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: [
            navItem(
              context,
              0,
              Icons.grid_view_outlined,
              Icons.grid_view_rounded,
              'Discover',
            ),
            navItem(
              context,
              1,
              Icons.bookmark_border_rounded,
              Icons.bookmark_rounded,
              'Favorites',
            ),
            navItem(
              context,
              2,
              Icons.person_outline_rounded,
              Icons.person_rounded,
              'Profile',
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem navItem(
    BuildContext context,
    int index,
    IconData icon,
    IconData selected,
    String label,
  ) => BottomNavigationBarItem(
    label: label,
    icon: AnimatedContainer(
      duration: motion(context),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      margin: const EdgeInsets.only(bottom: 3),
      decoration: BoxDecoration(
        color: tab == index ? Palette.of(context).tint : Colors.transparent,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Icon(tab == index ? selected : icon, size: 22),
    ),
  );
}

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key, required this.store});
  final AppStore store;
  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final search = TextEditingController();
  String category = 'All', sort = 'Curated';
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = filterProducts(
      query: search.text,
      category: category,
      sort: sort,
    );
    final p = Palette.of(context);
    return PageBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Reveal(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Kicker('Considered objects. Everyday joy.'),
                SizedBox(height: 12),
                PageHeading(
                  'Everyday,\nelevated.',
                  'Good design. Great company. Your next favorite.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: search,
            onChanged: (_) => setState(() {}),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Find your next favorite',
              prefixIcon: const Icon(Icons.search_rounded, size: 22),
              suffixIcon: search.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      onPressed: () {
                        search.clear();
                        setState(() {});
                      },
                      icon: const Icon(Icons.close_rounded, size: 20),
                    ),
            ),
          ),
          if (search.text.isEmpty && category == 'All') ...[
            const SizedBox(height: 24),
            Reveal(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Material(
                  color: const Color(0xFFDFE8D2),
                  child: InkWell(
                    onTap: () => openPage(
                      context,
                      DetailScreen(
                        product: products.first,
                        store: widget.store,
                      ),
                    ),
                    child: LayoutBuilder(
                      builder: (context, c) {
                        final copy = Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Kicker(
                                'THE QUIET COLLECTION',
                                color: Color(0xFF435539),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Tune in.\nSwitch off.',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  height: 1.08,
                                  letterSpacing: -1,
                                  color: Color(0xFF20382E),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Flexible(
                                    child: Text(
                                      'Meet Studio',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF20382E),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF20382E),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.arrow_outward_rounded,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                        return c.maxWidth < 340 ||
                                MediaQuery.textScalerOf(context).scale(14) > 22
                            ? Column(
                                children: [
                                  copy,
                                  ProductImage(products.first, ratio: 1.6),
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(child: copy),
                                  Expanded(
                                    child: ProductImage(
                                      products.first,
                                      ratio: c.maxWidth > 600 ? 1.8 : .95,
                                    ),
                                  ),
                                ],
                              );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'Audio', 'Photography', 'Lifestyle']
                  .map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        showCheckmark: false,
                        label: Text(c),
                        selected: category == c,
                        onSelected: (_) {
                          HapticFeedback.selectionClick();
                          setState(() => category = c);
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 4,
            children: [
              Text(
                'The considered edit',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: p.ink,
                  letterSpacing: -.5,
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Sort products',
                initialValue: sort,
                onSelected: (s) => setState(() => sort = s),
                itemBuilder: (_) => [
                  'Curated',
                  'Price: low to high',
                  'Price: high to low',
                  'Top rated',
                ].map((s) => PopupMenuItem(value: s, child: Text(s))).toList(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${list.length} objects',
                        style: TextStyle(fontSize: 12, color: p.muted),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.tune_rounded, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedSize(
            duration: motion(context),
            alignment: Alignment.topCenter,
            child: AnimatedSwitcher(
              duration: motion(context, 250),
              child: list.isEmpty
                  ? EmptyState(
                      key: const ValueKey('empty-search'),
                      icon: Icons.search_off_rounded,
                      title: 'Nothing here. Yet.',
                      message:
                          'Try a different word or explore another category.',
                      action: 'Reset filters',
                      onAction: () {
                        search.clear();
                        setState(() {
                          category = 'All';
                          sort = 'Curated';
                        });
                      },
                    )
                  : ProductGrid(
                      key: ValueKey('${search.text}:$category:$sort'),
                      items: list,
                      store: widget.store,
                      heroPrefix: 'feed-${search.text}:$category:$sort',
                    ),
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'FEWER THINGS. BETTER CHOICES.',
              style: TextStyle(fontSize: 9, letterSpacing: 2, color: p.muted),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductGrid extends StatelessWidget {
  const ProductGrid({
    super.key,
    required this.items,
    required this.store,
    required this.heroPrefix,
  });
  final List<Product> items;
  final AppStore store;
  final String heroPrefix;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final largeText = MediaQuery.textScalerOf(context).scale(14) > 22;
      final cols = largeText
          ? (c.maxWidth > 750 ? 2 : 1)
          : (c.maxWidth >= 900
                ? 4
                : c.maxWidth >= 580
                ? 3
                : c.maxWidth >= 290
                ? 2
                : 1);
      final width = (c.maxWidth - 16 * (cols - 1)) / cols;
      return Wrap(
        spacing: 16,
        runSpacing: 24,
        children: items
            .map(
              (p) => SizedBox(
                width: width,
                child: ProductCard(
                  product: p,
                  store: store,
                  heroTag: '$heroPrefix-${p.id}',
                ),
              ),
            )
            .toList(),
      );
    },
  );
}

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.store,
    required this.heroTag,
  });
  final Product product;
  final AppStore store;
  final String heroTag;
  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Reveal(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Material(
                  child: InkWell(
                    onTap: () => openPage(
                      context,
                      DetailScreen(
                        product: product,
                        store: store,
                        heroTag: heroTag,
                      ),
                    ),
                    child: Hero(
                      tag: heroTag,
                      child: ProductImage(product, ratio: .9),
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: SaveButton(product: product, store: store),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => openPage(
              context,
              DetailScreen(product: product, store: store, heroTag: heroTag),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Kicker(product.category),
                  const SizedBox(height: 6),
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        product.formattedPrice,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded, size: 14, color: p.muted),
                          const SizedBox(width: 3),
                          Text(
                            '${product.rating}',
                            style: TextStyle(fontSize: 11, color: p.muted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DetailScreen extends StatefulWidget {
  const DetailScreen({
    super.key,
    required this.product,
    required this.store,
    this.heroTag,
  });
  final Product product;
  final AppStore store;
  final String? heroTag;
  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int variant = 0, quantity = 1;
  bool added = false;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.store,
    builder: (context, _) {
      final product = widget.product;
      final s = widget.store;
      final v = product.variants[variant];
      final stock = s.available(product, v);
      final p = Palette.of(context);
      final cover = ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            if (widget.heroTag != null)
              Hero(tag: widget.heroTag!, child: ProductImage(product))
            else
              ProductImage(product),
            Positioned(
              left: 20,
              top: 20,
              right: 80,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Tag(product.category, onImage: true),
              ),
            ),
            Positioned(
              right: 12,
              top: 12,
              child: SaveButton(product: product, store: s),
            ),
            const Positioned(
              left: 20,
              bottom: 20,
              right: 20,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Tag('THE EVERYDAY COLLECTION', onImage: true),
              ),
            ),
          ],
        ),
      );
      final info = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star_rounded, size: 17, color: p.ink),
              const SizedBox(width: 5),
              Text(
                '${product.rating}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'NOVA EDITOR RATING',
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 1.3,
                    color: p.muted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            product.title,
            style: TextStyle(
              fontSize: MediaQuery.textScalerOf(context).scale(1) > 1.3
                  ? 26
                  : 36,
              fontWeight: FontWeight.w700,
              height: 1.1,
              letterSpacing: -1.4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            product.subtitle,
            style: TextStyle(fontSize: 15, height: 1.5, color: p.muted),
          ),
          const SizedBox(height: 20),
          Text(
            product.formattedPrice,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w500,
              letterSpacing: -.8,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: product.tags.map((t) => Tag(t)).toList(),
          ),
          const SizedBox(height: 28),
          const Divider(),
          const SizedBox(height: 24),
          Text(
            'Finish · ${v.name}',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(product.variants.length, (i) {
              final item = product.variants[i];
              return ChoiceChip(
                showCheckmark: false,
                avatar: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: item.color,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF8B9184)),
                  ),
                ),
                label: Text(item.name),
                selected: variant == i,
                onSelected: (_) {
                  HapticFeedback.selectionClick();
                  setState(() {
                    variant = i;
                    quantity = 1;
                    added = false;
                  });
                },
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            'Product photo shows the signature finish.',
            style: TextStyle(fontSize: 11, color: p.muted),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 20,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              QuantityControl(
                value: quantity,
                max: stock,
                onChanged: (q) => setState(() {
                  quantity = q;
                  added = false;
                }),
              ),
              Text(
                stock > 0 ? '$stock available' : 'Currently sold out',
                style: TextStyle(fontSize: 12, color: p.muted),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const Text(
            'Made for your everyday.',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            product.description,
            style: TextStyle(height: 1.7, fontSize: 14, color: p.muted),
          ),
          const SizedBox(height: 24),
          SurfaceCard(
            child: Column(
              children: product.specs.entries
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              e.key,
                              style: TextStyle(fontSize: 12, color: p.muted),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              e.value,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: const Text('Back to collection'),
          ),
        ],
      );
      return Scaffold(
        appBar: AppBar(
          title: const Kicker('A closer look'),
          actions: [
            IconButton(
              tooltip: 'Open shopping bag',
              onPressed: () => openPage(context, BagScreen(store: s)),
              icon: Badge(
                isLabelVisible: s.cartCount > 0,
                label: Text('${s.cartCount}'),
                child: const Icon(Icons.shopping_bag_outlined),
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
        body: PageBody(
          child: LayoutBuilder(
            builder: (context, c) => c.maxWidth >= 760
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: cover),
                      const SizedBox(width: 40),
                      Expanded(child: info),
                    ],
                  )
                : Column(
                    children: [
                      cover,
                      const SizedBox(height: 28),
                      Reveal(child: info),
                    ],
                  ),
          ),
        ),
        bottomNavigationBar: StickyAction(
          child: AnimatedSwitcher(
            duration: motion(context),
            child: PrimaryAction(
              added
                  ? 'Added to your bag'
                  : 'Add to Cart · ${money(product.priceCents * quantity)}',
              key: ValueKey(added),
              icon: added ? Icons.check_rounded : Icons.add_rounded,
              onPressed: stock < quantity
                  ? null
                  : () {
                      if (s.add(product, v, quantity)) {
                        HapticFeedback.mediumImpact();
                        setState(() => added = true);
                        feedback(
                          context,
                          '${product.title} · ${v.name} added to your bag',
                        );
                      } else {
                        feedback(
                          context,
                          'Your bag already contains the available stock.',
                        );
                      }
                    },
            ),
          ),
        ),
      );
    },
  );
}

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({
    super.key,
    required this.store,
    required this.onExplore,
  });
  final AppStore store;
  final VoidCallback onExplore;
  @override
  Widget build(BuildContext context) {
    final saved = products
        .where((p) => store.favorites.contains(p.id))
        .toList();
    return PageBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Kicker('Your personal edit'),
          const SizedBox(height: 12),
          PageHeading(
            'Worth keeping.',
            '${saved.length} considered ${saved.length == 1 ? 'choice' : 'choices'}. All in one place.',
          ),
          const SizedBox(height: 32),
          AnimatedSwitcher(
            duration: motion(context),
            child: saved.isEmpty
                ? EmptyState(
                    key: const ValueKey('no-favorites'),
                    icon: Icons.bookmark_border_rounded,
                    title: 'A little inspiration?',
                    message: 'Tap the bookmark on anything you love. We’ll keep it here for you.',
                    action: 'Explore the collection',
                    onAction: onExplore,
                  )
                : ProductGrid(
                    key: const ValueKey('favorites'),
                    items: saved,
                    store: store,
                    heroPrefix: 'favorites',
                  ),
          ),
        ],
      ),
    );
  }
}

// 06 — Bag, demo checkout and local order history
class BagScreen extends StatelessWidget {
  const BagScreen({super.key, required this.store});
  final AppStore store;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: store,
    builder: (context, _) => Scaffold(
      appBar: AppBar(title: const Kicker('Your collection, coming together')),
      body: PageBody(
        maxWidth: 760,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeading(
              'In the bag.',
              '${store.cartCount} ${store.cartCount == 1 ? 'good choice' : 'good choices'}. A little everyday upgrade.',
            ),
            const SizedBox(height: 32),
            if (store.cart.isEmpty)
              EmptyState(
                icon: Icons.shopping_bag_outlined,
                title: 'Room for something good.',
                message: 'Explore the edit and find an object you’ll love living with.',
                action: 'Keep exploring',
                onAction: () => Navigator.pop(context),
              )
            else ...[
              ...store.cart.values.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: CartLine(item: item, store: store),
                ),
              ),
              const SizedBox(height: 8),
              SurfaceCard(
                child: Column(
                  children: [
                    SummaryLine('Subtotal', money(store.subtotal)),
                    const SizedBox(height: 16),
                    const SummaryLine('Campus pickup', 'Free'),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 20),
                    SummaryLine('Total', money(store.subtotal), strong: true),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'This is a student store demo. No payment is collected and no products are shipped.',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.6,
                  color: Palette.of(context).muted,
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: store.cart.isEmpty
          ? null
          : StickyAction(
              child: PrimaryAction(
                'Continue to demo checkout',
                onPressed: () =>
                    openPage(context, CheckoutScreen(store: store)),
              ),
            ),
    ),
  );
}

class CartLine extends StatelessWidget {
  const CartLine({super.key, required this.item, required this.store});
  final CartItem item;
  final AppStore store;
  @override
  Widget build(BuildContext context) => SurfaceCard(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 72,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: ProductImage(item.product),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.variant.name,
                    style: TextStyle(
                      fontSize: 12,
                      color: Palette.of(context).muted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    money(item.product.priceCents * item.quantity),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            QuantityControl(
              value: item.quantity,
              max: store.available(item.product, item.variant),
              onChanged: (q) => store.changeQuantity(item, q),
            ),
            TextButton.icon(
              onPressed: () {
                store.changeQuantity(item, 0);
                feedback(context, '${item.product.title} removed');
              },
              icon: const Icon(Icons.close_rounded, size: 16),
              label: const Text('Remove'),
            ),
          ],
        ),
      ],
    ),
  );
}

class SummaryLine extends StatelessWidget {
  const SummaryLine(this.label, this.value, {super.key, this.strong = false});
  final String label, value;
  final bool strong;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Text(
          label,
          style: TextStyle(
            fontSize: strong ? 18 : 13,
            fontWeight: strong ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
      const SizedBox(width: 16),
      Flexible(
        child: Text(
          value,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: strong ? 22 : 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ],
  );
}

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, required this.store});
  final AppStore store;
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final form = GlobalKey<FormState>();
  late final name = TextEditingController(
    text: widget.store.profile?.name ?? '',
  );
  late final email = TextEditingController(
    text: widget.store.profile?.email ?? '',
  );
  bool busy = false;
  @override
  void dispose() {
    name.dispose();
    email.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!form.currentState!.validate() || busy) return;
    FocusScope.of(context).unfocus();
    setState(() => busy = true);
    try {
      final order = widget.store.placeOrder(name.text.trim());
      await widget.store.flush();
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) => ReceiptScreen(
            order: order,
            storageError: widget.store.storageError,
          ),
        ),
      );
    } on StateError catch (e) {
      if (mounted) {
        setState(() => busy = false);
        feedback(context, e.message.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Kicker('One last detail')),
    body: PageBody(
      maxWidth: 600,
      child: Form(
        key: form,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeading(
              'Almost yours.',
              'A simple checkout, just for the demo.',
            ),
            const SizedBox(height: 28),
            SurfaceCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.school_outlined),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Campus pickup',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Demo pickup point · no real delivery\nFree · no payment required',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.6,
                            color: Palette.of(context).muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            TextFormField(
              key: const Key('checkout-name'),
              controller: name,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Full name'),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Please enter your name.'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('checkout-email'),
              controller: email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: validateEmail,
              onFieldSubmitted: (_) => submit(),
            ),
            const SizedBox(height: 28),
            SurfaceCard(
              child: Column(
                children: [
                  ...widget.store.cart.values.map(
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: SummaryLine(
                        '${i.product.title} × ${i.quantity}',
                        money(i.product.priceCents * i.quantity),
                      ),
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 20),
                  SummaryLine(
                    'Demo total',
                    money(widget.store.subtotal),
                    strong: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Placing this demo order saves a receipt on this device. No charge, email or shipment will be made.',
              style: TextStyle(
                fontSize: 12,
                height: 1.6,
                color: Palette.of(context).muted,
              ),
            ),
          ],
        ),
      ),
    ),
    bottomNavigationBar: StickyAction(
      child: PrimaryAction(
        busy ? 'Saving your order…' : 'Place demo order',
        onPressed: busy ? null : submit,
        icon: Icons.check_rounded,
      ),
    ),
  );
}

class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({super.key, required this.order, this.storageError});
  final DemoOrder order;
  final String? storageError;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Kicker('A considered choice')),
    body: PageBody(
      maxWidth: 600,
      child: Reveal(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: .65, end: 1),
              duration: motion(context, 650),
              curve: Curves.easeOutBack,
              builder: (_, v, child) => Transform.scale(scale: v, child: child),
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: Palette.of(context).tint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, size: 36),
              ),
            ),
            const SizedBox(height: 28),
            PageHeading(
              'Good choice,\n${order.contactName.split(' ').first}.',
              'Your demo order is ready to revisit. Thanks for exploring NOVA.',
            ),
            const SizedBox(height: 28),
            const Tag('DEMO ORDER · NO PAYMENT'),
            const SizedBox(height: 20),
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Kicker(shortDate(order.created)),
                  const SizedBox(height: 8),
                  SelectableText(
                    order.id,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...order.items.map(
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              i.image,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  i.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${i.finish} · Qty ${i.quantity}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Palette.of(context).muted,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  money(i.unitPrice * i.quantity),
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 20),
                  SummaryLine('Total', money(order.total), strong: true),
                ],
              ),
            ),
            if (storageError != null) ...[
              const SizedBox(height: 16),
              Text(storageError!),
            ],
            const SizedBox(height: 24),
            Text(
              'Saved locally in Profile / My orders.',
              style: TextStyle(fontSize: 12, color: Palette.of(context).muted),
            ),
          ],
        ),
      ),
    ),
    bottomNavigationBar: StickyAction(
      child: PrimaryAction(
        'Back to NOVA',
        onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
      ),
    ),
  );
}

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key, required this.store});
  final AppStore store;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Kicker('Your NOVA story')),
    body: PageBody(
      maxWidth: 760,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeading(
            'Good choices,\nall together.',
            'Your demo orders, saved on this device.',
          ),
          const SizedBox(height: 32),
          if (store.orders.isEmpty)
            EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'A fresh start.',
              message: 'Your first demo order will appear here.',
              action: 'Back to profile',
              onAction: () => Navigator.pop(context),
            )
          else
            ...store.orders.map(
              (o) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Kicker(shortDate(o.created)),
                      const SizedBox(height: 12),
                      Text(
                        o.items.map((i) => i.title).join(' + '),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SummaryLine('Demo order', money(o.total)),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () =>
                            openPage(context, ReceiptScreen(order: o)),
                        child: const Text('View receipt'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

// 07 — Profile and Lab 6 registration
String? validateEmail(String? value) {
  final v = value?.trim() ?? '';
  return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)
      ? null
      : 'Enter a valid email, e.g. name@narxoz.kz.';
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.store});
  final AppStore store;
  Future<void> register(BuildContext context) async {
    final profile = await openPage<UserProfile>(
      context,
      RegistrationScreen(initial: store.profile),
    );
    if (profile != null) {
      store.setProfile(profile);
      if (context.mounted) {
        feedback(context, 'Your profile is ready. Welcome to NOVA.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final user = store.profile;
    return PageBody(
      maxWidth: 760,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Kicker('A space of your own'),
          const SizedBox(height: 12),
          PageHeading(
            user == null
                ? 'Hello, you.'
                : 'Hello, ${user.name.split(' ').first}.',
            'Your style. Your settings. Your NOVA.',
          ),
          const SizedBox(height: 28),
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: p.tint,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Center(
                        child: user == null
                            ? const Icon(Icons.person_outline_rounded, size: 28)
                            : Text(
                                user.name.characters.first.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Make yourself at home',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              letterSpacing: -.4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            user?.email ?? 'Create your local profile to keep things personal.',
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.5,
                              color: p.muted,
                            ),
                          ),
                          if (user != null) ...[
                            const SizedBox(height: 8),
                            Tag(user.role),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                PrimaryAction(
                  user == null ? 'Create your profile' : 'Update your profile',
                  onPressed: () => register(context),
                  icon: Icons.arrow_outward_rounded,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Kicker('Your collection'),
          const SizedBox(height: 12),
          SurfaceCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
              leading: const Icon(Icons.receipt_long_outlined),
              title: const Text(
                'My orders',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                '${store.orders.length} demo orders',
                style: TextStyle(fontSize: 12, color: p.muted),
              ),
              trailing: const Icon(Icons.arrow_forward_rounded, size: 20),
              onTap: () => openPage(context, OrdersScreen(store: store)),
            ),
          ),
          const SizedBox(height: 28),
          const Kicker('Make it feel like you'),
          const SizedBox(height: 12),
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Appearance',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  'A different mood. The same NOVA.',
                  style: TextStyle(fontSize: 12, color: p.muted),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ThemeMode.values
                      .map(
                        (m) => ChoiceChip(
                          showCheckmark: false,
                          avatar: Icon(
                            m == ThemeMode.system
                                ? Icons.brightness_auto_outlined
                                : m == ThemeMode.light
                                ? Icons.light_mode_outlined
                                : Icons.dark_mode_outlined,
                            size: 17,
                          ),
                          label: Text(
                            m == ThemeMode.system
                                ? 'System'
                                : m == ThemeMode.light
                                ? 'Light'
                                : 'Dark',
                          ),
                          selected: store.themeMode == m,
                          onSelected: (_) => store.setTheme(m),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'NOVA is a student project. Profiles and orders are stored only on this device. Registration demonstrates validation; it does not create an online account.',
            style: TextStyle(fontSize: 12, height: 1.6, color: p.muted),
          ),
          if (store.storageError != null) ...[
            const SizedBox(height: 16),
            Text(store.storageError!),
            TextButton(
              onPressed: store.retrySave,
              child: const Text('Retry saving'),
            ),
          ],
          const SizedBox(height: 32),
          const Center(child: Kicker('NOVA · Everyday, elevated.')),
        ],
      ),
    );
  }
}

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key, this.initial});
  final UserProfile? initial;
  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final form = GlobalKey<FormState>();
  late final name = TextEditingController(text: widget.initial?.name ?? '');
  late final email = TextEditingController(text: widget.initial?.email ?? '');
  final password = TextEditingController(), confirm = TextEditingController();
  final confirmKey = GlobalKey<FormFieldState<String>>();
  late String role = widget.initial?.role ?? 'Student';
  bool accepted = false,
      showPassword = false,
      showConfirm = false,
      submitted = false;
  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    confirm.dispose();
    super.dispose();
  }

  void submit() {
    setState(() => submitted = true);
    final valid = form.currentState!.validate();
    if (!valid || !accepted) return;
    FocusScope.of(context).unfocus();
    final user = UserProfile(name.text.trim(), email.text.trim(), role);
    debugPrint(
      'NOVA registration: name=${user.name}, email=${user.email}, role=$role, password=[REDACTED]',
    );
    Navigator.pop(context, user);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Kicker('Your everyday, personalized')),
    body: PageBody(
      maxWidth: 600,
      child: Form(
        key: form,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Reveal(
              child: PageHeading(
                'A little more\nyou.',
                'Set up your profile and make NOVA your own.',
              ),
            ),
            const SizedBox(height: 28),
            TextFormField(
              key: const Key('full-name'),
              controller: name,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              decoration: const InputDecoration(
                labelText: 'Full name',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Your full name is required.'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('email'),
              controller: email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.alternate_email_rounded),
              ),
              validator: validateEmail,
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('password'),
              controller: password,
              obscureText: !showPassword,
              enableSuggestions: false,
              autocorrect: false,
              textInputAction: TextInputAction.next,
              onChanged: (_) {
                if (confirm.text.isNotEmpty) {
                  confirmKey.currentState?.validate();
                }
              },
              decoration: InputDecoration(
                labelText: 'Password',
                helperText: 'At least 6 characters',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  tooltip: showPassword ? 'Hide password' : 'Show password',
                  onPressed: () => setState(() => showPassword = !showPassword),
                  icon: Icon(
                    showPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
              ),
              validator: (v) => v == null || v.length < 6
                  ? 'Use at least 6 characters.'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: confirmKey,
              controller: confirm,
              obscureText: !showConfirm,
              enableSuggestions: false,
              autocorrect: false,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => submit(),
              decoration: InputDecoration(
                labelText: 'Confirm password',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  tooltip: showConfirm
                      ? 'Hide confirmation'
                      : 'Show confirmation',
                  onPressed: () => setState(() => showConfirm = !showConfirm),
                  icon: Icon(
                    showConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
              ),
              validator: (v) => v == null || v.isEmpty
                  ? 'Please confirm your password.'
                  : v != password.text
                  ? 'Passwords must match exactly.'
                  : null,
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              initialValue: role,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Your role'),
              items: [
                'Student',
                'Teacher',
                'Developer',
              ].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (v) => setState(() => role = v!),
            ),
            const SizedBox(height: 20),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: accepted,
              onChanged: (v) => setState(() => accepted = v ?? false),
              title: const Text(
                'I accept the Terms and Conditions',
                style: TextStyle(fontSize: 13),
              ),
              subtitle: Text(
                'Demo profile only. Passwords are validated but never stored.',
                style: TextStyle(
                  fontSize: 11,
                  height: 1.5,
                  color: Palette.of(context).muted,
                ),
              ),
            ),
            if (submitted && !accepted)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Please accept the Terms and Conditions.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            PrimaryAction(
              widget.initial == null ? 'Create profile' : 'Save profile',
              onPressed: submit,
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Maybe later'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class ComponentGallery extends StatelessWidget {
  const ComponentGallery({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('NOVA · Design system')),
    body: PageBody(
      maxWidth: 760,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeading(
            'Considered\nby design.',
            '8pt rhythm. Warm neutrals. A quiet confidence.',
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children:
                [
                      Palette.of(context).canvas,
                      Palette.of(context).surface,
                      Palette.of(context).ink,
                      Palette.of(context).muted,
                      Palette.of(context).tint,
                    ]
                    .map(
                      (c) => Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: c,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Palette.of(context).line),
                        ),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 24),
          PrimaryAction('Primary action', onPressed: () {}),
          const SizedBox(height: 12),
          const PrimaryAction('Unavailable', onPressed: null),
          const SizedBox(height: 24),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [Tag('Wireless'), Tag('Considered design')],
          ),
          const SizedBox(height: 24),
          const SurfaceCard(
            child: SummaryLine('Everyday essentials', '\$249', strong: true),
          ),
        ],
      ),
    ),
  );
}

class PressScale extends StatefulWidget {
  const PressScale({super.key, required this.child});
  final Widget child;
  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool pressed = false;
  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: (_) => setState(() => pressed = true),
    onPointerUp: (_) => setState(() => pressed = false),
    onPointerCancel: (_) => setState(() => pressed = false),
    child: AnimatedScale(
      scale: pressed ? .975 : 1,
      duration: motion(context, 130),
      curve: Curves.easeOut,
      child: widget.child,
    ),
  );
}
