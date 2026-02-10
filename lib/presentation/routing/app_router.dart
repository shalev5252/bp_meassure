import 'package:bp_monitor/domain/entities/reading_entity.dart';
import 'package:bp_monitor/presentation/screens/ai/ai_insights_screen.dart';
import 'package:bp_monitor/presentation/screens/analytics/analytics_screen.dart';
import 'package:bp_monitor/presentation/screens/auth/login_screen.dart';
import 'package:bp_monitor/presentation/screens/auth/reset_password_screen.dart';
import 'package:bp_monitor/presentation/screens/auth/signup_screen.dart';
import 'package:bp_monitor/presentation/screens/export/export_screen.dart';
import 'package:bp_monitor/presentation/screens/home/home_screen.dart';
import 'package:bp_monitor/presentation/screens/onboarding/language_selection_screen.dart';
import 'package:bp_monitor/presentation/screens/onboarding/medications_screen.dart';
import 'package:bp_monitor/presentation/screens/onboarding/profile_screen.dart';
import 'package:bp_monitor/presentation/screens/onboarding/risk_factors_screen.dart';
import 'package:bp_monitor/presentation/screens/profile/medications_manage_screen.dart';
import 'package:bp_monitor/presentation/screens/profile/profile_view_screen.dart';
import 'package:bp_monitor/presentation/screens/profile/risk_factors_manage_screen.dart';
import 'package:bp_monitor/presentation/screens/readings/reading_detail_screen.dart';
import 'package:bp_monitor/presentation/screens/readings/reading_form_screen.dart';
import 'package:bp_monitor/presentation/screens/readings/reading_history_screen.dart';
import 'package:bp_monitor/presentation/screens/settings/settings_screen.dart';
import 'package:bp_monitor/presentation/state/auth_provider.dart';
import 'package:bp_monitor/presentation/state/onboarding_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Auth- and onboarding-aware routes.
///
/// Redirect logic:
/// - Unauthenticated users → /auth/login
/// - Authenticated users without a patient profile → /onboarding/language
/// - Authenticated users with a profile on auth/onboarding routes → /home
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final onboarded = ref.watch(onboardingCompleteProvider);

  return GoRouter(
    initialLocation: '/auth/login',
    redirect: (context, state) {
      final isLoggedIn =
          authState.whenOrNull(data: (user) => user != null) ?? false;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');
      final isOnboardingRoute =
          state.matchedLocation.startsWith('/onboarding');

      // Not logged in → must be on an auth route.
      if (!isLoggedIn) {
        return isAuthRoute ? null : '/auth/login';
      }

      // Logged in but still loading onboarding status → let them stay.
      final hasProfile = onboarded.valueOrNull;
      if (hasProfile == null) return null;

      // Logged in, no profile yet → send to onboarding (unless already there).
      if (!hasProfile) {
        return isOnboardingRoute ? null : '/onboarding/language';
      }

      // Logged in + has profile → redirect away from auth/onboarding.
      if (isAuthRoute || isOnboardingRoute) return '/home';
      return null;
    },
    routes: [
      // Auth
      GoRoute(
        path: '/auth/login',
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/signup',
        builder: (_, _) => const SignupScreen(),
      ),
      GoRoute(
        path: '/auth/reset-password',
        builder: (_, _) => const ResetPasswordScreen(),
      ),

      // Onboarding
      GoRoute(
        path: '/onboarding/language',
        builder: (_, _) => const LanguageSelectionScreen(),
      ),
      GoRoute(
        path: '/onboarding/profile',
        builder: (_, _) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/onboarding/risk-factors',
        builder: (_, _) => const RiskFactorsScreen(),
      ),
      GoRoute(
        path: '/onboarding/medications',
        builder: (_, _) => const MedicationsScreen(),
      ),

      // Main app
      GoRoute(
        path: '/home',
        builder: (_, _) => const HomeScreen(),
      ),

      // Readings
      GoRoute(
        path: '/new-reading',
        builder: (_, _) => const ReadingFormScreen(),
      ),
      GoRoute(
        path: '/readings',
        builder: (_, _) => const ReadingHistoryScreen(),
      ),
      GoRoute(
        path: '/reading/:id',
        builder: (_, state) => ReadingDetailScreen(
          readingId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/reading/:id/edit',
        builder: (_, state) => ReadingFormScreen(
          existingReading: state.extra as ReadingEntity?,
        ),
      ),

      // Analytics
      GoRoute(
        path: '/analytics',
        builder: (_, _) => const AnalyticsScreen(),
      ),

      // Profile
      GoRoute(
        path: '/profile',
        builder: (_, _) => const ProfileViewScreen(),
      ),
      GoRoute(
        path: '/profile/risk-factors',
        builder: (_, _) => const RiskFactorsManageScreen(),
      ),
      GoRoute(
        path: '/profile/medications',
        builder: (_, _) => const MedicationsManageScreen(),
      ),

      // AI
      GoRoute(
        path: '/ai',
        builder: (_, _) => const AiInsightsScreen(),
      ),

      // Export
      GoRoute(
        path: '/export',
        builder: (_, _) => const ExportScreen(),
      ),

      // Settings
      GoRoute(
        path: '/settings',
        builder: (_, _) => const SettingsScreen(),
      ),
    ],
  );
});
