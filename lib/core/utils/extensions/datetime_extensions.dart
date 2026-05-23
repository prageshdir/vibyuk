import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
    return '${(diff.inDays / 365).floor()}y ago';
  }

  String format(String pattern) => DateFormat(pattern).format(this);

  String get displayDate => DateFormat('MMM d, yyyy').format(this);
  String get displayTime => DateFormat('h:mm a').format(this);
  String get displayDateTime => DateFormat('MMM d, yyyy · h:mm a').format(this);
  String get isoDate => DateFormat('yyyy-MM-dd').format(this);

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isPast => isBefore(DateTime.now());
  bool get isFuture => isAfter(DateTime.now());
}

extension NullableDateTimeExtensions on DateTime? {
  String get orEmpty => this == null ? '' : this!.displayDate;
}
