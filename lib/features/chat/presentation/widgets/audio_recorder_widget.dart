import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:vibyuk/core/theme/app_colors.dart';

class AudioRecorderWidget extends StatefulWidget {
  const AudioRecorderWidget({
    super.key,
    required this.onStop,
    required this.onCancel,
  });

  final void Function(File file, int durationSeconds) onStop;
  final VoidCallback onCancel;

  @override
  State<AudioRecorderWidget> createState() => _AudioRecorderWidgetState();
}

class _AudioRecorderWidgetState extends State<AudioRecorderWidget> {
  final _recorder = AudioRecorder();
  int _elapsed = 0;
  Timer? _timer;
  bool _recording = false;
  String? _path;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    if (!await _recorder.hasPermission()) {
      widget.onCancel();
      return;
    }
    final dir = await getTemporaryDirectory();
    _path =
        '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 64000),
      path: _path!,
    );
    setState(() => _recording = true);
    _timer = Timer.periodic(const Duration(seconds: 1),
        (_) => setState(() => _elapsed++));
  }

  Future<void> _stop() async {
    _timer?.cancel();
    final path = await _recorder.stop();
    if (path != null && _elapsed > 0) {
      widget.onStop(File(path), _elapsed);
    } else {
      widget.onCancel();
    }
  }

  String _fmt(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.delete_outline_rounded),
          color: theme.colorScheme.error,
          onPressed: () async {
            _timer?.cancel();
            await _recorder.stop();
            widget.onCancel();
          },
        ),
        Expanded(
          child: Row(
            children: [
              if (_recording) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: Colors.red, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                _fmt(_elapsed),
                style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600, color: Colors.red),
              ),
              const SizedBox(width: 8),
              Text('Recording…',
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.send_rounded),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          onPressed: _stop,
        ),
      ],
    );
  }
}
