import 'product.dart';
import '../data/catalog.dart';

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
