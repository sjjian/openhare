import 'package:client/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateTimeFormat on DateTime {
  String formatDateTime(BuildContext context, {DateTime? now}) {
    final l10n = AppLocalizations.of(context)!;
    final local = toLocal();
    final nowLocal = (now ?? DateTime.now()).toLocal();
    final timeStr = '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';

    if (local.year == nowLocal.year &&
        local.month == nowLocal.month &&
        local.day == nowLocal.day) {
      return '${l10n.date_today} $timeStr';
    }

    final yesterday = nowLocal.subtract(const Duration(days: 1));
    if (local.year == yesterday.year &&
        local.month == yesterday.month &&
        local.day == yesterday.day) {
      return '${l10n.date_yesterday} $timeStr';
    }

    final difference = nowLocal.difference(local);
    if (difference.inDays < 7) {
      final weekdays = [
        l10n.date_monday,
        l10n.date_tuesday,
        l10n.date_wednesday,
        l10n.date_thursday,
        l10n.date_friday,
        l10n.date_saturday,
        l10n.date_sunday,
      ];
      return '${weekdays[local.weekday - 1]} $timeStr';
    }

    return '${local.year.toString().padLeft(4, '0')}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')} $timeStr';
  }

  String formatFullDateTime([BuildContext? context]) {
    final local = toLocal();
    final locale = context != null
        ? Localizations.localeOf(context).toString()
        : 'en';
    return DateFormat.yMMMMd(locale).add_Hm().format(local);
  }
}

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

