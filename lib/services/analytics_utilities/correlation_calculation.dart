import 'dart:math';

import './common_analytics_utilities.dart';
import 'package:flutter/material.dart';

import '../../model/note.dart';
import '../../model/parameter.dart';

Map<String, dynamic> calculateFixedCorrelation({
  required Parameter firstParameter,
  required Parameter secondParameter,
  required DateTimeRange range,
  int interval = 24,
  int lag = 0,
}) {
  int intervalMS = interval * 3600000; // convert interval to milliseconds

  Set<int> intervals = {1};
  Set<int> firstNotesIntervals = {};
  Set<int> secondNotesIntervals = {};
  Set<int> dayIntervalsToIgnore = {};

  //fill dayIntervalsToIgnore: the order numbers of an intervals in a day. If interval is 4 hours
  //there are 6 intervals in a day and every one has a dayInterval index
  int intervalsInDay = 24 ~/ interval;
  for (int i = 1; i <= intervalsInDay; i++) {
    dayIntervalsToIgnore.add(i);
  }

  //calculate lag in milliseconds
  int lagMS = lag * intervalMS;

  //get startofDay of the startMS - it is actualy startof day of range.start
  int firstDayMS = startOfDay(range.start).millisecondsSinceEpoch;
  print('firstDayMS: $firstDayMS');

  //find the start of first interval -> startMS
  int startRangeMS = range.start
      .millisecondsSinceEpoch; // convert start of the range to milliseconds
  print('startRangeMS: $startRangeMS');
  int startMS =
      ((startRangeMS - firstDayMS) ~/ intervalMS) * intervalMS + firstDayMS;

  print('startMS: $startMS');
  print('range starts: ${range.start}');

  //get the dayInterval order of the startMS
  //get the ~/ of the amount from startofday to calculate the order
  int dayIntervalLag = (startMS - firstDayMS) ~/ intervalMS;
  print('dayIntervalLag: $dayIntervalLag');

  //fill the intervals set
  int endRangeMS = range
      .end.millisecondsSinceEpoch; //convert end of the range to milliseconds
  for (int i = 1; startMS + intervalMS * (i - 1) < endRangeMS - lagMS; i++) {
    intervals.add(i);
  }

  //fill the first parameter set & remove interval-day index
  for (Note note in firstParameter.notes.values) {
    //get note time in MS
    DateTime noteTime = getNoteTime(note);
    int noteTimeMS = noteTime.millisecondsSinceEpoch;

    if (noteTimeMS > startMS) {
      int intervalIndex = (noteTimeMS - startMS) ~/ intervalMS + 1;

      //check if lagged interval is within a range
      if ((intervalIndex) <= intervals.last) {
        firstNotesIntervals.add(intervalIndex);
      }
    }

    //remove a corresponding DauInterval from dayIntervalsToIgnore
    int dayInterval = getDayInterval(noteTime, intervalsInDay);
    print('dayInterval to Remove: $dayInterval');
    dayIntervalsToIgnore.remove(dayInterval);
  }

  //fill the second parameter set
  for (Note note in secondParameter.notes.values) {
    //get note time in MS
    int noteTimeMS = getNoteTime(note).millisecondsSinceEpoch;
    int laggedTimeMS = noteTimeMS - lagMS;
    //check if lagged interval is within a range
    if (laggedTimeMS > startMS) {
      secondNotesIntervals.add((laggedTimeMS - startMS) ~/ intervalMS + 1);
    }
  }

  //elements of the contingency matrix
  int n01 = 0;
  int n00 = 0;
  int n10 = 0; // first occured, second did not
  int n11 = 0; // total occured on the "same/lagged" day
  //phi coefficient
  double phi;

  n11 = intervals
      .intersection(firstNotesIntervals)
      .intersection(secondNotesIntervals)
      .length;

  n10 = intervals
      .intersection(firstNotesIntervals)
      .difference(secondNotesIntervals)
      .length;
  n01 = intervals
      .intersection(secondNotesIntervals)
      .difference(firstNotesIntervals)
      .length;

  //n00 should not consider ignored dayIntervals - TODO

  //incorrect, because don't account the shift of interval - TODO
  Set<int> intervalsToIgnore = {};
  for (int dayInterval in dayIntervalsToIgnore) {
    for (int interval in intervals) {
      if ((interval + dayIntervalLag) % intervalsInDay == dayInterval) {
        intervalsToIgnore.add(interval);
      }
      if ((interval + dayIntervalLag) % intervalsInDay == 0 &&
          dayInterval == intervalsInDay) {
        intervalsToIgnore.add(interval);
      }
    }
  }

  n00 = intervals
      .difference(intervalsToIgnore)
      .difference(firstNotesIntervals)
      .difference(secondNotesIntervals)
      .length;

  //standard formula for phi coeficient
  phi = (n11 * n00 - n10 * n01) /
      sqrt((n00 + n10) * (n00 + n01) * (n11 + n10) * (n11 + n01));

  Map<String, dynamic> result = {
    'n00': n00,
    'n01': n01,
    'n10': n10,
    'n11': n11,
    'phi': phi,
  };

  print('intervals: $intervals');
  print('intervalsToIgnore: $intervalsToIgnore');
  print('firstNotesIntervals: $firstNotesIntervals');
  print('secondNotesIntervals: $secondNotesIntervals');
  print('dayIntervalsToIgnore: $dayIntervalsToIgnore');
  print('correlation result: $result');

  return result;
}

DateTime getNoteTime(Note note) {
  if (note.durationType == DurationType.moment) {
    return note.moment!;
  }

  if (note.durationType == DurationType.duration) {
    return note.duration!.end;
  }

  return DateTime.now();
}

//get the order of dayInterval current datetime lies in
int getDayInterval(DateTime date, int intervalsInDay) {
  int intervalMS = (24 ~/ intervalsInDay) * 3600000;
  return (date.millisecondsSinceEpoch -
              startOfDay(date).millisecondsSinceEpoch) ~/
          intervalMS +
      1;
}

List<Map<String, dynamic>> calculateAllFixedCorrelations({
  required Parameter firstParameter,
  required Parameter secondParameter,
  required DateTimeRange range,
  required List<int> intervals,
  required List<int> lags,
}) {
  List<Map<String, dynamic>> results = [];

  for (int interval in intervals) {
    for (int lag in lags) {
      Map<String, dynamic> result = calculateFixedCorrelation(
        firstParameter: firstParameter,
        secondParameter: secondParameter,
        range: range,
        interval: interval,
        lag: lag,
      );

      result['interval'] = interval;
      result['lag'] = lag;

      results.add(result);
    }
  }

  return results;
}
