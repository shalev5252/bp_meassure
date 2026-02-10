import 'package:bp_monitor/l10n/app_localizations.dart';
import 'package:bp_monitor/presentation/state/auth_provider.dart';
import 'package:bp_monitor/presentation/state/locale_provider.dart';
import 'package:bp_monitor/presentation/theme/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppLayout.horizontalPadding,
          vertical: 16,
        ),
        children: [
          // Language toggle
          Card(
            child: ListTile(
              leading: const Icon(Icons.language),
              title: Text(l.settingsLanguage),
              subtitle: Text(currentLocale.languageCode == 'he'
                  ? 'עברית'
                  : 'English'),
              onTap: () {
                final newLocale = currentLocale.languageCode == 'he'
                    ? supportedLocales.first
                    : supportedLocales.last;
                ref.read(localeProvider.notifier).state = newLocale;
              },
            ),
          ),
          const SizedBox(height: 8),

          // Export all data
          Card(
            child: ListTile(
              leading: const Icon(Icons.download),
              title: Text(l.settingsExportAll),
              onTap: () => context.push('/export'),
            ),
          ),
          const SizedBox(height: 8),

          // About
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(l.settingsAbout),
              subtitle: Text(l.aboutVersion),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: l.appTitle,
                  applicationVersion: '1.0.0',
                  children: [Text(l.aboutDescription)],
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Logout
          OutlinedButton.icon(
            onPressed: () => _confirmLogout(context, ref, l),
            icon: const Icon(Icons.logout),
            label: Text(l.logout),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(
      BuildContext context, WidgetRef ref, AppLocalizations l) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.logout),
        content: Text(l.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(authServiceProvider).logout();
              if (context.mounted) context.go('/auth/login');
            },
            child: Text(l.logout),
          ),
        ],
      ),
    );
  }
}
