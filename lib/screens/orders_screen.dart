import '../widgets/summary_line.dart';

import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/navigation.dart';
import '../state/app_store.dart';
import '../widgets/components.dart';
import 'receipt_screen.dart';

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
