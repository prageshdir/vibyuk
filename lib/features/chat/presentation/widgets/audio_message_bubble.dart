import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/chat/domain/entities/chat_message_entity.dart';

class AudioMessageBubble extends StatefulWidget {
  const AudioMessageBubble({super.key, required this.message});
  final ChatMessageEntity message;

  @override
  State<AudioMessageBubble> createState() => _AudioMessageBubbleState();
}

class _AudioMessageBubbleState extends State<AudioMessageBubble> {
  late final AudioPlayer _player;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    if (widget.message.mediaUrl == null) return;
    try {
      await _player.setUrl(widget.message.mediaUrl!);
      if (mounted) {
        setState(() {
          _duration = _player.duration ?? Duration.zero;
          _ready = true;
        });
      }
      _player.positionStream.listen((p) {
        if (mounted) setState(() => _position = p);
      });
      _player.playerStateStream.listen((s) {
        if (!mounted) return;
        setState(() => _isPlaying = s.playing);
        if (s.processingState == ProcessingState.completed) {
          _player.seek(Duration.zero);
          if (mounted) setState(() { _isPlaying = false; _position = Duration.zero; });
        }
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _fmtDuration(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _fmtTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMe = widget.message.isMe;
    final bgColor = isMe ? null : theme.colorScheme.surfaceVariant;
    final fgColor = isMe ? Colors.white : theme.colorScheme.onSurface;
    final fgLight =
        isMe ? Colors.white70 : theme.colorScheme.onSurfaceVariant;
    final sliderActive = isMe ? Colors.white : AppColors.primary;
    final sliderInactive = isMe
        ? Colors.white38
        : AppColors.primary.withOpacity(0.3);
    final totalSecs =
        widget.message.durationSeconds ?? _duration.inSeconds;

    return Padding(
      padding: EdgeInsets.only(
        left: isMe ? 64 : 52,
        right: isMe ? 12 : 64,
        top: 2,
        bottom: 2,
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 260),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          gradient: isMe
              ? const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark])
              : null,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () async {
                if (!_ready) return;
                if (_isPlaying) {
                  await _player.pause();
                } else {
                  await _player.play();
                }
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: fgColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: fgColor,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 2,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 5),
                      activeTrackColor: sliderActive,
                      inactiveTrackColor: sliderInactive,
                      thumbColor: sliderActive,
                      overlayShape: SliderComponentShape.noOverlay,
                    ),
                    child: Slider(
                      value: _duration.inMilliseconds > 0
                          ? (_position.inMilliseconds /
                                  _duration.inMilliseconds)
                              .clamp(0.0, 1.0)
                          : 0.0,
                      onChanged: (v) => _player.seek(Duration(
                          milliseconds:
                              (v * _duration.inMilliseconds).round())),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isPlaying
                            ? _fmtDuration(_position)
                            : _fmtDuration(Duration(seconds: totalSecs)),
                        style: TextStyle(
                            color: fgLight,
                            fontSize: 10,
                            fontWeight: FontWeight.w500),
                      ),
                      Text(
                        _fmtTime(widget.message.createdAt),
                        style: TextStyle(color: fgLight, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
