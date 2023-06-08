import 'dart:math';

import '../../view/view_utilities/text_utilities.dart';
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
  phi = calculatePhi(n00: n00, n01: n01, n10: n10, n11: n11);

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

Map<String, dynamic> calculateFloatingCorrelation({
  required Parameter firstParameter,
  required Parameter secondParameter,
  required DateTimeRange range,
  int intervalDuration = 24,
  int delay = 0,
}) {
  //DEBUG PRINTS
  print(
      'FLOATING CORRELATION FOR: ${firstParameter.name} & ${secondParameter.name}');
  print('--------------------');
  print('Range: ${prettifyDT(range.start)} - ${prettifyDT(range.end)}');
  print('Interval: $intervalDuration');
  print('Delay: $delay');
  print('--------------------');

  List<DateTimeRange> getTargetIntervals(List<DateTime> noteTimes) {
    List<DateTimeRange> intervals = [];
    for (DateTime noteTime in noteTimes) {
      DateTime startInterval = noteTime.add(Duration(hours: delay));
      DateTime endInterval =
          startInterval.add(Duration(hours: intervalDuration));
      DateTimeRange interval =
          DateTimeRange(start: startInterval, end: endInterval);
      intervals.add(interval);
    }
    return intervals;
  }

  Map<String, Set<int>> matchIntervalsWithNoteTimes(
      List<DateTimeRange> intervals, List<DateTime> noteTimes) {
    Set<int> intervalsInclude = <int>{};
    Set<int> intervalsNotInclude = <int>{};
    Set<int> notesIncluded = <int>{};
    Set<int> notesNotIncluded = <int>{};

    intervals.asMap().forEach((iIndex, interval) {
      noteTimes.asMap().forEach((tIndex, noteTime) {
        if (noteTime.isAfter(interval.start) &&
            noteTime.isBefore(interval.end)) {
          intervalsInclude.add(iIndex);
          notesIncluded.add(tIndex);
        }
      });
    });

    List<int> iIndexes = [for (int i = 0; i < intervals.length; i++) i];
    List<int> tIndexes = [for (int i = 0; i < noteTimes.length; i++) i];

    intervalsNotInclude = iIndexes.toSet().difference(intervalsInclude);

    notesNotIncluded = tIndexes.toSet().difference(notesIncluded);

    return {
      'intervalsInclude': intervalsInclude,
      'intervalsNotInclude': intervalsNotInclude,
      'notesIncluded': notesIncluded,
      'notesNotIncluded': notesNotIncluded,
    };
  }

  Set<int> getRelevantHourIndexes(List<DateTime> noteTimes) {
    Set<int> relevantHourIndexes = <int>{};
    for (DateTime noteTime in noteTimes) {
      relevantHourIndexes.add(noteTime.hour);
    }
    return relevantHourIndexes;
  }

  List<DateTimeRange> getRelevantHourIntervals(
      Set<int> relevantHourIndexes, DateTimeRange p1range) {
    List<DateTimeRange> intervals = [];

    //get first day intervals
    for (int hourIndex in relevantHourIndexes) {
      if (hourIndex > p1range.start.hour) {
        DateTime relevantIntervalStart = hourOfDay(hourIndex, p1range.start);
        DateTimeRange relevantInterval = DateTimeRange(
            start: relevantIntervalStart,
            end: relevantIntervalStart.add(const Duration(hours: 1)));
        intervals.add(relevantInterval);
      }
    }
    //get last day intervals
    for (int hourIndex in relevantHourIndexes) {
      if (hourIndex < p1range.end.hour - 1) {
        DateTime relevantIntervalStart = hourOfDay(hourIndex, p1range.end);
        DateTimeRange relevantInterval = DateTimeRange(
            start: relevantIntervalStart,
            end: relevantIntervalStart.add(const Duration(hours: 1)));
        intervals.add(relevantInterval);
      }
    }

    //get intervals for days in the middle
    for (DateTime day = startOfNextDay(p1range.start);
        day.isBefore(startOfDay(p1range.end));
        day = startOfNextDay(day)) {
      for (int hourIndex in relevantHourIndexes) {
        DateTime relevantIntervalStart = hourOfDay(hourIndex, day);
        DateTimeRange relevantInterval = DateTimeRange(
            start: relevantIntervalStart,
            end: relevantIntervalStart.add(const Duration(hours: 1)));
        intervals.add(relevantInterval);
      }
    }

    return intervals;
  }

  List<DateTimeRange> getEmptyTargetIntervals(
      List<DateTimeRange> relevantHourIntervals, List<DateTime> p1noteTimes) {
    List<DateTimeRange> targetIntervals = [];
    for (DateTimeRange relevantHourInterval in relevantHourIntervals) {
      bool includesAny = false;
      for (DateTime noteTime in p1noteTimes) {
        if (includedInRange(noteTime, relevantHourInterval)) {
          includesAny = true;
        }
      }
      if (!includesAny) {
        DateTime targetIntervalStart =
            relevantHourInterval.start.add(Duration(hours: delay));
        DateTime targetIntervalEnd = relevantHourInterval.end
            .add(Duration(hours: delay + intervalDuration));
        DateTimeRange targetInterval =
            DateTimeRange(start: targetIntervalStart, end: targetIntervalEnd);
        targetIntervals.add(targetInterval);
      }
    }

    return targetIntervals;
  }

  //how many times p1 occured and p2 NOT
  int n10;
  //how many times p1 occured and p2 occured
  int n11;
  //how many times p1 NOT occured and p2 occured
  int n01;
  //how many times neither p1 not p2 occured
  int n00;
  //phi coefficient
  double phi;

  //takes into account that we cannot see the result of p1 (in the future) if it occured too late
  DateTimeRange p1Range = DateTimeRange(
      start: range.start,
      end: range.end.subtract(Duration(hours: intervalDuration + delay)));
  //takes into account that we cannot see the cause of p2 occurances if it occured to early
  DateTimeRange p2Range = DateTimeRange(
      start: range.start.add(Duration(hours: intervalDuration + delay)),
      end: range.end);

  print('p1Range: ${prettifyDT(p1Range.start)} - ${prettifyDT(p1Range.end)}');
  print('p2Range: ${prettifyDT(p2Range.start)} - ${prettifyDT(p2Range.end)}');
  print('--------------------');

  //get the list of times of the notes of p1
  List<DateTime> p1NoteTimes = getNoteTimes(firstParameter, p1Range);
  print('p1Notes (${p1NoteTimes.length}): $p1NoteTimes');
  print('--------------------');

  //get target intervals where we search got p2
  List<DateTimeRange> targetIntervals = getTargetIntervals(p1NoteTimes);
  print(
      'Target Intervals to check p2 (${targetIntervals.length}): $targetIntervals');
  print('--------------------');

  //get the list of times of the notes of p2
  List<DateTime> p2NoteTimes = getNoteTimes(secondParameter, p2Range);
  print('p2Notes (${p2NoteTimes.length}): $p2NoteTimes');
  print('--------------------');

  //get indexes of intervals having a note
  Map<String, Set<int>> matchResult =
      matchIntervalsWithNoteTimes(targetIntervals, p2NoteTimes);

  n10 = matchResult['intervalsNotInclude']!.length;
  n11 = matchResult['intervalsInclude']!.length;
  n01 = matchResult['notesNotIncluded']!.length;
  print('n10: $n10');
  print('n11: $n11');
  print('n01: $n01');
  print('--------------------');

  //Find the relevant hourIntervals for n00
  print('FINDING N00:');
  //Take every p1 noteTime and generate a set of hourIndexes to check
  Set<int> relevantHourIndexes = getRelevantHourIndexes(p1NoteTimes);
  print('relevant Hour Indexes: $relevantHourIndexes');

  //Get List of p1 intervals to check n00: from Indexes and p1Range
  List<DateTimeRange> relevantHourIntervals =
      getRelevantHourIntervals(relevantHourIndexes, p1Range);
  print(
      'relevant Hour Intervals(${relevantHourIntervals.length}): $relevantHourIntervals');

  //Get target Hour Intervals to check n00 (p1 NOT occured) with p2 occurances
  List<DateTimeRange> emptyTargetIntervals =
      getEmptyTargetIntervals(relevantHourIntervals, p1NoteTimes);
  print(
      'Relevant Empty N00 Intervals (${emptyTargetIntervals.length}): $emptyTargetIntervals');

  //Calculate n00, where it is the count if empty N00 intervals not including unmatched p2
  //p2 note not included in target intervals

  //Seems like we don't need it - FIX
  // List<DateTime> unmatchedP2NoteTimes = [
  //   for (int index in matchResult['notesNotIncluded']!) p2NoteTimes[index]
  // ];
  // print(
  //     'p2 notes not included in target intervals (${unmatchedP2NoteTimes.length}): $unmatchedP2NoteTimes');

  //How many NOO intervals does not include any of p2 notes
  Map<String, Set<int>> emptyIntervalsMatch =
      matchIntervalsWithNoteTimes(emptyTargetIntervals, p2NoteTimes);
  n00 = emptyIntervalsMatch['intervalsNotInclude']!.length;

  //Need to check if intervals do really not include any of p2 note
  List<DateTimeRange> emptyN00IntervalNotInclude = [
    for (int index in emptyIntervalsMatch['intervalsNotInclude']!)
      emptyTargetIntervals[index]
  ];
  print(
      'Empty N00 Intervals NOT INCLUDE p2: (${emptyN00IntervalNotInclude.length}): $emptyN00IntervalNotInclude');

  phi = calculatePhi(n00: n00, n01: n01, n10: n10, n11: n11);

  print('END OF CALCULATION');
  print('----------------------------------------');

  return {
    'n00': n00,
    'n01': n01,
    'n10': n10,
    'n11': n11,
    'phi': phi,
  };
}

List<DateTime> getNoteTimes(Parameter parameter, DateTimeRange range) {
  List<DateTime> noteTimes = [];
  for (Note note in parameter.notes.values) {
    DateTime noteTime = getNoteTime(note);
    if (includedInRange(noteTime, range)) {
      noteTimes.add(noteTime);
    }
  }
  return noteTimes;
}

bool includedInRange(DateTime time, DateTimeRange range) {
  return (time == range.start || time.isAfter(range.start)) &&
      time.isBefore(range.end);
}
