class DateHelper {
  static String toYYYYMMDD(DateTime date) {
    if (date == null) return null;

    return date.year.toString() +
        "-" +
        date.month.toString().padLeft(2, '0') +
        "-" +
        date.day.toString().padLeft(2, '0');
  }

  static int toUnixTimestamp(DateTime date) {
    if (date == null) return null;

    return date.millisecondsSinceEpoch * 1000;
  }
}
