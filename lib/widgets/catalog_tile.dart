import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../core/navigation.dart';
import '../core/theme.dart';
import '../models/product.dart';
import '../screens/detail_screen.dart';
import '../state/app_store.dart';
import 'components.dart';

/// Both catalog modes share their content, navigation and accessibility actions.
class CatalogTile extends StatelessWidget {
  const CatalogTile({
    super.key,
    required this.product,
    required this.store,
    required this.grid,
    required this.onDelete,
  });
  final Product product;
  final AppStore store;
  final bool grid;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final hero = 'catalog-${product.id}';
    final title = Text(
      product.title,
      maxLines: grid ? 2 : null,
      overflow: grid ? TextOverflow.ellipsis : null,
      style: TextStyle(
        fontSize: grid && MediaQuery.textScalerOf(context).scale(14) > 21
            ? 13
            : 15,
        height: 1.2,
        fontWeight: FontWeight.w700,
      ),
    );
    final category = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: p.tint,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        product.category,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11,
          height: 1.2,
          fontWeight: FontWeight.w500,
          color: p.ink,
        ),
      ),
    );
    final price = Wrap(
      spacing: 12,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          product.formattedPrice,
          style: const TextStyle(
            fontSize: 15,
            height: 1.2,
            fontWeight: FontWeight.w700,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, size: 16, color: Color(0xFF99712D)),
            const SizedBox(width: 3),
            Text(
              '${product.rating}',
              style: TextStyle(fontSize: 12, color: p.muted),
            ),
          ],
        ),
      ],
    );
    final image = Hero(
      tag: hero,
      child: ProductImage(product, ratio: grid ? 1.15 : .85),
    );
    return Semantics(
      customSemanticsActions: {
        const CustomSemanticsAction(label: 'Delete product'): onDelete,
      },
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: p.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: p.line),
        ),
        child: InkWell(
          onTap: () => openPage(
            context,
            DetailScreen(product: product, store: store, heroTag: hero),
          ),
          child: grid
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        image,
                        Positioned(
                          top: 6,
                          right: 6,
                          child: SaveButton(product: product, store: store),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            category,
                            const SizedBox(height: 8),
                            title,
                            const Spacer(),
                            price,
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.all(12),
                  child: LayoutBuilder(
                    builder: (context, bounds) => Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: bounds.maxWidth < 300 ? 72 : 104,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: image,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              category,
                              const SizedBox(height: 8),
                              title,
                              const SizedBox(height: 12),
                              price,
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
