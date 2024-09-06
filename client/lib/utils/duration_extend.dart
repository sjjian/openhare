extension TimeFormat on Duration {
  String format() {
    var microseconds = inMicroseconds;
    if (microseconds < 0) {
      return "0.00s";
    }

    var hoursFormat = "";
    var hours = microseconds ~/ Duration.microsecondsPerHour;
    if (hours > 0) {
      hoursFormat = "${hours}h";
    }

    var minutesFormat = "";
    microseconds = microseconds.remainder(Duration.microsecondsPerHour);
    var minutes = microseconds ~/ Duration.microsecondsPerMinute;
    if (minutes > 0) {
      minutesFormat = "${minutes}m";
    }

    var secondsFormat = "";
    microseconds = microseconds.remainder(Duration.microsecondsPerMinute);
    var seconds = microseconds / Duration.microsecondsPerSecond;
    if (seconds > 0) {
      secondsFormat = "${seconds.toStringAsFixed(2)}s";
    }

    return "$hoursFormat$minutesFormat$secondsFormat";
  }
}
