import 'dart:async';

import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'package:intl/intl.dart';

import '../../model/parameter.dart';
import '../../model/note.dart';
import 'picker_widgets.dart';
import 'ui_widgets.dart';

class OneParamChart extends StatefulWidget {
  const OneParamChart(
      {required this.parameter,
      this.width = 320,
      this.height = 300,
      this.tickFrequency = 1,
      this.showTicks = 12,
      super.key});

  final Parameter parameter;
  final double width;
  final double height;

  //tickFrequency - how many ticks will be shown in a day on X-axis
  final double tickFrequency;

  //how many ticks will be visible of a graph at first build
  final int showTicks;

  @override
  State<OneParamChart> createState() => _OneParamChartState();
}

class _OneParamChartState extends State<OneParamChart> {
  //tickFrequency - how many ticks will be shown in a day on X-axis
  double _selectedTickFrequency = 1;

  //refactor - don't think should be there
  final gestureChannel = StreamController<GestureSignal>.broadcast();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const SizedBox(height: 15),
      ChartLabel(parameter: widget.parameter),
      const SizedBox(height: 5),
      Container(
        height: widget.height,
        width: widget.width,
        decoration:
            BoxDecoration(border: Border.all(color: Colors.purple, width: 1)),
        child: SingleParamChart(
            parameter: widget.parameter,
            tickFrequency: _selectedTickFrequency,
            gestureChannel: gestureChannel,
            timeAxisStart: widget.parameter.createdTime),
      ),
      const SizedBox(height: 15),
      TickFrequencyPicker(
        selectedTickFrequency: _selectedTickFrequency,
        onChanged: (value) {
          setState(() {
            _selectedTickFrequency = value!;
          });
        },
      ),
    ]);
  }
}

String? hoursTicksFormatter(DateTime time) {
  if (time == startOfDay(time)) {
    if (time.day == 1) {
      return DateFormat.MMM().format(time);
    } else {
      return DateFormat.d().format(time);
    }
  } else {
    return DateFormat.Hm().format(time);
  }
}

String? daysTicksFormatter(DateTime time) {
  return time.day == 1
      ? DateFormat.MMM().format(time)
      : DateFormat.d().format(time);
}

class SingleParamChart extends StatelessWidget {
  const SingleParamChart({
    Key? key,
    required this.parameter,
    required this.tickFrequency,
    required this.gestureChannel,
    this.showTicks = 12,
    required this.timeAxisStart,
  }) : super(key: key);

  final Parameter parameter;
  final double tickFrequency;
  final int showTicks;
  final DateTime timeAxisStart;
  final StreamController<GestureSignal>? gestureChannel;

