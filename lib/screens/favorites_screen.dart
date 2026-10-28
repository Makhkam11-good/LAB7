import 'package:flutter/material.dart';

import '../data/catalog.dart';
import '../state/app_store.dart';
import '../widgets/components.dart';
import '../widgets/motion.dart';
import '../widgets/product_card.dart';

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
    final saved = store.favorites.map(productById).toList();
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
