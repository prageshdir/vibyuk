import 'package:flutter/material.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/core/widgets/buttons/primary_button.dart';

class ErrorView extends StatelessWidget {
  final Failure? failure;
  final String? message;
  final String? title;
  final VoidCallback? onRetry;
  final String retryLabel;

  const ErrorView({
    super.key,
    this.failure,
    this.message,
    this.title,
    this.onRetry,
    this.retryLabel = 'Try Again',
  });

  @override
  Widget build(BuildContext context) {
    final errorMessage = message ?? failure?.message ?? 'Something went wrong.';
    final isConnection = failure is ConnectionFailure;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isConnection ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              title ?? (isConnection ? 'No Internet' : 'Error'),
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              PrimaryButton(
                label: retryLabel,
                onPressed: onRetry,
                isFullWidth: false,
                width: 180,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