  @override
  Widget build(BuildContext context) {
    //calculate data for chart
    var datum = getChartData(parameter);

    //calculating accessor
    dynamic Function(Map<dynamic, dynamic>) accessor;
    Scale<dynamic, num>? scale;
    switch (parameter.varType) {
      case VarType.binary:
        {
          accessor = (Map map) => map['name'] as String;
          scale = null;
        }
        break;
      case VarType.quantitative:
        {
          accessor = (Map map) => map['value'] as num;
          scale = LinearScale(formatter: (v) => '$v ${parameter.metric}');
        }
        break;
      case VarType.categorical:
        {
          accessor = (Map map) => map['value'] as String;
          scale = OrdinalScale(
              values: parameter.categories!.list
                  .map((category) => category.name)
                  .toList());
        }
        break;
      case VarType.ordinal:
        {
          accessor = (Map map) => map['value'] as String;
          scale = OrdinalScale(
              values: parameter.categories!.list
                  .map((category) => category.name)
                  .toList());
        }
        break;
      case VarType.unstructured:
        {
          accessor = (Map map) => map['name'] as String;
          scale = null;
        }
        break;
      default:
        {
          accessor = (_) {};
          scale = null;
        }
        break;
    }

    //formatter for Time axis labels
    final String? Function(DateTime) dateFormatter =
        tickFrequency > 1 ? hoursTicksFormatter : daysTicksFormatter;

    //calculate ticks from creation of parameter till now
    List<DateTime>? ticks = calculateTicks(
        start: parameter.createdTime, tickFrequency: tickFrequency);

    DateTime minTimeScale = startOfDay(timeAxisStart);
    //parameter for visible area of a graph depending on how many ticks till
    //today we want to show
    double horizontalRangeStart =
        getHorizontalRangeStart(timeAxisStart, tickFrequency, showTicks);

    //Set variables and PointElements for moment or durational parameters
    Map<String, Variable<Map<dynamic, dynamic>, dynamic>> variables;
    List<GeomElement<Shape>> elements;
    if (parameter.durationType == DurationType.moment) {
      variables = {
        'time': Variable(
            accessor: (Map map) => map['time'] as DateTime,
            scale: TimeScale(
              formatter: dateFormatter,
              ticks: ticks,
              min: minTimeScale,
              max: DateTime.now(),
            )),
        'value': Variable(
          accessor: accessor,
          scale: scale,
        ),
      };

      elements = [
        PointElement(
          position: Varset('value') * Varset('time'),
          color: ColorAttr(value: parameter.decoration.color),
          elevation: SizeAttr(value: 1),
        )
      ];
    } else {
      Scale<dynamic, num>? timeScale = TimeScale(
        formatter: dateFormatter,
        ticks: ticks,
        min: minTimeScale,
        max: DateTime.now(),
      );

      variables = {
        'start': Variable(
            accessor: (Map map) => map['start'] as DateTime, scale: timeScale),
        'end': Variable(
            accessor: (Map map) => map['end'] as DateTime, scale: timeScale),
        'value': Variable(
          accessor: accessor,
          scale: scale,
        ),
      };

      elements = [
        IntervalElement(
            position: Varset('value') * (Varset('start') + Varset('end')),
            shape: ShapeAttr(
                value: RectShape(borderRadius: BorderRadius.circular(2))),
            size: SizeAttr(value: 3),
            color: ColorAttr(value: parameter.decoration.color),
            elevation: SizeAttr(value: 1)),
        PointElement(
          position: Varset('value') * Varset('start'),
          color: ColorAttr(value: parameter.decoration.color),
          elevation: SizeAttr(value: 1),
        ),
        PointElement(
          position: Varset('value') * Varset('end'),
          color: ColorAttr(value: parameter.decoration.color),
          elevation: SizeAttr(value: 1),
        ),
      ];
    }

    return Chart(
      data: datum,
      variables: variables,
      elements: elements,
      axes: [
        AxisGuide(
          line: StrokeStyle(
            color: const Color(0xffe8e8e8),
          ),
          label: LabelStyle(
            offset: const Offset(-7.5, 0),
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xff808080),
            ),
            textAlign: TextAlign.end,
            maxWidth: 60,
            maxLines: 2,
            ellipsis: '...',
          ),
          grid: StrokeStyle(
            color: const Color(0xffe8e8e8),
            dash: [4, 2],
          ),
        ),
        AxisGuide(
          line: StrokeStyle(
            color: const Color(0xffe8e8e8),
          ),
          label: LabelStyle(
            offset: const Offset(0, 7.5),
            style: const TextStyle(
              fontSize: 7,
              color: Color(0xff808080),
            ),
          ),
          grid: StrokeStyle(
            color: const Color(0xffe8e8e8),
            dash: [4, 2],
          ),
        ),
      ],
      coord: RectCoord(
        transposed: true,
        horizontalRange: [horizontalRangeStart, 1],
        horizontalRangeUpdater: Defaults.horizontalRangeSignal,
      ),
      gestureChannel: gestureChannel,
    );
  }
}

class TwoParamsChart extends StatefulWidget {
  const TwoParamsChart(
      {required this.parameters,
      this.width = 320,
      this.height = 600,
      this.tickFrequency = 1,
      this.showTicks = 12,
      super.key});

  final List<Parameter> parameters;
  final double width;
  final double height;

  //tickFrequency -how many ticks will be shown in a day on X-axis
  final double tickFrequency;

  //how many ticks will be visible of a graph at first build
  final int showTicks;

  @override
  State<TwoParamsChart> createState() => _TwoParamsChartState();
}

class _TwoParamsChartState extends State<TwoParamsChart> {
  double _selectedTickFrequency = 1;

  final gestureChannel = StreamController<GestureSignal>.broadcast();

