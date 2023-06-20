import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/parameter.dart';
import '../services/analytics_utilities/common_analytics_utilities.dart';
import '../services/analytics_utilities/daily_correlation_calculation.dart';
import 'view_utilities/text_utilities.dart';
import 'view_utilities/ui_analytics_utilities/contingency_matrix.dart';
import 'view_utilities/ui_widgets.dart';

// Caluclates fixed daily correlation between the parameters

class DailyCorrelationScreen extends StatefulWidget {
  const DailyCorrelationScreen({required this.parameters, super.key});

  final List<Parameter> parameters;

  @override
  State<DailyCorrelationScreen> createState() => _DailyCorrelationScreenState();
}

class _DailyCorrelationScreenState extends State<DailyCorrelationScreen> {
  late DateTimeRange _rangeForCalculation;
  late DateTimeRange _rangeForUI;
  //lag can be choosen between 0 (same day) or 1 (next day)
  int _lag = 0;
  bool _calculated = false;

  Map _correlationResult = {};

  @override
  void initState() {
    super.initState();
    _rangeForCalculation = _calculateDefaultDailyRangeFor2(widget.parameters);
    _rangeForUI = DateTimeRange(
        start: startOfDay(_rangeForCalculation.start),
        end: startOfDay(
            _rangeForCalculation.end.subtract(const Duration(days: 1))));
    //calculate _range
  }

  //calculate default daily range based on 2 selected parameters:
  //takes the intersection of ranges from the start of observations
  DateTimeRange _calculateDefaultDailyRangeFor2(List<Parameter> params) {
    DateTime now = DateTime.now();
    DateTime defaultStartDate;

    if (params[0].hasEvents && params[1].hasEvents) {
      //time of the first note of parameter 1
      DateTime p1FirstNoteTime =
          params[0].firstNote!.durationType == DurationType.moment
              ? params[0].firstNote!.moment!
              : params[0].firstNote!.duration!.end;

      //time of the first note of parameter 2
      DateTime p2FirstNoteTime =
          params[1].firstNote!.durationType == DurationType.moment
              ? params[1].firstNote!.moment!
              : params[1].firstNote!.duration!.end;

      defaultStartDate = earliestDate([
        oldestDate([params[0].createdTime, p1FirstNoteTime]),
        oldestDate([params[1].createdTime, p2FirstNoteTime])
      ]);
    } else {
      defaultStartDate = now;
    }

    return DateTimeRange(start: defaultStartDate, end: now);
  }

  @override
  Widget build(BuildContext context) {
    Parameter p1 = widget.parameters[0];
    Parameter p2 = widget.parameters[1];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Correlation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outlined),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const AlertDialog(
                    title: Text('Daily correlations manual'),
                    content: SingleChildScrollView(
                        child: DailyCorrelationsManualContent())),
                barrierDismissible: true,
              );
            },
          ),
        ],
      ),
      body: Scrollbar(
          child: SingleChildScrollView(
              child: Center(
                  child: SizedBox(
                      width: 320,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 15),
                            SelectedParameterButton(
                              parameter: p1,
                              order: 1,
                            ),
                            const SizedBox(height: 15),
                            SelectedParameterButton(
                              parameter: p2,
                              order: 2,
                            ),
                            const SizedBox(height: 15),

                            //block for choosing lag
                            const Headline('Choose lag:'),
                            PopupMenuButton(
                                child: Container(
                                  height: 40,
                                  width: 150,
                                  decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.blue)),
                                  padding:
                                      const EdgeInsets.fromLTRB(13, 5, 13, 5),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.stacked_line_chart,
                                          size: 24, color: Colors.blue),
                                      Text(_lag == 0 ? 'same day' : 'next day',
                                          style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.blue,
                                              fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                ),
                                onSelected: (int value) {
                                  if (value != _lag) {
                                    setState(() {
                                      _calculated = false;
                                      _lag = value;
                                    });
                                  }
                                },
                                itemBuilder: (BuildContext context) =>
                                    <PopupMenuEntry<int>>[
                                      PopupMenuItem<int>(
                                        value: 0,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text('same day',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.w500)),
                                            Text(
                                                'Show if "${p1.name}" and "${p2.name}" occurances on the same day correlate.'),
                                            const SizedBox(height: 5),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem<int>(
                                        value: 1,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text('next day',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.w500)),
                                            Text(
                                                'Show if "${p1.name}" occurance correlate with "${p2.name}" occurance on the next day.'),
                                            const SizedBox(height: 5),
                                          ],
                                        ),
                                      ),
                                    ]),

                            //"Calculate" Control button
                            const SizedBox(height: 25),
                            ControlButton(
                                title: _calculated
                                    ? 'Result:'
                                    : 'Calculate correlation',
                                onPressed: () {
                                  setState(() {
                                    _correlationResult =
                                        calculateDailyCorrelation(
                                            p1: p1,
                                            p2: p2,
                                            range: _rangeForCalculation,
                                            lag: _lag);
                                    _calculated = true;
                                  });
                                }),
                            if (_calculated)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 25),
                                  Headline(
                                      'Dates range (${_rangeForUI.duration.inDays + 1}): '),
                                  Text(toContextualDurationDates(DateTimeRange(
                                      start: _rangeForUI.start,
                                      end: _rangeForUI.end))),
                                  const SizedBox(height: 15),
                                  const Headline('Contingency matrix:'),
                                  DailyContingencyMatrix(
                                      p1: p1,
                                      p2: p2,
                                      lag: _lag,
                                      n00: _correlationResult["n00"],
                                      n10: _correlationResult["n10"],
                                      n01: _correlationResult["n01"],
                                      n11: _correlationResult["n11"]),
                                  const SizedBox(height: 25),
                                  Headline(
                                      'Phi coefficient: ${NumberFormat().format(_correlationResult["phi"])}'),
                                  Headline(explainDailyCorrelationResults(
                                      _correlationResult["phi"], p1, p2, _lag)),
                                  const SizedBox(height: 25),
                                ],
                              ),
                          ]))))),
    );
  }
}

