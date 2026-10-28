import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme.dart';
import '../state/app_store.dart';
import '../models/product.dart';
import 'motion.dart';

class PageBody extends StatelessWidget {
  const PageBody({
    super.key,
    required this.child,
    this.maxWidth = 1120,
    this.controller,
  });
  final Widget child;
  final double maxWidth;
  final ScrollController? controller;
  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: SingleChildScrollView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: SizedBox(width: double.infinity, child: child),
        ),
      ),
    ),
  );
}

class Kicker extends StatelessWidget {
  const Kicker(this.text, {super.key, this.color});
  final String text;
  final Color? color;
  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.8,
      color: color ?? Palette.of(context).muted,
    ),
  );
}

class PageHeading extends StatelessWidget {
  const PageHeading(this.title, this.subtitle, {super.key});
  final String title, subtitle;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: TextStyle(
          fontSize: MediaQuery.textScalerOf(context).scale(1) > 1.3 ? 26 : 36,
          height: 1.12,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.3,
        ),
      ),
      const SizedBox(height: 12),
      Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          height: 1.6,
          color: Palette.of(context).muted,
        ),
      ),
    ],
  );
}

class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });
  final Widget child;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      color: p.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: p.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(padding: padding, child: child),
    );
  }
}

class Tag extends StatelessWidget {
  const Tag(this.text, {super.key, this.onImage = false});
  final String text;
  final bool onImage;
  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: onImage ? const Color(0xFFF6F7F1) : p.tint,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: onImage ? Palette.light.ink : p.ink,
        ),
      ),
    );
  }
}

class ProductImage extends StatelessWidget {
  const ProductImage(this.product, {super.key, this.ratio = 1});
  final Product product;
  final double ratio;
  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: ratio,
    child: Image.asset(
      product.image,
      fit: BoxFit.cover,
      semanticLabel: product.title,
      errorBuilder: (_, error, stack) => ColoredBox(
        color: Palette.of(context).tint,
        child: Center(
          child: Icon(
            Icons.image_outlined,
            size: 48,
            color: Palette.of(context).muted,
          ),
        ),
      ),
    ),
  );
}

class SaveButton extends StatelessWidget {
  const SaveButton({super.key, required this.product, required this.store});
  final Product product;
  final AppStore store;
  @override
  Widget build(BuildContext context) {
    final saved = store.favorites.contains(product.id);
    return Material(
      color: const Color(0xFFF6F7F1),
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: '${saved ? 'Unsave' : 'Save'} ${product.title}',
        isSelected: saved,
        onPressed: () {
          store.toggleFavorite(product.id);
          HapticFeedback.selectionClick();
        },
        icon: AnimatedSwitcher(
          duration: motion(context, 220),
          transitionBuilder: (child, animation) => ScaleTransition(
            scale: animation,
            child: FadeTransition(opacity: animation, child: child),
          ),
          child: Icon(
            saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            key: ValueKey(saved),
            color: Palette.light.ink,
            size: 21,
          ),
        ),
      ),
    );
  }
}

class PrimaryAction extends StatelessWidget {
  const PrimaryAction(
    this.label, {
    super.key,
    required this.onPressed,
    this.icon = Icons.arrow_forward_rounded,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData icon;
  @override
  Widget build(BuildContext context) => PressScale(
    child: FilledButton(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(child: Text(label, textAlign: TextAlign.center)),
          const SizedBox(width: 12),
          Icon(icon, size: 19),
        ],
      ),
    ),
  );
}

class StickyAction extends StatelessWidget {
  const StickyAction({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Container(
      decoration: BoxDecoration(
        color: p.canvas,
        border: Border(top: BorderSide(color: p.line)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Row(children: [Expanded(child: child)]),
            ),
          ),
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.action,
    required this.onAction,
  });
  final IconData icon;
  final String title, message, action;
  final VoidCallback onAction;
  @override
  Widget build(BuildContext context) => SurfaceCard(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Palette.of(context).tint,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 32),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: -.6,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: Palette.of(context).muted, height: 1.6),
        ),
        const SizedBox(height: 24),
        PrimaryAction(action, onPressed: onAction),
      ],
    ),
  );
}

class QuantityControl extends StatelessWidget {
  const QuantityControl({
    super.key,
    required this.value,
    required this.max,
    required this.onChanged,
    this.allowZero = false,
  });
  final int value, max;
  final ValueChanged<int> onChanged;
  final bool allowZero;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Palette.of(context).surface,
      border: Border.all(color: Palette.of(context).line),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Decrease quantity',
          onPressed: value > (allowZero ? 0 : 1)
              ? () => onChanged(value - 1)
              : null,
          icon: const Icon(Icons.remove_rounded, size: 18),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Semantics(
            label: 'Quantity $value',
            child: Text(
              '$value',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
        IconButton(
          tooltip: 'Increase quantity',
          onPressed: value < max ? () => onChanged(value + 1) : null,
          icon: const Icon(Icons.add_rounded, size: 18),
        ),
      ],
    ),
  );
}

class NovaMark extends StatelessWidget {
  const NovaMark({super.key, this.size = 28});
  final double size;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: CustomPaint(painter: MarkPainter(Palette.of(context).ink)),
  );
}

class MarkPainter extends CustomPainter {
  MarkPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = size.width * .15
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(
      Path()
        ..moveTo(size.width * .17, size.height * .85)
        ..lineTo(size.width * .17, size.height * .15)
        ..lineTo(size.width * .83, size.height * .85)
        ..lineTo(size.width * .83, size.height * .15),
      p,
    );
  }

  @override
  bool shouldRepaint(MarkPainter oldDelegate) => oldDelegate.color != color;
}
