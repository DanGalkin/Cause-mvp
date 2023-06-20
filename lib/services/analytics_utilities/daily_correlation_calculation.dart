import 'dart:math';

import 'package:flutter/material.dart';

import '../../model/note.dart';
import '../../model/parameter.dart';
import 'common_analytics_utilities.dart';

Map<String, dynamic> calculateDailyCorrelation(
    {required Parameter p1,
    required Parameter p2,
    required DateTimeRange range,
    int lag = 0}) {
  //we start counting from the first day of range
  DateTime firstDayOfObservations = startOfDay(range.start);

  //Usually range.end is DateTime.now(), so the last day observed is previous day
  DateTime lastDayOfObservations =
      startOfDay(range.end.subtract(Duration(days: (1 + lag))));

  //set of days observed in milliseconds(to make them comparable)
  Set<int> observationDaysMS = {};
  for (int i = 0;
      firstDayOfObservations
              .add(Duration(days: i))
              .isBefore(lastDayOfObservations) ||
          firstDayOfObservations
              .add(Duration(days: i))
              .isAtSameMomentAs(lastDayOfObservations);
      i++) {
    observationDaysMS.add(
        firstDayOfObservations.add(Duration(days: i)).millisecondsSinceEpoch);
  }

  //set of days p1 occured in
  Set<int> daysP1Occured = {};
  for (Note note in p1.notes.values) {
    //get note time in MS
    daysP1Occured.add(startOfDay(getNoteTime(note)).millisecondsSinceEpoch);
  }

  //set of (lagged) days p2 occured in
  Set<int> daysP2Occured = {};
  for (Note note in p2.notes.values) {
    //get note time in MS
    daysP2Occured.add(
        startOfDay(getNoteTime(note).subtract(Duration(days: lag)))
            .millisecondsSinceEpoch);
  }

  int n01 = 0;
  int n00 = 0;
  int n10 = 0;
  int n11 = 0;
  double phi;

  n11 = observationDaysMS
      .intersection(daysP1Occured)
      .intersection(daysP2Occured)
      .length;

  n10 = observationDaysMS
      .intersection(daysP1Occured)
      .difference(daysP2Occured)
      .length;
  n01 = observationDaysMS
      .intersection(daysP2Occured)
      .difference(daysP1Occured)
      .length;

  n00 = observationDaysMS
      .difference(daysP1Occured)
      .difference(daysP2Occured)
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

  print(firstDayOfObservations);
  print(lastDayOfObservations);
  print(observationDaysMS);
  print(daysP1Occured);
  print(daysP2Occured);

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
