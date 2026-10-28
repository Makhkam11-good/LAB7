import '../widgets/summary_line.dart';

import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../core/format.dart';
import '../core/navigation.dart';
import '../models/commerce.dart';
import '../state/app_store.dart';
import '../widgets/components.dart';
import 'checkout_screen.dart';

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