  @override
  Widget build(BuildContext context) {
    DateTime timeAxisStart = widget.parameters[0].createdTime
            .isAfter(widget.parameters[1].createdTime)
        ? widget.parameters[1].createdTime
        : widget.parameters[0].createdTime;

    return Column(children: [
      const SizedBox(height: 10),
      SizedBox(
        width: 320,
        // decoration:
        //     BoxDecoration(border: Border.all(color: Colors.purple, width: 1)),
        child: Column(
          children: [
            Align(
                alignment: Alignment.centerLeft,
                child: ChartLabel(parameter: widget.parameters[0])),
            const SizedBox(height: 5),
            SizedBox(
              height: 200,
              width: 320,
              child: SingleParamChart(
                  parameter: widget.parameters[0],
                  tickFrequency: _selectedTickFrequency,
                  gestureChannel: gestureChannel,
                  timeAxisStart: timeAxisStart),
            ),
            const SizedBox(height: 10),
            Align(
                alignment: Alignment.centerLeft,
                child: ChartLabel(parameter: widget.parameters[1])),
            const SizedBox(height: 5),
            SizedBox(
              height: 200,
              width: 320,
              child: SingleParamChart(
                  parameter: widget.parameters[1],
                  tickFrequency: _selectedTickFrequency,
                  gestureChannel: gestureChannel,
                  timeAxisStart: timeAxisStart),
            ),
            TickFrequencyPicker(
              selectedTickFrequency: _selectedTickFrequency,
              onChanged: (value) {
                setState(() {
                  _selectedTickFrequency = value!;
                });
              },
            ),
          ],
        ),
      )
    ]);
  }
}

// Takes all the notes of a parameter and creates a list of Map with timestamp,
// value and name of the parameter
List<Map<String, dynamic>> getChartData(Parameter parameter) {
  List<Note> notes = parameter.notes.values.toList();
  List<Map<String, dynamic>> data = [];
  for (Note note in notes) {
    DateTime? timestamp;
    DateTime? startTime;
    DateTime? endTime;
    var value;

    switch (note.varType) {
      case VarType.binary:
        {
          value = note.value['binary']['value'];
        }
        break;
      case VarType.quantitative:
        {
          value = note.value['quantitative']['value'];
        }
        break;
      case VarType.categorical:
        {
          value = note.value['categorical']['name'];
        }
        break;
      case VarType.ordinal:
        {
          value = note.value['ordinal']['name'];
        }
        break;
      case VarType.unstructured:
        {
          value = note.value['unstructured']['value'];
        }
        break;
      default:
        {
          print('Invalid case');
        }
        break;
    }

    Map<String, dynamic> item;

    if (note.durationType == DurationType.moment) {
      timestamp = note.moment;
      item = {'time': timestamp, 'name': parameter.name, 'value': value};
    } else {
      startTime = note.duration!.start;
      endTime = note.duration!.end;
      item = {
        'start': startTime,
        'end': endTime,
        'name': parameter.name,
        'value': value
      };
    }
    data.add(item);
  }
  return data;
}

dynamic getDefaultValue(parameter) {
  List<Note> notes = parameter.notes.values.toList();
  if (notes.isEmpty) {
    return parameter.name;
  }
  var value;
  switch (parameter.varType) {
    case VarType.binary:
      {
        value = notes[0].value['binary']['value'];
      }
      break;
    case VarType.quantitative:
      {
        value = notes[0].value['quantitative']['value'];
      }
      break;
    case VarType.categorical:
      {
        value = notes[0].value['categorical']['name'];
      }
      break;
    case VarType.ordinal:
      {
        value = notes[0].value['ordinal']['name'];
      }
      break;
    case VarType.unstructured:
      {
        value = notes[0].value['unstructured']['value'];
      }
      break;
    default:
      {
        print('Invalid case');
      }
      break;
  }
  return value;
}

