import 'package:flutter/material.dart';
import '../../model/note.dart';

import 'package:intl/intl.dart';

import '../../model/parameter.dart';

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool isSameYear(DateTime other) {
    return year == other.year;
  }

  bool isToday() {
    DateTime other = DateTime.now();
    return year == other.year && month == other.month && day == other.day;
  }

  bool isYesterday() {
    DateTime other = DateTime.now();
    return year == other.year && month == other.month && day == (other.day - 1);
  }
}

String toContextualMoment(DateTime date) {
  if (date.isToday()) {
    return 'Today, ${DateFormat.Hm().format(date)}';
  }

  if (date.isYesterday()) {
    return 'Yesterday, ${DateFormat.Hm().format(date)}';
  }

  if (date.isSameYear(DateTime.now())) {
    return DateFormat.MMMd().add_Hm().format(date);
  }

  return DateFormat.yMMMd().add_Hm().format(date);
}

String toContextualDate(DateTime date) {
  if (date.isToday()) {
    return 'Today';
  }

  if (date.isYesterday()) {
    return 'Yesterday';
  }

  if (date.isSameYear(DateTime.now())) {
    return DateFormat.MMMd().format(date);
  }

  return DateFormat.yMMMd().format(date);
}

String toContextualDurationDates(DateTimeRange duration) {
  if (duration.start.isSameDate(duration.end) && duration.start.isToday()) {
    return 'Today';
  }

  if (duration.start.isSameDate(duration.end) && duration.start.isYesterday()) {
    return 'Yesterday';
  }

  if (duration.start.isSameDate(duration.end) &&
      duration.start.isSameYear(DateTime.now())) {
    return DateFormat.MMMd().format(duration.start);
  }

  if (duration.start.isSameYear(duration.end) &&
      duration.start.isSameYear(DateTime.now())) {
    return '${DateFormat.MMMd().format(duration.start)} - ${DateFormat.MMMd().format(duration.end)}';
  }

  return '${DateFormat.yMMMd().format(duration.start)} - ${DateFormat.yMMMd().format(duration.end)}';
}

String toContextualDuration(DateTimeRange duration) {
  if (duration.start.isSameDate(duration.end) && duration.start.isToday()) {
    return 'Today, ${DateFormat.Hm().format(duration.start)} - ${DateFormat.Hm().format(duration.end)}';
  }

  if (duration.start.isSameDate(duration.end) && duration.start.isYesterday()) {
    return 'Yesterday, ${DateFormat.Hm().format(duration.start)} - ${DateFormat.Hm().format(duration.end)}';
  }

  if (duration.start.isSameDate(duration.end) &&
      duration.start.isSameYear(DateTime.now())) {
    return '${DateFormat.MMMd().format(duration.start)}, ${DateFormat.Hm().format(duration.start)} - ${DateFormat.Hm().format(duration.end)}';
  }

  if (duration.start.isSameYear(duration.end) &&
      duration.start.isSameYear(DateTime.now())) {
    return '${DateFormat.MMMd().add_Hm().format(duration.start)} - ${DateFormat.MMMd().add_Hm().format(duration.end)}';
  }

  return '${DateFormat.yMMMd().add_Hm().format(duration.start)} - ${DateFormat.yMMMd().add_Hm().format(duration.end)}';
}

String getLastNoteString(Note note) {
  if (note.durationType == DurationType.duration) {
    return toContextualDuration(note.duration!);
  }

  if (note.varType == VarType.binary) {
    return toContextualMoment(note.moment!);
  }

  if (note.varType == VarType.categorical) {
    return '${toContextualMoment(note.moment!)}: ${note.value['categorical']['name']}';
  }

  if (note.varType == VarType.ordinal) {
    return '${toContextualMoment(note.moment!)}: ${note.value['ordinal']['name']}';
  }

  if (note.varType == VarType.quantitative) {
    return '${toContextualMoment(note.moment!)}: ${note.value['quantitative']['value']} ${note.value['quantitative']['metric']}';
  }

  if (note.varType == VarType.unstructured) {
    return toContextualMoment(note.moment!);
  }

  return '';
}

String showStartOfRecording(Parameter parameter) {
  if (parameter.recordState.recording == false) {
    return '';
  }

  DateTime startMoment = parameter.recordState.startedAt!;
  return 'Started: ${toContextualMoment(startMoment)}';
}