String explainDailyCorrelationResults(
    phi, Parameter p1, Parameter p2, int lag) {
  String correlationExplanation = '';
  String p1Name = '"${p1.name}"';
  String p2Name = '"${p2.name}"';
  String betweenText = '';

  //understand how to explain correlation
  if (phi < -0.5) {
    correlationExplanation = 'strong negative (phi < -0.5)';
  } else if (phi < -0.33) {
    correlationExplanation = 'medium negative (-0.5 < phi < -0.33)';
  } else if (phi < 0.33) {
    correlationExplanation = 'weak (-0.33 < phi < 0.33)';
  } else if (phi < 0.5) {
    correlationExplanation = 'medium positive (0.33 < phi < 0.5)';
  } else {
    correlationExplanation = 'strong positive (phi > 0.5)';
  }

  //understand how to explain lag
  if (lag == 0) {
    betweenText = '$p1Name and $p2Name occuring on the same day.';
  } else if (lag == 1) {
    betweenText = '$p2Name occuring the next day after $p1Name';
  } else {
    betweenText = '$p1Name and $p2Name occuring with the lag of $lag.';
  }

  //There is a weak negative interconnection between p1 and p2 occuring on the same day.

  return 'There is a $correlationExplanation interconnection between $betweenText';
}

class DailyContingencyMatrix extends StatelessWidget {
  const DailyContingencyMatrix(
      {super.key,
      required this.p1,
      required this.p2,
      required this.n00,
      required this.n10,
      required this.n01,
      required this.n11,
      this.lag = 0});

  final Parameter p1;
  final Parameter p2;
  final int n00;
  final int n10;
  final int n01;
  final int n11;
  final int lag;

