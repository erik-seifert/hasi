import 'package:intl/intl.dart';

class HaDateUtils {
  /// Detects if a string is a Home Assistant ISO 8601 timestamp.
  /// Example: 2024-05-24T10:30:00.000000+00:00
  static bool isHaTimestamp(String value) {
    if (value.length < 10) return false;

    // Basic format check: 0000-00-00T...
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}T').hasMatch(value)) return false;

    return DateTime.tryParse(value) != null;
  }

  /// Formats a Home Assistant timestamp into a user-friendly string.
  /// If [relative] is true, returns "2 hours ago" etc.
  /// Otherwise returns a localized date-time string.
  static String formatHaTimestamp(
    String value, {
    bool relative = true,
    String? locale,
  }) {
    final dateTime = DateTime.tryParse(value);
    if (dateTime == null) return value;

    final localDateTime = dateTime.toLocal();

    if (relative) {
      return _formatRelative(localDateTime);
    }

    return DateFormat.yMMMd(locale).add_jm().format(localDateTime);
  }

  static String _formatRelative(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }
}
