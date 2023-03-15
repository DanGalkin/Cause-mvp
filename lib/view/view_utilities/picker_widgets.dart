import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'ui_widgets.dart';

class MomentPicker extends StatefulWidget {
  const MomentPicker({this.initialDateTime, required this.onChange, super.key});
  final DateTime? initialDateTime;
  final void Function(DateTime newMoment) onChange;

  @override
  State<MomentPicker> createState() => _MomentPickerState();
}

class _MomentPickerState extends State<MomentPicker> {
  DateTime _moment = DateTime.now();

  @override
  initState() {
    _moment = widget.initialDateTime ?? DateTime.now();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Headline('Select a moment:'),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Ink(
              height: 60,
              width: 145,
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue)),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () async {
                  final DateTime newTime = await _getDateSelection(
                      initialDateTime: _moment, context: context);
                  if (newTime != _moment) {
                    bool validationResult =
                        await _validateMomentSelection(newTime);
                    if (validationResult == true) {
                      setState(() {
                        _moment = newTime;
                      });
                      widget.onChange(newTime);
                    }
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.date_range, size: 24, color: Colors.blue),
                    const SizedBox(width: 12),
                    Text(DateFormat.MMMd().format(_moment),
                        style: const TextStyle(
                            fontSize: 20,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
            Ink(
              height: 60,
              width: 145,
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue)),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () async {
                  final DateTime newTime = await _getTimeSelection(
                      initialDateTime: _moment, context: context);
                  if (newTime != _moment) {
                    bool validationResult =
                        await _validateMomentSelection(newTime);
                    if (validationResult == true) {
                      setState(() {
                        _moment = newTime;
                      });
                      widget.onChange(newTime);
                    }
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.schedule, size: 24, color: Colors.blue),
                    const SizedBox(width: 12),
                    Text(DateFormat.Hm().format(_moment),
                        style: const TextStyle(
                            fontSize: 20,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Future<bool> _validateMomentSelection(DateTime moment) async {
    if (moment.isAfter(DateTime.now())) {
      final bool? alertResult = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text('Just a check'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: [
                      const Text('You have entered the date:'),
                      Text(DateFormat.yMMMd().add_Hm().format(moment)),
                      const Text('Are you sure event will occur in future?'),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Oops, no!'),
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                  ),
                  TextButton(
                    child: const Text('Sure'),
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                  ),
                ],
              ),
          barrierDismissible: true);
      if (alertResult == true || alertResult == null) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }
}

class DurationPicker extends StatefulWidget {
  const DurationPicker(
      {this.initialDateTimeRange, required this.onChange, super.key});
  final DateTimeRange? initialDateTimeRange;
  final void Function(DateTimeRange newDuration) onChange;

  @override
  State<DurationPicker> createState() => _DurationPickerState();
}

class _DurationPickerState extends State<DurationPicker> {
  DateTimeRange _duration =
      DateTimeRange(start: DateTime.now(), end: DateTime.now());

  @override
  initState() {
    _duration = widget.initialDateTimeRange ??
        DateTimeRange(start: DateTime.now(), end: DateTime.now());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Headline('Select a duration: Start time'),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Ink(
              height: 60,
              width: 145,
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue)),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () async {
                  final DateTime newTime = await _getDateSelection(
                      initialDateTime: _duration.start, context: context);
                  if (newTime != _duration.start) {
                    final bool validationResult =
                        await _validateDurationSelection(
                            newTime, _duration.end);
                    if (validationResult) {
                      DateTimeRange newDuration =
                          DateTimeRange(start: newTime, end: _duration.end);
                      setState(() {
                        _duration = newDuration;
                      });
                      widget.onChange(newDuration);
                    }
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.date_range, size: 24, color: Colors.blue),
                    const SizedBox(width: 12),
                    Text(DateFormat.MMMd().format(_duration.start),
                        style: const TextStyle(
                            fontSize: 20,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
            Ink(
              height: 60,
              width: 145,
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue)),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () async {
                  final DateTime newTime = await _getTimeSelection(
                      initialDateTime: _duration.start, context: context);
                  if (newTime != _duration.start) {
                    final bool validationResult =
                        await _validateDurationSelection(
                            newTime, _duration.end);
                    if (validationResult) {
                      DateTimeRange newDuration =
                          DateTimeRange(start: newTime, end: _duration.end);
                      setState(() {
                        _duration = newDuration;
                      });
                      widget.onChange(newDuration);
                    }
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.schedule, size: 24, color: Colors.blue),
                    const SizedBox(width: 12),
                    Text(DateFormat.Hm().format(_duration.start),
                        style: const TextStyle(
                            fontSize: 20,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          ]),
          const SizedBox(height: 15),
          const Headline('End time'),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Ink(
              height: 60,
              width: 145,
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue)),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () async {
                  final DateTime newTime = await _getDateSelection(
                      initialDateTime: _duration.end, context: context);
                  if (newTime != _duration.end) {
                    bool validationResult = await _validateDurationSelection(
                        _duration.start, newTime);
                    if (validationResult) {
                      DateTimeRange newDuration =
                          DateTimeRange(start: _duration.start, end: newTime);
                      setState(() {
                        _duration = newDuration;
                      });
                      widget.onChange(newDuration);
                    }
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.date_range, size: 24, color: Colors.blue),
                    const SizedBox(width: 12),
                    Text(DateFormat.MMMd().format(_duration.end),
                        style: const TextStyle(
                            fontSize: 20,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
            Ink(
              height: 60,
              width: 145,
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue)),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () async {
                  final DateTime newTime = await _getTimeSelection(
                      initialDateTime: _duration.end, context: context);
                  if (newTime != _duration.end) {
                    bool validationResult = await _validateDurationSelection(
                        _duration.start, newTime);
                    if (validationResult) {
                      DateTimeRange newDuration =
                          DateTimeRange(start: _duration.start, end: newTime);
                      setState(() {
                        _duration = newDuration;
                      });
                      widget.onChange(newDuration);
                    }
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.schedule, size: 24, color: Colors.blue),
                    const SizedBox(width: 12),
                    Text(DateFormat.Hm().format(_duration.end),
                        style: const TextStyle(
                            fontSize: 20,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Future<bool> _validateDurationSelection(
      DateTime startTime, DateTime endTime) async {
    if (startTime.isAfter(endTime)) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
            title: const Text('Oops!'),
            content: SingleChildScrollView(
              child: ListBody(
                children: const [
                  Text(
                      'Selected start time is after the end time. Please reconsider your selection.'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ]),
      );
      return false;
    } else if (startTime.isAfter(DateTime.now()) ||
        endTime.isAfter(DateTime.now())) {
      final bool? alertResult = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text('Just a check'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: [
                      const Text(
                          'Selected interval happens to end in the future:'),
                      Text(
                          'Start: ${DateFormat.yMMMd().add_Hm().format(startTime)}'),
                      Text(
                          'End: ${DateFormat.yMMMd().add_Hm().format(endTime)}'),
                      const Text('Are you sure event will occur in future?'),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Oops, no!'),
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                  ),
                  TextButton(
                    child: const Text('Sure'),
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                  ),
                ],
              ),
          barrierDismissible: true);
      if (alertResult == false || alertResult == null) {
        return false;
      } else {
        return true;
      }
    } else {
      return true;
    }
  }
}

Future<DateTime> _getDateSelection(
    {required DateTime initialDateTime, required BuildContext context}) async {
  final DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: initialDateTime,
      firstDate: DateTime(2000, 1),
      lastDate: DateTime(2024, 12),
      helpText: 'Select a date');
  if (newDate != null) {
    final DateTime newMoment = DateTime(
      newDate.year,
      newDate.month,
      newDate.day,
      initialDateTime.hour,
      initialDateTime.minute,
    );
    return newMoment;
  } else {
    return initialDateTime;
  }
}

Future<DateTime> _getTimeSelection(
    {required DateTime initialDateTime, required BuildContext context}) async {
  final TimeOfDay? newTime = await showTimePicker(
      context: context, initialTime: TimeOfDay.fromDateTime(initialDateTime));
  if (newTime != null) {
    final DateTime newMoment = DateTime(
      initialDateTime.year,
      initialDateTime.month,
      initialDateTime.day,
      newTime.hour,
      newTime.minute,
    );
    return newMoment;
  } else {
    return initialDateTime;
  }
}

class TickFrequencyPicker extends StatelessWidget {
  const TickFrequencyPicker({
    super.key,
    required this.selectedTickFrequency,
    required this.onChanged,
  });

  final double selectedTickFrequency;
  final void Function(double?) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Headline('Select scale'),
        RadioListTile<double>(
          title: const Text('1 day'),
          value: 1,
          groupValue: selectedTickFrequency,
          onChanged: onChanged,
        ),
        RadioListTile<double>(
          title: const Text('6 hours'),
          value: 4,
          groupValue: selectedTickFrequency,
          onChanged: onChanged,
        ),
        RadioListTile<double>(
          title: const Text('1 hour'),
          value: 24,
          groupValue: selectedTickFrequency,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
