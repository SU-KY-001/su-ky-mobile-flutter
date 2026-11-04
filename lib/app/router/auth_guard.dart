import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:su_ky_mobile/features/auth/ui/session_controller.dart';

import 'app_routes.dart';

/// Sends guests to login and back. Before hydration finishes it never
/// redirects, so a stored session is not mistaken for a guest.
GoRouterRedirect authGuard(Ref ref) => (context, state) {
  final session = ref.read(sessionControllerProvider);
  if (!session.hydrated || session.isAuthenticated) return null;
  return AppRoutes.loginFor(state.uri.toString());
};

/// Keeps an authenticated user off the login screen, sending them back to the
/// safe `returnTo` target or home. The sign-in button also navigates by itself
/// (a pushed login cannot be popped after the session refresh), so this guard
/// covers logins reached through a redirect or a deep link.
GoRouterRedirect loginGuard(Ref ref) => (context, state) {
  final session = ref.read(sessionControllerProvider);
  if (!session.hydrated || !session.isAuthenticated) return null;
  return AppRoutes.returnToOf(state.uri) ?? AppRoutes.home;
};
