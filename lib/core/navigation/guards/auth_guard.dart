import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibyuk/core/auth/token_manager.dart';
import 'package:vibyuk/core/navigation/route_names.dart';

class AuthGuard {
  AuthGuard(this._tokenManager);

  final TokenManager _tokenManager;

  // Returns null to allow navigation, or a redirect path.
  Future<String?> redirect(BuildContext context, GoRouterState state) async {
    final hasSession = await _tokenManager.hasValidSession();
    final location = state.matchedLocation;
    final isAuthRoute = _isAuthRoute(location);
    final isPublicRoute = _isPublicRoute(location);

    // Unauthenticated user trying to access a protected route
    if (!hasSession && !isAuthRoute && !isPublicRoute) {
      return '${RouteNames.login}?redirect=${Uri.encodeComponent(location)}';
    }

    // Authenticated user landing on auth routes → send home
    if (hasSession && isAuthRoute) {
      return RouteNames.home;
    }

    return null;
  }

  bool _isAuthRoute(String path) {
    return path.startsWith('/auth') ||
        path == RouteNames.splash ||
        path == RouteNames.onboarding;
  }

  bool _isPublicRoute(String path) {
    return path == RouteNames.splash ||
        path == RouteNames.onboarding;
  }
}