List<Map<String, dynamic>> getChartDataForTwo(
    Parameter parameter1, Parameter parameter2) {
  List<Note> notes1 = parameter1.notes.values.toList();
  List<Note> notes2 = parameter2.notes.values.toList();
  var defaultValue1 = getDefaultValue(parameter1);
  var defaultValue2 = getDefaultValue(parameter2);

  List<Map<String, dynamic>> data = [];
  for (Note note in notes1) {
    DateTime? timestamp;
    var value;
    note.durationType == DurationType.moment
        ? timestamp = note.moment
        : timestamp = note.duration!.start;
    switch (note.varType) {
      case VarType.binary:
        {
          value = note.value['binary']['value'];
        }
        break;
      case VarType.quantitative:
        {
          value = note.value['quantitative']['value'];
        }
        break;
      case VarType.categorical:
        {
          value = note.value['categorical']['name'];
        }
        break;
      case VarType.ordinal:
        {
          value = note.value['ordinal']['name'];
        }
        break;
      case VarType.unstructured:
        {
          value = note.value['unstructured']['value'];
        }
        break;
      default:
        {
          print('Invalid case');
        }
        break;
    }
    Map<String, dynamic> item = {
      'time': timestamp,
      'name1': parameter1.name,
      'value1': value,
      'name2': parameter2.name,
      'value2': defaultValue2,
      'var': 1,
    };
    data.add(item);
  }
  for (Note note in notes2) {
    DateTime? timestamp;
    var value;
    note.durationType == DurationType.moment
        ? timestamp = note.moment
        : timestamp = note.duration!.start;
    switch (note.varType) {
      case VarType.binary:
        {
          value = note.value['binary']['value'];
        }
        break;
      case VarType.quantitative:
        {
          value = note.value['quantitative']['value'];
        }
        break;
      case VarType.categorical:
        {
          value = note.value['categorical']['name'];
        }
        break;
      case VarType.ordinal:
        {
          value = note.value['ordinal']['name'];
        }
        break;
      case VarType.unstructured:
        {
          value = note.value['unstructured']['value'];
        }
        break;
      default:
        {
          print('Invalid case');
        }
        break;
    }
    Map<String, dynamic> item = {
      'time': timestamp,
      'name1': parameter1.name,
      'value1': defaultValue1,
      'name2': parameter2.name,
      'value2': value,
      'var': 2,
    };
    data.add(item);
  }
  print(data);
  return data;
}

List<DateTime> calculateTicks(
    {required DateTime start, DateTime? end, double tickFrequency = 1}) {
  //number of minutes between ticks.
  //Works well only when tickFrequency is a divider of 1440
  // 1440 - minutes in 24 hours
  int deltaMinutes = (1440 / tickFrequency).round();

  List<DateTime> ticks = [];

  for (DateTime dayTick = startOfDay(start);
      dayTick.isBefore(end ?? DateTime.now());
      dayTick = nextDay(dayTick)) {
    ticks.add(dayTick);
    DateTime nextDayTick = nextDay(dayTick);
    for (DateTime hoursTick = dayTick.add(Duration(minutes: deltaMinutes));
        hoursTick.isBefore(end ?? DateTime.now()) &&
            hoursTick.isBefore(nextDayTick);
        hoursTick = hoursTick.add(Duration(minutes: deltaMinutes))) {
      ticks.add(hoursTick);
    }
  }
  return ticks;
}

DateTime nextDay(DateTime day) {
  return DateTime(day.year, day.month, day.day + 1);
}

DateTime startOfDay(DateTime time) {
  return DateTime(time.year, time.month, time.day);
}

Set<DateTime> daysFromRange(DateTimeRange range) {
  int totalDays = range.duration.inDays + 1; //it is a bad calculation?
  Set<DateTime> days = {};
  DateTime firstDay = startOfDay(range.start);
  for (int i = 0; i < totalDays; i++) {
    days.add(firstDay.add(Duration(days: i)));
  }
  return days;
}

double getHorizontalRangeStart(
    DateTime timeAxisStart, double tickFrequency, int showTicks) {
  int totalMinutesInRange = DateTime.now().difference(timeAxisStart).inMinutes;
  double tickPeriods = totalMinutesInRange / 1440 * tickFrequency;

  return (1 - tickPeriods / showTicks);
}

class ChartWidget extends StatefulWidget {
  const ChartWidget({this.parameters = const [], super.key});

  final List<Parameter> parameters;

  @override
  State<ChartWidget> createState() => _ChartWidgetState();
}

class _ChartWidgetState extends State<ChartWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.parameters.isEmpty) {
      return Container();
    } else if (widget.parameters.length == 1) {
      return OneParamChart(
        parameter: widget.parameters[0],
      );
    } else {
      return TwoParamsChart(
        parameters: [widget.parameters[0], widget.parameters[1]],
      );
    }
  }
}
