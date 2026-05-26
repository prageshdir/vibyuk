import 'dart:math' as math;

import 'package:flutter/material.dart';

class AdminHeader extends StatefulWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;

  const AdminHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
  });

  @override
  State<AdminHeader> createState() => _AdminHeaderState();
}

class _AdminHeaderState extends State<AdminHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Container(
          padding: EdgeInsets.fromLTRB(
            20,
            MediaQuery.of(context).padding.top + 16,
            20,
            20,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF7B2FFF).withValues(alpha: 0.85),
                const Color(0xFF5A1FBF),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20 + math.sin(_ctrl.value * math.pi * 2) * 10,
                top: -10 + math.cos(_ctrl.value * math.pi * 2) * 8,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.04),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            if (widget.subtitle != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                widget.subtitle!,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.65),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (widget.actions != null)
                        ...widget.actions!.map(
                          (a) => Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: a,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
