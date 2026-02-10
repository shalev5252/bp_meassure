import 'package:bp_monitor/core/errors.dart';
import 'package:bp_monitor/l10n/app_localizations.dart';
import 'package:bp_monitor/presentation/state/auth_provider.dart';
import 'package:bp_monitor/presentation/theme/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await ref.read(authServiceProvider).resetPassword(
          email: _emailCtrl.text.trim(),
        );

    if (!mounted) return;
    setState(() => _loading = false);

    switch (result) {
      case Success():
        setState(() => _sent = true);
      case Err(:final failure):
        setState(() => _error = failure.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/auth/login'),
        ),
        title: Text(l.resetPassword),
      ),
      body: SafeArea(
        child: AppLayout.formWrapper(
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                const SizedBox(height: 32),
                if (_sent) ...[
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l.resetPasswordSent,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: () => context.go('/auth/login'),
                    child: Text(l.login),
                  ),
                ] else ...[
                  if (_error != null) ...[
                    _ErrorBanner(message: _error!),
                    const SizedBox(height: AppLayout.fieldSpacing),
                  ],
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: InputDecoration(labelText: l.email),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    autocorrect: false,
                    onFieldSubmitted: (_) => _submit(),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return l.emailRequired;
                      if (!v.contains('@')) return l.invalidEmail;
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l.sendResetLink),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: TextStyle(color: colors.onErrorContainer),
      ),
    );
  }
}
