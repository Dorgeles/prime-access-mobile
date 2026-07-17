import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:prime_access/providers/auth_provider.dart';
import 'package:prime_access/features/auth/screens/login_screen.dart';
import 'package:prime_access/features/auth/screens/register_screen.dart';
import 'package:prime_access/features/dashboard/screens/dashboard_screen.dart';
import 'package:prime_access/features/history/screens/history_screen.dart';
import 'package:prime_access/features/profile/screens/profile_screen.dart';
import 'package:prime_access/features/profile/screens/edit_profile_screen.dart';
import 'package:prime_access/features/qr_scan/screens/scanner_screen.dart';
import 'package:prime_access/features/qr_scan/screens/confirmation_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/dashboard',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final isAuthRoute =
          state.matchedLocation == '/login' || state.matchedLocation == '/register';
      final isAuthenticated = authProvider.isAuthenticated;
      final isInitializing = authProvider.status == AuthStatus.initial ||
          authProvider.status == AuthStatus.loading;

      if (isInitializing) return null;

      if (!isAuthenticated && !isAuthRoute) return '/login';
      if (isAuthenticated && isAuthRoute) return '/dashboard';

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return _ShellScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/history',
            builder: (context, state) => const HistoryScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/scan',
        builder: (context, state) => const ScannerScreen(),
      ),
      GoRoute(
        path: '/scan/confirm',
        builder: (context, state) {
          final data = state.extra as Map<String, String>;
          return ConfirmationScreen(
            qrData: data['qrData']!,
            latitude: data['latitude']!,
            longitude: data['longitude']!,
          );
        },
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const EditProfileScreen(),
      ),
    ],
  );
}

class _ShellScaffold extends StatelessWidget {
  final Widget child;

  const _ShellScaffold({required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _calculateSelectedIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => _onItemTapped(index, context),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Historique',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(String location) {
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/history')) return 1;
    if (location.startsWith('/profile')) return 2;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/history');
        break;
      case 2:
        context.go('/profile');
        break;
    }
  }
}
