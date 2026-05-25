import 'dart:io';
import 'package:flutter/material.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/chat/presentation/widgets/audio_recorder_widget.dart';
import 'package:vibyuk/features/chat/presentation/widgets/media_picker_sheet.dart';

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    super.key,
    required this.onSendText,
    required this.onSendImage,
    required this.onSendFile,
    required this.onSendAudio,
    required this.onTypingStart,
    required this.onTypingStop,
    this.isSending = false,
    this.uploadProgress,
  });

  final void Function(String text) onSendText;
  final void Function(File file) onSendImage;
  final void Function(File file) onSendFile;
  final void Function(File file, int durationSeconds) onSendAudio;
  final VoidCallback onTypingStart;
  final VoidCallback onTypingStop;
  final bool isSending;
  final double? uploadProgress;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();
  bool _hasText = false;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final has = _controller.text.trim().isNotEmpty;
    if (has != _hasText) {
      setState(() => _hasText = has);
      has ? widget.onTypingStart() : widget.onTypingStop();
    }
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    widget.onTypingStop();
    widget.onSendText(text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.uploadProgress != null)
            LinearProgressIndicator(
              value: widget.uploadProgress,
              backgroundColor:
                  theme.colorScheme.surfaceVariant,
              color: AppColors.primary,
              minHeight: 2,
            ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                  top: BorderSide(
                      color: theme.colorScheme.outlineVariant,
                      width: 0.5)),
            ),
            child: _isRecording
                ? AudioRecorderWidget(
                    onStop: (file, dur) {
                      setState(() => _isRecording = false);
                      widget.onSendAudio(file, dur);
                    },
                    onCancel: () =>
                        setState(() => _isRecording = false),
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.attach_file_rounded),
                        onPressed: () => showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20)),
                          ),
                          builder: (_) => MediaPickerSheet(
                            onImageSelected: widget.onSendImage,
                            onFileSelected: widget.onSendFile,
                          ),
                        ),
                        color: theme.colorScheme.onSurfaceVariant,
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Container(
                          constraints:
                              const BoxConstraints(maxHeight: 120),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: TextField(
                            controller: _controller,
                            maxLines: null,
                            textCapitalization:
                                TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              hintText: 'Type a message…',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                            ),
                            onSubmitted: (_) => _send(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      if (_hasText)
                        _SendBtn(isSending: widget.isSending, onTap: _send)
                      else
                        IconButton(
                          icon: const Icon(Icons.mic_rounded),
                          onPressed: () =>
                              setState(() => _isRecording = true),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(44, 44),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _SendBtn extends StatelessWidget {
  const _SendBtn({required this.isSending, required this.onTap});
  final bool isSending;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => FilledButton(
        onPressed: isSending ? null : onTap,
        style: FilledButton.styleFrom(
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(12),
          minimumSize: const Size(44, 44),
        ),
        child: isSending
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.send_rounded, size: 20),
      );
}