  @override
  Widget build(BuildContext context) {
    final int observations = n00 + n10 + n11 + n01;

    return ContingencyMatrix(
        firstParamColor: p1.decoration.color,
        secondParamColor: p2.decoration.color,
        n00: n00,
        n10: n10,
        n01: n01,
        n11: n11,
        explainN00: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                  title: Column(children: [
                    SmallParameterLabel(
                        parameter: p1,
                        leadingIcon: const Icon(Icons.event_busy)),
                    const SizedBox(height: 10),
                    SmallParameterLabel(
                        parameter: p2,
                        leadingIcon: const Icon(Icons.event_busy)),
                  ]),
                  content: SingleChildScrollView(
                      child: Text(lag == 0
                          ? '$n00 - number of days (of $observations observed), when neither "${p1.name}" or "${p2.name}" occured'
                          : '$n00 - number of times (of $observations observed), when neither "${p1.name}" or "${p2.name}" occured on consequent days'))),
              barrierDismissible: true,
            ),
        explainN01: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                  title: Column(children: [
                    SmallParameterLabel(
                        parameter: p1,
                        leadingIcon: const Icon(Icons.event_busy)),
                    const SizedBox(height: 10),
                    SmallParameterLabel(
                        parameter: p2,
                        leadingIcon: const Icon(Icons.event_available)),
                  ]),
                  content: SingleChildScrollView(
                      child: Text(lag == 0
                          ? '$n01 - number of days (of $observations observed), when "${p1.name}" did not occured, but "${p2.name}" did occure'
                          : '$n01 - number of times (of $observations observed), when "${p1.name}" did not occured but "${p2.name}" occured the next day'))),
              barrierDismissible: true,
            ),
        explainN11: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                  title: Column(children: [
                    SmallParameterLabel(
                        parameter: p1,
                        leadingIcon: const Icon(Icons.event_available)),
                    const SizedBox(height: 10),
                    SmallParameterLabel(
                        parameter: p2,
                        leadingIcon: const Icon(Icons.event_available)),
                  ]),
                  content: SingleChildScrollView(
                      child: Text(lag == 0
                          ? '$n11 - number of days (of $observations observed), when "${p1.name}" and "${p2.name}" occured the same day'
                          : '$n11 - number of times (of $observations observed), when "${p2.name}" occured the next day after "${p1.name}" occured'))),
              barrierDismissible: true,
            ),
        explainN10: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                  title: Column(children: [
                    SmallParameterLabel(
                        parameter: p1,
                        leadingIcon: const Icon(Icons.event_available)),
                    const SizedBox(height: 10),
                    SmallParameterLabel(
                        parameter: p2,
                        leadingIcon: const Icon(Icons.event_busy)),
                  ]),
                  content: SingleChildScrollView(
                      child: Text(lag == 0
                          ? '$n10 - number of days (of $observations observed), when "${p1.name}" occured, but "${p2.name}" did not occure'
                          : '$n11 - number of times (of $observations observed), when "${p1.name}" occured, but the next day "${p2.name}" did not occure'))),
              barrierDismissible: true,
            ));
  }
}

class SelectedParameterButton extends StatelessWidget {
  const SelectedParameterButton(
      {super.key, required this.parameter, this.order});

  final Parameter parameter;
  final int? order;

  @override
  Widget build(BuildContext context) {
    return ParameterButtonTemplate(
        parameter: parameter,
        trailing: order != null
            ? SizedBox(
                width: 48,
                child: Center(
                    child: Text(
                  '#$order',
                  style: const TextStyle(
                    color: Color(0xFF7B7B7B),
                    fontWeight: FontWeight.w500,
                    fontSize: 17,
                  ),
                )))
            : null);
  }
}

class DailyCorrelationsManualContent extends StatelessWidget {
  const DailyCorrelationsManualContent({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SizedBox(height: 15),
          Text(
              'This tool calculates the content of a contingency matrix and phi coefficient between occurances of parameter 1 (p1) and parameter 2 (p2) events in every day of research timerange.',
              style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 15),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                    text: "Research timerange ",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                  text:
                      "is calculated as an intersection of the parameter ranges: from the day of start of observations till yesterday.",
                ),
              ],
            ),
          ),
          SizedBox(height: 15),
          Text.rich(TextSpan(children: [
            TextSpan(
              text:
                  "Each day is checked for the occurance of parameters events to calculate values of the ",
            ),
            TextSpan(
                text: "contingency matrix",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ])),
          SizedBox(height: 15),
          Text.rich(TextSpan(children: [
            TextSpan(
              text: "If choosen lag is ",
            ),
            TextSpan(
                text: "next day",
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(
              text:
                  ", then only occurances of p2 on the next adjacent day are counted.",
            ),
          ])),
          SizedBox(height: 15),
          Text.rich(TextSpan(children: [
            TextSpan(
                text: "Phi coefficient",
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(
              text:
                  " is calculated by the standard formula from statistics: (n11 *  n00 - n10 * n01) / (sqrt((n11 + n10) * (n11 + n01) * (n10 + n00) * (n01 + n00))).",
            ),
          ])),
        ]);
  }
}

class ControlButton extends StatelessWidget {
  const ControlButton(
      {super.key, required this.title, required this.onPressed});

  final String title;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Ink(
        height: 60,
        width: 320,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xFF2196F3),
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              offset: Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onPressed,
          child: Center(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),
        ));
  }
}
