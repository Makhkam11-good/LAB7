import '../core/validation.dart';

import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/commerce.dart';
import '../widgets/components.dart';
import '../widgets/motion.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key, this.initial});
  final UserProfile? initial;
  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final form = GlobalKey<FormState>();
  late final name = TextEditingController(text: widget.initial?.name ?? '');
  late final email = TextEditingController(text: widget.initial?.email ?? '');
  final password = TextEditingController(), confirm = TextEditingController();
  final confirmKey = GlobalKey<FormFieldState<String>>();
  late final String role = widget.initial?.role ?? 'Student';
  bool accepted = false,
      showPassword = false,
      showConfirm = false,
      submitted = false;
  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    confirm.dispose();
    super.dispose();
  }

  void submit() {
    setState(() => submitted = true);
    final valid = form.currentState!.validate();
    if (!valid || !accepted) return;
    FocusScope.of(context).unfocus();
    final user = UserProfile(name.text.trim(), email.text.trim(), role);
    debugPrint(
      'NOVA registration: name=${user.name}, email=${user.email}, role=$role, password=[REDACTED]',
    );
    Navigator.pop(context, user);
  }

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
    ),
    body: PageBody(
      maxWidth: 1000,
      child: LayoutBuilder(
        builder: (context, bounds) {
          final intro = Reveal(
            child: _ProfileWelcome(editing: widget.initial != null),
          );
          final fields = SurfaceCard(
            padding: EdgeInsets.all(bounds.maxWidth < 340 ? 12 : 24),
            child: AutofillGroup(child: buildForm(context)),
          );
          if (bounds.maxWidth >= 820 &&
              MediaQuery.textScalerOf(context).scale(1) < 1.5) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 4, child: intro),
                const SizedBox(width: 32),
                Expanded(flex: 5, child: fields),
              ],
            );
          }
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                children: [intro, const SizedBox(height: 24), fields],
              ),
            ),
          );
        },
      ),
    ),
  );

  Widget buildForm(BuildContext context) => Form(
    key: form,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.initial == null ? 'Make it yours.' : 'Your profile.',
          style: const TextStyle(
            fontSize: 24,
            height: 1.2,
            fontWeight: FontWeight.w700,
            letterSpacing: -.7,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'A few details. A more personal collection.',
          style: TextStyle(
            fontSize: 13,
            height: 1.5,
            color: Palette.of(context).muted,
          ),
        ),
        const SizedBox(height: 24),
        const Kicker('01 / Your details'),
        const SizedBox(height: 16),
        TextFormField(
          key: const Key('full-name'),
          controller: name,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.name],
          decoration: const InputDecoration(
            labelText: 'Full name',
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
          validator: (v) => v == null || v.trim().isEmpty
              ? 'Your full name is required.'
              : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          key: const Key('email'),
          controller: email,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.alternate_email_rounded),
          ),
          validator: validateEmail,
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 24),
        const Kicker('02 / A little privacy'),
        const SizedBox(height: 16),
        TextFormField(
          key: const Key('password'),
          controller: password,
          autofillHints: const [AutofillHints.newPassword],
          obscureText: !showPassword,
          enableSuggestions: false,
          autocorrect: false,
          textInputAction: TextInputAction.next,
          onChanged: (_) {
            if (confirm.text.isNotEmpty) {
              confirmKey.currentState?.validate();
            }
          },
          decoration: InputDecoration(
            labelText: 'Password',
            helperText: 'At least 6 characters',
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            suffixIcon: IconButton(
              tooltip: showPassword ? 'Hide password' : 'Show password',
              onPressed: () => setState(() => showPassword = !showPassword),
              icon: Icon(
                showPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
            ),
          ),
          validator: (v) =>
              v == null || v.length < 6 ? 'Use at least 6 characters.' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          key: confirmKey,
          controller: confirm,
          obscureText: !showConfirm,
          enableSuggestions: false,
          autocorrect: false,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => submit(),
          decoration: InputDecoration(
            labelText: 'Confirm password',
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            suffixIcon: IconButton(
              tooltip: showConfirm ? 'Hide confirmation' : 'Show confirmation',
              onPressed: () => setState(() => showConfirm = !showConfirm),
              icon: Icon(
                showConfirm
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
            ),
          ),
          validator: (v) => v == null || v.isEmpty
              ? 'Please confirm your password.'
              : v != password.text
              ? 'Passwords must match exactly.'
              : null,
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 24),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: accepted,
          onChanged: (v) => setState(() => accepted = v ?? false),
          title: const Text(
            'I accept the Terms and Conditions',
            style: TextStyle(fontSize: 13),
          ),
          subtitle: Text(
            'Demo profile only. Passwords are validated but never stored.',
            style: TextStyle(
              fontSize: 11,
              height: 1.5,
              color: Palette.of(context).muted,
            ),
          ),
        ),
        if (submitted && !accepted)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Please accept the Terms and Conditions.',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        const SizedBox(height: 24),
        PrimaryAction(
          widget.initial == null ? 'Create profile' : 'Save profile',
          onPressed: submit,
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe later'),
          ),
        ),
      ],
    ),
  );
}

class _ProfileWelcome extends StatelessWidget {
  const _ProfileWelcome({required this.editing});
  final bool editing;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: p.tint,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: p.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: p.ink,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: CustomPaint(
                  size: const Size(26, 26),
                  painter: MarkPainter(p.canvas),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(child: Kicker('A space of your own')),
            ],
          ),
          const SizedBox(height: 24),
          PageHeading(
            editing ? 'Still you.\nJust updated.' : 'A little more\nyou.',
            'Your favorites. Your everyday essentials. All in one considered place.',
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _WelcomeTag(
                icon: Icons.bookmark_border_rounded,
                label: 'Save your favorites',
              ),
              _WelcomeTag(icon: Icons.tune_rounded, label: 'Make it personal'),
            ],
          ),
        ],
      ),
    );
  }
}

class _WelcomeTag extends StatelessWidget {
  const _WelcomeTag({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: Palette.of(context).surface,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 8),
        Flexible(
          child: Text(label, style: const TextStyle(fontSize: 11, height: 1.3)),
        ),
      ],
    ),
  );
}
