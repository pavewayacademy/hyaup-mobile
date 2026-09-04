import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _currencyFormat = NumberFormat('#,###', 'en_US');

  /// Formats salary amounts in FCFA (XAF) or USD
  static String formatSalaryRange({
    num? min,
    num? max,
    String currency = "XAF",
    String period = "month",
  }) {
    if (min == null && max == null) {
      return "Salary Undisclosed";
    }

    final currencyLabel = currency == "XAF" ? "FCFA" : currency;

    if (min != null && max != null) {
      if (min == max) {
        return "${_currencyFormat.format(min)} $currencyLabel / $period";
      }
      return "${_currencyFormat.format(min)} - ${_currencyFormat.format(max)} $currencyLabel / $period";
    } else if (min != null) {
      return "From ${_currencyFormat.format(min)} $currencyLabel / $period";
    } else {
      return "Up to ${_currencyFormat.format(max!)} $currencyLabel / $period";
    }
  }
}
