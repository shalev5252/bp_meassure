import 'package:bp_monitor/l10n/app_localizations.dart';
import 'package:bp_monitor/presentation/state/locale_provider.dart';
import 'package:bp_monitor/presentation/theme/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LanguageSelectionScreen extends ConsumerWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeProvider);
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: AppLayout.formWrapper(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l.onboardingLanguage,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 32),
              _LanguageTile(
                label: 'English',
                locale: const Locale('en'),
                selected: current.languageCode == 'en',
                onTap: () =>
                    ref.read(localeProvider.notifier).state = const Locale('en'),
              ),
              const SizedBox(height: 12),
              _LanguageTile(
                label: 'עברית',
                locale: const Locale('he'),
                selected: current.languageCode == 'he',
                onTap: () =>
                    ref.read(localeProvider.notifier).state = const Locale('he'),
              ),
              const SizedBox(height: 48),
              FilledButton(
                onPressed: () => context.go('/onboarding/profile'),
                child: Text(l.onboardingNext),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.label,
    required this.locale,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Locale locale;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(
            color: selected ? colors.primary : colors.outline,
            width: selected ? 2 : 1,
          ),
          backgroundColor: selected ? colors.primaryContainer : null,
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 18,
            color: selected ? colors.onPrimaryContainer : colors.onSurface,
          ),
        ),
      ),
    );
  }
}
