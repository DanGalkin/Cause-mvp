import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/parameter.dart';
import '../services/analytics_utilities/common_analytics_utilities.dart';
import '../services/analytics_utilities/correlation_calculation.dart';
import 'view_utilities/ui_analytics_utilities/contingency_matrix.dart';
import 'view_utilities/ui_widgets.dart';

class FloatingCorrelationScreen extends StatefulWidget {
  const FloatingCorrelationScreen({required this.parameters, super.key});

  final List<Parameter> parameters;

  @override
  State<FloatingCorrelationScreen> createState() =>
      _FloatingCorrelationScreenState();
}

class _FloatingCorrelationScreenState extends State<FloatingCorrelationScreen> {
  late DateTimeRange _range;
  // 0 for Fixed and 1 for Floating
  int _calculationType = 0;
  int _interval = 1;
  int _delay = 0;
  bool _calculated = false;
  bool _calculatedAll = false;
  Map _correlationResult = {};
  List<Map> _allCorrelationResults = [];

  @override
  void initState() {
    super.initState();
    _range = _calculateDefaultRangeFor2(widget.parameters);
    //calculate _range
  }

  //calculate default daily range based on 2 selected parameters:
  //takes the intersection of ranges from the start of observations
  DateTimeRange _calculateDefaultRangeFor2(List<Parameter> params) {
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
        title: const Text('Floating Correlation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outlined, color: Colors.red),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                    title: const Text('Correlations manual'),
                    content: SingleChildScrollView(
                        child: CorrelationsManualContent())),
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
                            ParameterButtonTemplate(parameter: p1),
                            const SizedBox(height: 15),
                            ParameterButtonTemplate(parameter: p2),
                            const SizedBox(height: 15),

                            //block for choosing interval
                            const Headline('Choose interval'),
                            PopupMenuButton(
                                child: Container(
                                  height: 40,
                                  width: 130,
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
                                      const Icon(Icons.straighten,
                                          size: 24, color: Colors.blue),
                                      Text(
                                          _interval == 1
                                              ? '1 hour'
                                              : '$_interval hours',
                                          style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.blue,
                                              fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                ),
                                onSelected: (int value) {
                                  if (value != _interval) {
                                    setState(() {
                                      _calculated = false;
                                      _calculatedAll = false;
                                      _interval = value;
                                    });
                                  }
                                },
                                itemBuilder: (BuildContext context) =>
                                    <PopupMenuEntry<int>>[
                                      const PopupMenuItem<int>(
                                        value: 1,
                                        child: Text('1 hours'),
                                      ),
                                      const PopupMenuItem<int>(
                                        value: 2,
                                        child: Text('2 hours'),
                                      ),
                                      const PopupMenuItem<int>(
                                        value: 3,
                                        child: Text('3 hours'),
                                      ),
                                      const PopupMenuItem<int>(
                                        value: 4,
                                        child: Text('4 hours'),
                                      ),
                                      const PopupMenuItem<int>(
                                        value: 6,
                                        child: Text('6 hours'),
                                      ),
                                      const PopupMenuItem<int>(
                                        value: 12,
                                        child: Text('12 hours'),
                                      ),
                                      const PopupMenuItem<int>(
                                        value: 24,
                                        child: Text('24 hours'),
                                      ),
                                    ]),
                            const SizedBox(height: 15),

                            //block for choosing lag
                            Headline('Choose delay:'),
                            PopupMenuButton(
                                child: Container(
                                  height: 40,
                                  width: 130,
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
                                      Text(
                                          _delay == 1
                                              ? '1 hour'
                                              : '$_delay hours',
                                          style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.blue,
                                              fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                ),
                                onSelected: (int value) {
                                  if (value != _delay) {
                                    setState(() {
                                      _calculated = false;
                                      _calculatedAll = false;
                                      _delay = value;
                                    });
                                  }
                                },
                                itemBuilder: (BuildContext context) =>
                                    <PopupMenuEntry<int>>[
                                      const PopupMenuItem<int>(
                                        value: 0,
                                        child: Text('0 hours'),
                                      ),
                                      const PopupMenuItem<int>(
                                        value: 1,
                                        child: Text('1 hour'),
                                      ),
                                      const PopupMenuItem<int>(
                                        value: 2,
                                        child: Text('2 hours'),
                                      ),
                                      const PopupMenuItem<int>(
                                        value: 3,
                                        child: Text('3 hours'),
                                      ),
                                      const PopupMenuItem<int>(
                                        value: 4,
                                        child: Text('4 hours'),
                                      ),
                                      const PopupMenuItem<int>(
                                        value: 6,
                                        child: Text('6 hours'),
                                      ),
                                      const PopupMenuItem<int>(
                                        value: 9,
                                        child: Text('9 hours'),
                                      ),
                                      const PopupMenuItem<int>(
                                        value: 12,
                                        child: Text('12 hours'),
                                      ),
                                      const PopupMenuItem<int>(
                                        value: 24,
                                        child: Text('24 hours'),
                                      ),
                                    ]),

                            //Control button
                            const SizedBox(height: 25),
                            ControlButton(
                                title: _calculated || _calculatedAll
                                    ? 'Result:'
                                    : 'Calculate correlation',
                                onPressed: () {
                                  setState(() {
                                    _correlationResult =
                                        calculateFloatingCorrelation(
                                            firstParameter: p1,
                                            secondParameter: p2,
                                            range: _range,
                                            intervalDuration: _interval,
                                            delay: _delay);
                                    _calculated = true;
                                  });
                                }),
                            //Control button
                            const SizedBox(height: 25),
                            // Floating Calculate all will be later
                            // if (!_calculated && !_calculatedAll)
                            //   ControlButton(
                            //       title: 'Calculate All options',
                            //       onPressed: () {
                            //         setState(() {
                            //           _allCorrelationResults =
                            //               calculateAllFixedCorrelations(
                            //                   firstParameter: p1,
                            //                   secondParameter: p2,
                            //                   range: _range,
                            //                   intervals: [2, 3, 4, 6, 12, 24],
                            //                   lags: [0, 1, 2, 3, 4]);
                            //           _allCorrelationResults.sort((a, b) =>
                            //               a['phi'].abs() > b['phi'].abs()
                            //                   ? -1
                            //                   : 1);
                            //           _calculatedAll = true;
                            //         });
                            //       }),
                            if (_calculated)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 25),
                                  const Headline('Contingency matrix'),
                                  ContingencyMatrix(
                                      firstParamColor: p1.decoration.color,
                                      secondParamColor: p2.decoration.color,
                                      n00: _correlationResult["n00"],
                                      n10: _correlationResult["n10"],
                                      n01: _correlationResult["n01"],
                                      n11: _correlationResult["n11"]),
                                  const SizedBox(height: 25),
                                  Headline(
                                      'Phi coefficient: ${NumberFormat().format(_correlationResult["phi"])}'),
                                  const SizedBox(height: 25),
                                ],
                              ),
                            if (_calculatedAll)
                              for (Map result in _allCorrelationResults)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 25),
                                    Headline(
                                        'interval = ${result['interval']} hours, lag = ${result['lag']}'),
                                    ContingencyMatrix(
                                        firstParamColor: p1.decoration.color,
                                        secondParamColor: p2.decoration.color,
                                        n00: result["n00"],
                                        n10: result["n10"],
                                        n01: result["n01"],
                                        n11: result["n11"]),
                                    const SizedBox(height: 25),
                                    Headline(
                                        'Phi coefficient: ${NumberFormat().format(result["phi"])}'),
                                    const SizedBox(height: 25),
                                    const Divider(),
                                  ],
                                ),
                          ]))))),
    );
  }
}

