import 'package:bp_monitor/core/errors.dart';
import 'package:bp_monitor/l10n/app_localizations.dart';
import 'package:bp_monitor/presentation/state/auth_provider.dart';
import 'package:bp_monitor/presentation/theme/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await ref.read(authServiceProvider).signUp(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );

    if (!mounted) return;
    setState(() => _loading = false);

    if (result case Err(:final failure)) {
      setState(() => _error = failure.message);
    }
    // On success, authStateProvider triggers redirect to onboarding.
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: AppLayout.formWrapper(
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                const SizedBox(height: 64),
                Text(
                  l.appTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l.createAccount,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                if (_error != null) ...[
                  _ErrorBanner(message: _error!),
                  const SizedBox(height: AppLayout.fieldSpacing),
                ],
                TextFormField(
                  controller: _emailCtrl,
                  decoration: InputDecoration(labelText: l.email),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return l.emailRequired;
                    if (!v.contains('@')) return l.invalidEmail;
                    return null;
                  },
                ),
                const SizedBox(height: AppLayout.fieldSpacing),
                TextFormField(
                  controller: _passwordCtrl,
                  decoration: InputDecoration(
                    labelText: l.password,
                    helperText: l.passwordHint,
                  ),
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  validator: (v) {
                    if (v == null || v.isEmpty) return l.passwordRequired;
                    if (v.length < 6) return l.passwordHint;
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
                      : Text(l.signUp),
                ),
                const SizedBox(height: AppLayout.fieldSpacing),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(l.haveAccount),
                    TextButton(
                      onPressed: () => context.go('/auth/login'),
                      child: Text(l.login),
                    ),
                  ],
                ),
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
