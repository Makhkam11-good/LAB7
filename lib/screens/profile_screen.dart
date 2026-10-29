import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../core/navigation.dart';
import '../models/commerce.dart';
import '../state/app_store.dart';
import '../widgets/components.dart';
import 'registration_screen.dart';
import 'orders_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.store});
  final AppStore store;
  Future<void> register(BuildContext context) async {
    final profile = await openPage<UserProfile>(
      context,
      RegistrationScreen(initial: store.profile),
    );
    if (profile != null) {
      store.setProfile(profile);
      if (context.mounted) {
        feedback(context, 'Your profile is ready. Welcome to NOVA.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final user = store.profile;
    return PageBody(
      maxWidth: 760,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          const Kicker('A space of your own'),
          const SizedBox(height: 12),
          PageHeading(
            user == null
                ? 'Hello, you.'
                : 'Hello, ${user.name.split(' ').first}.',
            'Your style. Your settings. Your NOVA.',
          ),
          const SizedBox(height: 28),
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: p.tint,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Center(
                        child: user == null
                            ? const Icon(Icons.person_outline_rounded, size: 28)
                            : Text(
                                user.name.characters.first.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Make yourself at home',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              letterSpacing: -.4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            user?.email ?? 'Create your local profile to keep things personal.',
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.5,
                              color: p.muted,
                            ),
                          ),
                          if (user != null) ...[
                            const SizedBox(height: 8),
                            Tag(user.role),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                PrimaryAction(
                  user == null ? 'Create your profile' : 'Update your profile',
                  onPressed: () => register(context),
                  icon: Icons.arrow_outward_rounded,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Kicker('Your collection'),
          const SizedBox(height: 12),
          SurfaceCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
              leading: const Icon(Icons.receipt_long_outlined),
              title: const Text(
                'My orders',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                '${store.orders.length} demo orders',
                style: TextStyle(fontSize: 12, color: p.muted),
              ),
              trailing: const Icon(Icons.arrow_forward_rounded, size: 20),
              onTap: () => openPage(context, OrdersScreen(store: store)),
            ),
          ),
          const SizedBox(height: 28),
          const Kicker('Make it feel like you'),
          const SizedBox(height: 12),
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Appearance',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  'A different mood. The same NOVA.',
                  style: TextStyle(fontSize: 12, color: p.muted),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ThemeMode.values
                      .map(
                        (m) => ChoiceChip(
                          showCheckmark: false,
                          avatar: Icon(
                            m == ThemeMode.system
                                ? Icons.brightness_auto_outlined
                                : m == ThemeMode.light
                                ? Icons.light_mode_outlined
                                : Icons.dark_mode_outlined,
                            size: 17,
                          ),
                          label: Text(
                            m == ThemeMode.system
                                ? 'System'
                                : m == ThemeMode.light
                                ? 'Light'
                                : 'Dark',
                          ),
                          selected: store.themeMode == m,
                          onSelected: (_) => store.setTheme(m),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'NOVA is a student project. Profiles and orders are stored only on this device. Registration demonstrates validation; it does not create an online account.',
            style: TextStyle(fontSize: 12, height: 1.6, color: p.muted),
          ),
          if (store.storageError != null) ...[
            const SizedBox(height: 16),
            Text(store.storageError!),
            TextButton(
              onPressed: store.retrySave,
              child: const Text('Retry saving'),
            ),
          ],
          const SizedBox(height: 32),
          const Center(child: Kicker('NOVA · Everyday, elevated.')),
        ],
      ),
    );
  }
}