class CorrelationsManualContent extends StatelessWidget {
  const CorrelationsManualContent({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text.rich(
            TextSpan(
              children: [
                WidgetSpan(
                  child: Icon(Icons.science_outlined, color: Colors.red),
                ),
                TextSpan(text: " Experimental "),
                WidgetSpan(
                  child: Icon(Icons.science_outlined, color: Colors.red),
                ),
              ],
            ),
          ),
          SizedBox(height: 15),
          Text(
              'This tool calculates the content of a contingency matrix and phi coefficient between occurances of parameter 1 (p1) and parameter 2 (p2) events in lagged time intervals of specified period during research timerange.',
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
                      "is calculated as an intersection of the parameter ranges: from start of observations till now.",
                ),
              ],
            ),
          ),
          SizedBox(height: 15),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "It is divided into intervals of ",
                ),
                TextSpan(
                    text: "period ",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                  text:
                      "length (can be choosed from 2 hours to 1 day). Intervals starts at 00:00, so if the selected period is 6 hours, intervals of every day would be: 00 - 06, 06-12, 12-18, 18-24.",
                ),
              ],
            ),
          ),
          SizedBox(height: 15),
          Text.rich(TextSpan(children: [
            TextSpan(
              text:
                  "Each interval is checked for the occurance of parameters events to calculate values of the ",
            ),
            TextSpan(
                text: "contingency matrix",
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(
              text: ":",
            ),
          ])),
          Text('n11 - count of intervals where p1 and p2 events occured.'),
          Text(
              'n10 - count of intervals where p1 event(s) occured and p2 not.'),
          Text(
              'n01 - count of intervals where p2 event(s) occured and p1 not.'),
          Text(
              'n00 - count of intervals where p2 and p1 events have not occured.'),
          Text.rich(TextSpan(children: [
            WidgetSpan(
              child: Icon(Icons.warning, color: Colors.red),
            ),
            TextSpan(
              text: "Important note: intervals corresponding to ",
            ),
            TextSpan(
                text: "day intervals",
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(
              text:
                  ", in which p1 never occurred are not counted in n00. This is the only difference of the Cause App approach from general statistics.The goal is: to lesser influence of n00 on the phi coefficient ignoring the intervals where p1 has zero probability to occur.",
            ),
          ])),
          Text.rich(TextSpan(children: [
            TextSpan(
                text: "Day interval",
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(
              text:
                  " - is a number of the interval within a day. For example if the 6 hour interval is 12-18 it’s ",
            ),
            TextSpan(
                text: "day interval",
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(
              text: " is 3.",
            ),
          ])),
          SizedBox(height: 15),
          Text.rich(TextSpan(children: [
            TextSpan(
                text: "Occurance of parameter event",
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(
              text:
                  " is as one or more note moments in the interval. If the parameter has duration type Duration, then the moment of the duration end is taken.",
            ),
          ])),
          SizedBox(height: 15),
          Text.rich(TextSpan(children: [
            TextSpan(
                text: "Lag", style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(
              text:
                  " is the shift between intervals we want to examine. For example, you think parameter 1 event occurance in 2-hour interval N will cause occurance of parameter 2 event in interval N+1. Then you should examine correlation with a lag = 1.",
            ),
          ])),
          SizedBox(height: 15),
          Text.rich(TextSpan(children: [
            TextSpan(
                text: "Phi coefficient",
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(
              text:
                  " is calculated by the formula: (n11 *  n00 - n10 * n01) / (sqrt((n11 + n10) * (n11 + n01) * (n10 + n00) * (n01 + n00))).",
            ),
          ])),
          SizedBox(height: 15),
          Text.rich(TextSpan(children: [
            TextSpan(
                text: "Calculate All Options",
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(
              text:
                  " button launches the calculation of every variant of period and lag and displays results for every calculation in the order of descending values of phi coefficient.",
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
