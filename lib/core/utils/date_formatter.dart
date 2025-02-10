import 'package:intl/intl.dart';

class DateFormatter {
  /// Formats DateTime to "20 Sep, 2022"
  static String format(DateTime date) {
    return DateFormat("dd MMM, yyyy").format(date);
  }

  /// Parses "20 Sep, 2022" back to DateTime
  static DateTime parse(String date) {
    return DateFormat("dd MMM, yyyy").parse(date);
  }
}
