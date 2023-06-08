import 'dart:math';

import 'package:flutter/material.dart';

DateTime startOfDay(DateTime time) {
  return DateTime(time.year, time.month, time.day);
}

DateTime startOfNextDay(DateTime time) {
  return DateTime(time.year, time.month, time.day + 1);
}

DateTime hourOfDay(int hourIndex, DateTime time) {
  return DateTime(time.year, time.month, time.day, hourIndex);
}

Set<DateTime> daysFromRange(DateTimeRange range) {
  int totalDays = range.duration.inDays + 1;
  Set<DateTime> days = {};
  DateTime firstDay = startOfDay(range.start);
  for (int i = 0; i < totalDays; i++) {
    days.add(firstDay.add(Duration(days: i)));
  }
  return days;
}

DateTime oldestDate(List<DateTime> dates) {
  return dates.reduce((oldest, date) => date.isBefore(oldest) ? date : oldest);
}

DateTime earliestDate(List<DateTime> dates) {
  return dates
      .reduce((earliest, date) => date.isAfter(earliest) ? date : earliest);
}

//standard formula for phi coeficient
double calculatePhi(
    {required int n00, required int n01, required int n10, required int n11}) {
  return (n11 * n00 - n10 * n01) /
      sqrt((n00 + n10) * (n00 + n01) * (n11 + n10) * (n11 + n01));
}
