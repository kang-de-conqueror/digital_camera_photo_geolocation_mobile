import 'package:intl/intl.dart';

class FormatString {
  static String formatTime(DateTime time, String pattern) {
    // Format time string by pattern
    return DateFormat(pattern).format(time);
  }
}
