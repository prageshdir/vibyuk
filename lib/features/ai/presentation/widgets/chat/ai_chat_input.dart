import 'package:flutter/material.dart';
import 'package:vibyuk/core/theme/app_colors.dart';

class AiChatInput extends StatefulWidget {
  final bool isEnabled;
  final ValueChanged<String> onSubmit;
  final String hintText;

  const AiChatInput({
    super.key,
    this.isEnabled = true,
    required this.onSubmit,
    this.hintText = 'Ask Viby AI anything...',
  });

  @override
  State<AiChatInput> createState() => _AiChatInputState();
}

class _AiChatInputState extends State<AiChatInput> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) setState(() => _hasText = hasText);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty || !widget.isEnabled) return;
    widget.onSubmit(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: AppColors.outline.withValues(alpha: 0.15),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.surfaceVariantDark
                      : AppColors.surfaceVariant,
                  border: Border.all(
                    color: _hasText
                        ? AppColors.primary.withValues(alpha: 0.4)
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        enabled: widget.isEnabled,
                        maxLines: 4,
                        minLines: 1,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _submit(),
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: widget.hintText,
                          hintStyle: TextStyle(
                            color: AppColors.textDisabled,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedScale(
              scale: _hasText && widget.isEnabled ? 1.0 : 0.85,
              duration: const Duration(milliseconds: 150),
              child: GestureDetector(
                onTap: _submit,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _hasText && widget.isEnabled
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: AppColors.brandGradient,
                          )
                        : null,
                    color: _hasText && widget.isEnabled
                        ? null
                        : AppColors.outline.withValues(alpha: 0.2),
                    boxShadow: _hasText && widget.isEnabled
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Icon(
                    Icons.send_rounded,
                    size: 18,
                    color: _hasText && widget.isEnabled
                        ? Colors.white
                        : AppColors.textDisabled,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
