import '../widgets/summary_line.dart';

import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../core/format.dart';
import '../models/commerce.dart';
import '../widgets/components.dart';
import '../widgets/motion.dart';

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
