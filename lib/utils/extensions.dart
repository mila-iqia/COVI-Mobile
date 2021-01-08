extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

extension IntExtension on int {
  int negative() {
    return -this;
  }

  String formatDecimal({String separator = ","}) {
    if (this > -1000 && this < 1000) return this.toString();

    final String digits = this.abs().toString();
    final StringBuffer result = StringBuffer(this < 0 ? '-' : '');
    final int maxDigitIndex = digits.length - 1;
    for (int i = 0; i <= maxDigitIndex; i += 1) {
      result.write(digits[i]);
      if (i < maxDigitIndex && (maxDigitIndex - i) % 3 == 0)
        result.write(separator);
    }
    return result.toString();
  }
}

extension DateTimeExtension on DateTime {
  bool isToday() {
    DateTime today = new DateTime.now();
    return this != null &&
        today.day == this.day &&
        today.month == this.month &&
        today.year == this.year;
  }
}
