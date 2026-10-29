import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/login/login_page.dart';
import '../features/dashboard/view/dashboard_page.dart';
import '../features/shell/home_shell.dart';

abstract final class Routes {
  static const splash = '/splash';
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const tickets = '/tickets';
  static const reports = '/reports';
}

/// Routes follow the session: nothing but the login screen until signed in,
/// and straight to the dashboard once signed in.
GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: Routes.dashboard,
    refreshListenable: _StreamListenable(authBloc.stream),
    redirect: (context, state) {
      final location = state.matchedLocation;

      return switch (authBloc.state.status) {
        AuthStatus.unknown => location == Routes.splash ? null : Routes.splash,
        AuthStatus.unauthenticated =>
          location == Routes.login ? null : Routes.login,
        AuthStatus.authenticated =>
          location == Routes.login || location == Routes.splash
              ? Routes.dashboard
              : null,
      };
    },
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, state) =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            HomeShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.dashboard,
                builder: (context, state) => const DashboardPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.tickets,
                builder: (context, state) =>
                    const ComingSoonPage(title: 'Tickets'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.reports,
                builder: (context, state) =>
                    const ComingSoonPage(title: 'Reports'),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// Lets go_router re-run its redirect whenever the auth state changes.
class _StreamListenable extends ChangeNotifier {
  _StreamListenable(Stream<Object?> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<Object?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
