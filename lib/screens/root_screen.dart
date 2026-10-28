import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../core/navigation.dart';
import '../state/app_store.dart';
import '../widgets/components.dart';
import '../widgets/motion.dart';

import 'package:flutter/services.dart';

import 'feed_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import 'bag_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({
    super.key,
    required this.store,
    this.initialGridMode = false,
  });
  final AppStore store;
  final bool initialGridMode;
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
  late bool gridMode = widget.initialGridMode;
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
        titleSpacing: 16,
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
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        actions: [
          if (tab == 0)
            IconButton(
              key: const ValueKey('catalog-view-toggle'),
              tooltip: gridMode ? 'Show list' : 'Show grid',
              onPressed: () {
                HapticFeedback.selectionClick();
                setState(() => gridMode = !gridMode);
              },
              icon: AnimatedSwitcher(
                duration: motion(context, 200),
                child: Icon(
                  gridMode ? Icons.view_list_rounded : Icons.grid_view_rounded,
                  key: ValueKey(gridMode),
                ),
              ),
            ),
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
                    child: FeedScreen(store: s, gridMode: gridMode),
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
