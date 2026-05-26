import 'package:flutter/material.dart';
import 'package:vibyuk/core/logging/app_logger.dart';
import 'package:vibyuk/core/services/crash_reporting_service.dart';
import 'package:vibyuk/core/widgets/buttons/primary_button.dart';

/// A Flutter error boundary widget.
/// Catches errors thrown during the build phase of its [child] and
/// renders a recoverable fallback UI instead of a white/red screen.
///
/// Usage:
/// ```dart
/// AppErrorBoundary(
///   child: SomeComplexWidget(),
/// )
/// ```
class AppErrorBoundary extends StatefulWidget {
  const AppErrorBoundary({
    super.key,
    required this.child,
    this.fallback,
    this.onError,
    this.allowReload = true,
  });

  final Widget child;

  /// Custom fallback widget. Receives [error] and a [reload] callback.
  final Widget Function(Object error, VoidCallback reload)? fallback;

  /// Called whenever an error is caught. Useful for analytics / crash hooks.
  final void Function(Object error, StackTrace stack)? onError;

  /// If true, shows a "Try Again" button to clear the error state.
  final bool allowReload;

  @override
  State<AppErrorBoundary> createState() => _AppErrorBoundaryState();
}

class _AppErrorBoundaryState extends State<AppErrorBoundary> {
  Object? _error;
  StackTrace? _stack;

  void _reload() => setState(() {
        _error = null;
        _stack = null;
      });

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      if (widget.fallback != null) {
        return widget.fallback!(_error!, _reload);
      }
      return _DefaultErrorFallback(
        error: _error!,
        onReload: widget.allowReload ? _reload : null,
      );
    }

    return _ErrorBoundaryScope(
      onError: (error, stack) {
        AppLogger.error(
          'AppErrorBoundary caught error',
          error: error,
          stackTrace: stack,
        );
        widget.onError?.call(error, stack);
        setState(() {
          _error = error;
          _stack = stack;
        });
      },
      child: widget.child,
    );
  }
}

/// A widget that wraps ErrorWidget.builder locally within its subtree.
class _ErrorBoundaryScope extends StatelessWidget {
  const _ErrorBoundaryScope({
    required this.child,
    required this.onError,
  });

  final Widget child;
  final void Function(Object error, StackTrace stack) onError;

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (details) {
      // Report once but don't loop
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onError(details.exception, details.stack ?? StackTrace.empty);
      });
      return const SizedBox.shrink();
    };
    return child;
  }
}

class _DefaultErrorFallback extends StatelessWidget {
  const _DefaultErrorFallback({required this.error, this.onReload});

  final Object error;
  final VoidCallback? onReload;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.bug_report_rounded,
                  size: 40,
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Something went wrong',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'An unexpected error occurred. Our team has been notified.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              if (onReload != null) ...[
                const SizedBox(height: 32),
                PrimaryButton(
                  label: 'Try Again',
                  onPressed: onReload,
                  isFullWidth: false,
                  width: 160,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Screen-level error boundary that also reports to CrashReportingService.
/// Use this at the screen/route level in production.
class ScreenErrorBoundary extends StatelessWidget {
  const ScreenErrorBoundary({
    super.key,
    required this.child,
    required this.crashReporting,
    this.screenName,
  });

  final Widget child;
  final CrashReportingService crashReporting;
  final String? screenName;

  @override
  Widget build(BuildContext context) {
    return AppErrorBoundary(
      onError: (error, stack) {
        crashReporting.recordError(
          error,
          stack,
          reason: 'Screen error${screenName != null ? ' on $screenName' : ''}',
          context: {
            if (screenName != null) 'screen': screenName!,
            'type': 'build_error',
          },
        );
      },
      child: child,
    );
  }
}
