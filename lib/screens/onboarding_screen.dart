import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/catalog.dart';
import '../state/app_store.dart';
import '../widgets/components.dart';
import '../widgets/motion.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.store});
  final AppStore store;
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int step = 0;
  static const titles = [
    'Less, but\nbetter.',
    'Find your\neveryday icons.',
    'Make it\nyours.',
  ];
  static const copy = [
    'Thoughtfully chosen objects. A little more intention in every day.',
    'Save what speaks to you. Explore the details. Build a collection at your own pace.',
    'Your favorites, bag and profile stay on this device. Welcome to a more considered kind of shopping.',
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'NOVA',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 4,
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.store.completeOnboarding,
          child: const Text('Skip'),
        ),
        const SizedBox(width: 12),
      ],
    ),
    body: PageBody(
      maxWidth: 560,
      child: AnimatedSwitcher(
        duration: motion(context, 450),
        child: Column(
          key: ValueKey(step),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Stack(
                children: [
                  ProductImage(
                    products[step == 0
                        ? 0
                        : step == 1
                        ? 3
                        : 1],
                    ratio: 1.18,
                  ),
                  Positioned(
                    left: 20,
                    top: 20,
                    child: Tag('THE NOVA EDIT · 0${step + 1}', onImage: true),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            PageHeading(titles[step], copy[step]),
            const SizedBox(height: 24),
            Row(
              children: List.generate(
                3,
                (i) => AnimatedContainer(
                  duration: motion(context),
                  width: i == step ? 32 : 8,
                  height: 5,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: i == step
                        ? Palette.of(context).ink
                        : Palette.of(context).line,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    bottomNavigationBar: StickyAction(
      child: PrimaryAction(
        step == 2 ? 'Explore NOVA' : 'Continue',
        onPressed: () {
          HapticFeedback.selectionClick();
          if (step < 2) {
            setState(() => step++);
          } else {
            widget.store.completeOnboarding();
          }
        },
      ),
    ),
  );
}
