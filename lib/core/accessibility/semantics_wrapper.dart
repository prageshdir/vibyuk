import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Wraps a child with a semantic label and optional tap-action hint.
/// Replaces ad-hoc Semantics(...) usage throughout the codebase.
class SemanticsWrapper extends StatelessWidget {
  const SemanticsWrapper({
    super.key,
    required this.child,
    required this.label,
    this.hint,
    this.button = false,
    this.enabled = true,
    this.onTap,
    this.excludeSemantics = false,
  });

  final Widget child;
  final String label;
  final String? hint;
  final bool button;
  final bool enabled;
  final VoidCallback? onTap;
  final bool excludeSemantics;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint,
      button: button,
      enabled: enabled,
      onTap: onTap,
      excludeSemantics: excludeSemantics,
      child: child,
    );
  }
}

/// Marks a decorative widget as hidden from the accessibility tree.
class AccessibilityHidden extends StatelessWidget {
  const AccessibilityHidden({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(child: child);
  }
}

/// Combines a visible label widget with a semantic override label.
/// Use when the rendered text differs from what screen readers should announce.
class AccessibilityLabel extends StatelessWidget {
  const AccessibilityLabel({
    super.key,
    required this.child,
    required this.label,
  });

  final Widget child;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: child,
    );
  }
}

/// Announces a status message to screen readers without visual change.
/// Useful for confirming actions (e.g., "Saved", "Copied to clipboard").
class AccessibilityAnnouncement extends StatefulWidget {
  const AccessibilityAnnouncement({
    super.key,
    required this.child,
    required this.message,
    this.trigger = false,
  });

  final Widget child;
  final String message;

  /// Set to true then back to false to trigger the announcement.
  final bool trigger;

  @override
  State<AccessibilityAnnouncement> createState() =>
      _AccessibilityAnnouncementState();
}

class _AccessibilityAnnouncementState
    extends State<AccessibilityAnnouncement> {
  @override
  void didUpdateWidget(AccessibilityAnnouncement oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      SemanticsService.announce(widget.message, TextDirection.ltr);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Enforces a minimum touch-target size of 48×48 dp per WCAG 2.5.5.
class MinTouchTarget extends StatelessWidget {
  const MinTouchTarget({
    super.key,
    required this.child,
    this.minSize = 48.0,
  });

  final Widget child;
  final double minSize;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minSize,
        minHeight: minSize,
      ),
      child: child,
    );
  }
}

/// Convenience extension on BuildContext to read the effective text scale.
extension AccessibilityContext on BuildContext {
  double get textScaleFactor =>
      MediaQuery.of(this).textScaler.scale(1.0);

  bool get isHighContrast =>
      MediaQuery.of(this).highContrast;

  bool get reduceMotion =>
      MediaQuery.of(this).disableAnimations;

  bool get boldText => MediaQuery.of(this).boldText;
}

/// Respects the system "reduce motion" flag.
/// Returns [Duration.zero] when animations should be skipped.
Duration accessibleDuration(BuildContext context, Duration duration) {
  return context.reduceMotion ? Duration.zero : duration;
}
