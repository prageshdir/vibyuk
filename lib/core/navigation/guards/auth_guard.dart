import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibyuk/core/auth/token_manager.dart';
import 'package:vibyuk/core/navigation/route_names.dart';

class AuthGuard {
  AuthGuard(this._tokenManager);

  final TokenManager _tokenManager;

  // Returns null if the user may proceed, otherwise returns the redirect path.
  Future<String?> redirect(BuildContext context, GoRouterState state) async {
    final hasSession = await _tokenManager.hasValidSession();
    final isAuthRoute = _isAuthRoute(state.matchedLocation);

    if (!hasSession && !isAuthRoute) {
      return '${RouteNames.login}?redirect=${Uri.encodeComponent(state.matchedLocation)}';
    }

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
}
