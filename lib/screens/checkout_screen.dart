import 'package:flutter/services.dart';

import '../core/validation.dart';
import '../widgets/summary_line.dart';

import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../core/format.dart';
import '../core/navigation.dart';
import '../state/app_store.dart';
import '../widgets/components.dart';
import 'receipt_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, required this.store});
  final AppStore store;
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final form = GlobalKey<FormState>();
  late final name = TextEditingController(
    text: widget.store.profile?.name ?? '',
  );
  late final email = TextEditingController(
    text: widget.store.profile?.email ?? '',
  );
  bool busy = false;
  @override
  void dispose() {
    name.dispose();
    email.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!form.currentState!.validate() || busy) return;
    FocusScope.of(context).unfocus();
    setState(() => busy = true);
    try {
      final order = widget.store.placeOrder(name.text.trim());
      await widget.store.flush();
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) => ReceiptScreen(
            order: order,
            storageError: widget.store.storageError,
          ),
        ),
      );
    } on StateError catch (e) {
      if (mounted) {
        setState(() => busy = false);
        feedback(context, e.message.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Kicker('One last detail')),
    body: PageBody(
      maxWidth: 600,
      child: Form(
        key: form,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeading(
              'Almost yours.',
              'A simple checkout, just for the demo.',
            ),
            const SizedBox(height: 28),
            SurfaceCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.school_outlined),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Campus pickup',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Demo pickup point · no real delivery\nFree · no payment required',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.6,
                            color: Palette.of(context).muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            TextFormField(
              key: const Key('checkout-name'),
              controller: name,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Full name'),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Please enter your name.'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('checkout-email'),
              controller: email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: validateEmail,
              onFieldSubmitted: (_) => submit(),
            ),
            const SizedBox(height: 28),
            SurfaceCard(
              child: Column(
                children: [
                  ...widget.store.cart.values.map(
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: SummaryLine(
                        '${i.product.title} × ${i.quantity}',
                        money(i.product.priceCents * i.quantity),
                      ),
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 20),
                  SummaryLine(
                    'Demo total',
                    money(widget.store.subtotal),
                    strong: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Placing this demo order saves a receipt on this device. No charge, email or shipment will be made.',
              style: TextStyle(
                fontSize: 12,
                height: 1.6,
                color: Palette.of(context).muted,
              ),
            ),
          ],
        ),
      ),
    ),
    bottomNavigationBar: StickyAction(
      child: PrimaryAction(
        busy ? 'Saving your order…' : 'Place demo order',
        onPressed: busy ? null : submit,
        icon: Icons.check_rounded,
      ),
    ),
  );
}
