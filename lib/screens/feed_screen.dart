import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme.dart';
import '../data/catalog.dart';
import '../models/product.dart';
import '../state/app_store.dart';
import '../widgets/catalog_tile.dart';
import '../widgets/components.dart';

/// One mutable collection, two lazy view modes. State survives tab switches.
class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key, required this.store, this.gridMode = false});
  final AppStore store;
  final bool gridMode;

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final search = TextEditingController();
  final listScroll = ScrollController();
  final gridScroll = ScrollController();
  String category = 'All', sort = 'Curated';
  bool refreshing = false;
  int resetGeneration = 0;

  @override
  void dispose() {
    search.dispose();
    listScroll.dispose();
    gridScroll.dispose();
    super.dispose();
  }

  Future<void> refresh() async {
    if (refreshing) return;
    setState(() => refreshing = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() {
      widget.store.catalog.insert(
        0,
        arrivalProduct(++widget.store.arrivalSerial),
      );
      // Show the arrival at index zero, even if refresh began with a filter.
      search.clear();
      category = 'All';
      sort = 'Curated';
      refreshing = false;
    });
    widget.store.saveCatalog();
    for (final controller in [listScroll, gridScroll]) {
      if (controller.hasClients) controller.jumpTo(0);
    }
    HapticFeedback.lightImpact();
  }

  void remove(Product product) {
    final originalIndex = widget.store.catalog.indexWhere(
      (p) => p.id == product.id,
    );
    if (originalIndex < 0) return;
    final generation = resetGeneration;
    setState(() => widget.store.catalog.removeAt(originalIndex));
    widget.store.saveCatalog();
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 6),
          content: Text('${product.title} removed'),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () {
              if (!mounted ||
                  generation != resetGeneration ||
                  widget.store.catalog.any((p) => p.id == product.id)) {
                return;
              }
              setState(() {
                final index = originalIndex.clamp(
                  0,
                  widget.store.catalog.length,
                );
                widget.store.catalog.insert(index, product);
              });
              widget.store.saveCatalog();
            },
          ),
        ),
      );
  }

  void resetFilters() {
    search.clear();
    setState(() {
      category = 'All';
      sort = 'Curated';
    });
  }

  void restoreSeeds() {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    setState(() {
      resetGeneration++;
      widget.store.catalog
        ..clear()
        ..addAll(products);
      search.clear();
      category = 'All';
      sort = 'Curated';
    });
    widget.store.saveCatalog();
  }

  Widget dismissible(Product product) => Dismissible(
    key: ValueKey(product.id),
    direction: DismissDirection.endToStart,
    background: Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFB3261E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(
        Icons.delete,
        color: Colors.white,
        semanticLabel: 'Delete',
      ),
    ),
    onDismissed: (_) => remove(product),
    child: CatalogTile(
      product: product,
      store: widget.store,
      grid: widget.gridMode,
      onDelete: () => remove(product),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final items = filterProducts(
      source: widget.store.catalog,
      query: search.text,
      category: category,
      sort: sort,
    );
    final palette = Palette.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final largeText = MediaQuery.textScalerOf(context).scale(14) > 21;
        final compact = constraints.maxHeight < 480 || largeText;
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!compact) ...[
                        const Kicker('THE EVERYDAY COLLECTION'),
                        const SizedBox(height: 8),
                        const Text(
                          'Find your next favorite.',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -.8,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextField(
                        controller: search,
                        onChanged: (_) => setState(() {}),
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: 'Search the collection',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: search.text.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: 'Clear search',
                                  onPressed: resetFilters,
                                  icon: const Icon(Icons.close_rounded),
                                ),
                        ),
                      ),
                      if (!compact) ...[
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children:
                                ['All', 'Audio', 'Photography', 'Lifestyle']
                                    .map(
                                      (value) => Padding(
                                        padding: const EdgeInsets.only(
                                          right: 8,
                                        ),
                                        child: ChoiceChip(
                                          showCheckmark: false,
                                          label: Text(value),
                                          selected: category == value,
                                          onSelected: (_) =>
                                              setState(() => category = value),
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
                      ],
                      if (constraints.maxHeight > 260)
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                refreshing
                                    ? 'Finding something new…'
                                    : '${items.length} objects · Swipe left to remove',
                                maxLines: 2,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: palette.muted,
                                ),
                              ),
                            ),
                            PopupMenuButton<String>(
                              tooltip: 'Sort products',
                              initialValue: sort,
                              onSelected: (value) =>
                                  setState(() => sort = value),
                              itemBuilder: (_) =>
                                  [
                                        'Curated',
                                        'Price: low to high',
                                        'Price: high to low',
                                        'Top rated',
                                      ]
                                      .map(
                                        (value) => PopupMenuItem(
                                          value: value,
                                          child: Text(value),
                                        ),
                                      )
                                      .toList(),
                              icon: const Icon(Icons.tune_rounded, size: 20),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    key: const ValueKey('catalog-refresh'),
                    onRefresh: refresh,
                    child: items.isEmpty
                        ? ListView(
                            key: const ValueKey('catalog-empty-scroll'),
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            children: [
                              EmptyState(
                                icon: widget.store.catalog.isEmpty
                                    ? Icons.inventory_2_outlined
                                    : Icons.search_off_rounded,
                                title: widget.store.catalog.isEmpty
                                    ? 'Catalog is Empty'
                                    : 'No matching objects',
                                message: widget.store.catalog.isEmpty
                                    ? 'A fresh start. Restore the collection or pull down to discover something new.'
                                    : 'Try another search or reset your filters.',
                                action: widget.store.catalog.isEmpty
                                    ? 'Restore catalog'
                                    : 'Reset filters',
                                onAction: widget.store.catalog.isEmpty
                                    ? restoreSeeds
                                    : resetFilters,
                              ),
                            ],
                          )
                        : widget.gridMode
                        ? LayoutBuilder(
                            builder: (context, bounds) {
                              final cellWidth = (bounds.maxWidth - 44) / 2;
                              final scale =
                                  MediaQuery.textScalerOf(context).scale(14) /
                                  14;
                              final cellHeight =
                                  cellWidth / 1.15 + 48 + 105 * scale;
                              return GridView.builder(
                                key: const PageStorageKey('catalog-grid'),
                                controller: gridScroll,
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  24,
                                ),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      childAspectRatio: cellWidth / cellHeight,
                                    ),
                                itemCount: items.length,
                                itemBuilder: (_, index) =>
                                    dismissible(items[index]),
                              );
                            },
                          )
                        : ListView.separated(
                            key: const PageStorageKey('catalog-list'),
                            controller: listScroll,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            itemCount: items.length,
                            separatorBuilder: (_, index) => Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 16,
                              ),
                              child: Divider(color: palette.line, height: 1),
                            ),
                            itemBuilder: (_, index) =>
                                dismissible(items[index]),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
