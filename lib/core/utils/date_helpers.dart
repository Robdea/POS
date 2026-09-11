import 'package:intl/intl.dart';

class DateHelpers {
  DateHelpers._();

  static final DateFormat _fullFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  static String formatFull(DateTime date) => _fullFormat.format(date);
  static String formatDate(DateTime date) => _dateFormat.format(date);

  static bool isExpired(DateTime? expirationDate) {
    if (expirationDate == null) return false;
    return expirationDate.isBefore(DateTime.now());
  }

  static bool isNearExpiration(DateTime? expirationDate, {int days = 7}) {
    if (expirationDate == null) return false;
    final now = DateTime.now();
    final difference = expirationDate.difference(now).inDays;
    return difference >= 0 && difference <= days;
  }

  static int daysUntilExpiration(DateTime? expirationDate) {
    if (expirationDate == null) return -1;
    return expirationDate.difference(DateTime.now()).inDays;
  }
}
