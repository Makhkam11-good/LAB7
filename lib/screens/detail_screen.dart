import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../core/format.dart';
import '../core/navigation.dart';
import '../models/product.dart';
import '../state/app_store.dart';
import '../widgets/components.dart';
import '../widgets/motion.dart';

import 'package:flutter/services.dart';

import 'bag_screen.dart';

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
            'Illustrative photograph. Finish and specifications are demo data.',
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
