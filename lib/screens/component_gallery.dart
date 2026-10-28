import '../widgets/summary_line.dart';

import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../widgets/components.dart';

class ComponentGallery extends StatelessWidget {
  const ComponentGallery({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('NOVA · Design system')),
    body: PageBody(
      maxWidth: 760,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeading(
            'Considered\nby design.',
            '8pt rhythm. Warm neutrals. A quiet confidence.',
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children:
                [
                      Palette.of(context).canvas,
                      Palette.of(context).surface,
                      Palette.of(context).ink,
                      Palette.of(context).muted,
                      Palette.of(context).tint,
                    ]
                    .map(
                      (c) => Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: c,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Palette.of(context).line),
                        ),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 24),
          PrimaryAction('Primary action', onPressed: () {}),
          const SizedBox(height: 12),
          const PrimaryAction('Unavailable', onPressed: null),
          const SizedBox(height: 24),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [Tag('Wireless'), Tag('Considered design')],
          ),
          const SizedBox(height: 24),
          const SurfaceCard(
            child: SummaryLine('Everyday essentials', '\$249', strong: true),
          ),
        ],
      ),
    ),
  );
}
