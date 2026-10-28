import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../core/navigation.dart';
import '../models/product.dart';
import '../state/app_store.dart';
import '../widgets/components.dart';
import '../widgets/motion.dart';
import '../screens/detail_screen.dart';

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
