import 'package:flutter/material.dart';

import '../core/format.dart';

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
    this.addedOrder = 0,
  });
  final String id, title, subtitle, description, image, category;
  final int priceCents;

  /// Monotonic catalog publication order; larger values are newer.
  final int addedOrder;
  final double rating;
  final List<String> tags;
  final List<ProductVariant> variants;
  final Map<String, String> specs;
  String get formattedPrice => money(priceCents);
}
