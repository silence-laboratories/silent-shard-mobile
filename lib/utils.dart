String hexToAscii(String hexString) => List.generate(
      hexString.length ~/ 2,
      (i) => String.fromCharCode(int.parse(hexString.substring(i * 2, (i * 2) + 2), radix: 16)),
    ).join();

String formatDurationFromNow(DateTime date) {
  final duration = DateTime.now().difference(date);
  return formatDuration(duration);
}

String formatDuration(Duration duration) {
  if (duration.inYears > 0) {
    return "${duration.inYears} ${duration.inYears == 1 ? "year" : "years"}";
  }
  if (duration.inMonths > 0) {
    return "${duration.inMonths} ${duration.inMonths == 1 ? "month" : "months"}";
  }
  if (duration.inWeeks > 0) {
    return "${duration.inWeeks} ${duration.inWeeks == 1 ? "week" : "weeks"}";
  }
  if (duration.inDays > 0) {
    return "${duration.inDays} ${duration.inDays == 1 ? "day" : "days"}";
  }
  if (duration.inHours > 0) {
    return "${duration.inHours} ${duration.inHours == 1 ? "hour" : "hours"}";
  }
  if (duration.inMinutes > 0) {
    return "${duration.inMinutes} ${duration.inMinutes == 1 ? "minute" : "minutes"}";
  }
  return "less than a minute";
}

String fileMessage(DateTime date) => "Last backup to file: ${formatDurationFromNow(date)} ago";

String cloudMessage(DateTime date) => "Last checked: ${formatDurationFromNow(date)} ago";

extension DateUtils on Duration {
  int get inYears => inMicroseconds ~/ (365 * Duration.microsecondsPerDay);
  int get inMonths => inMicroseconds ~/ (30 * Duration.microsecondsPerDay);
  int get inWeeks => inMicroseconds ~/ (7 * Duration.microsecondsPerDay);
}
