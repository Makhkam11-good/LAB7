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
  late String role = widget.initial?.role ?? 'Student';
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
    appBar: AppBar(title: const Kicker('Your everyday, personalized')),
    body: PageBody(
      maxWidth: 600,
      child: Form(
        key: form,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Reveal(
              child: PageHeading(
                'A little more\nyou.',
                'Set up your profile and make NOVA your own.',
              ),
            ),
            const SizedBox(height: 28),
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
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('password'),
              controller: password,
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
              validator: (v) => v == null || v.length < 6
                  ? 'Use at least 6 characters.'
                  : null,
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
                  tooltip: showConfirm
                      ? 'Hide confirmation'
                      : 'Show confirmation',
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
            DropdownButtonFormField<String>(
              initialValue: role,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Your role'),
              items: [
                'Student',
                'Teacher',
                'Developer',
              ].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (v) => setState(() => role = v!),
            ),
            const SizedBox(height: 20),
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
      ),
    ),
  );
}
