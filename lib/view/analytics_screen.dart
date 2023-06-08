import 'package:flutter/material.dart';
import './view_utilities/ui_widgets.dart';
import './parameter_picker.dart';

import 'chart_screen.dart';
import 'correlation_screen.dart';
import 'floating_correlation_screen.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 15),
            ToolButton(
              title: '2-parameter chart',
              icon: const Icon(Icons.science_outlined, color: Colors.red),
              popupDescription: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text.rich(
                      TextSpan(
                        children: [
                          WidgetSpan(
                            child:
                                Icon(Icons.science_outlined, color: Colors.red),
                          ),
                          TextSpan(text: " Experimental "),
                          WidgetSpan(
                            child:
                                Icon(Icons.science_outlined, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                        'Get a sense of correlation with the chart of 2 parameters of your choice.'),
                  ]),
              onPressed: () {
                pickParameters(context: context, count: 2).then((parameters) {
                  if (parameters != null) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ChartScreen(parameters: parameters)));
                  }
                });
              }, //show param picker and then make a graph
            ),
            const SizedBox(height: 15),
            ToolButton(
              title: 'Correlation',
              icon: const Icon(Icons.science_outlined, color: Colors.red),
              popupDescription: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text.rich(
                      TextSpan(
                        children: [
                          WidgetSpan(
                            child:
                                Icon(Icons.science_outlined, color: Colors.red),
                          ),
                          TextSpan(text: " Experimental "),
                          WidgetSpan(
                            child:
                                Icon(Icons.science_outlined, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                        'Correlation of 2 parameters in time to think of causation.'),
                    SizedBox(height: 15),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                              text: "More instructions under ",
                              style: TextStyle(color: Colors.black)),
                          WidgetSpan(
                            child: Icon(Icons.info),
                          ),
                          TextSpan(
                              text: " in the section.",
                              style: TextStyle(color: Colors.black)),
                        ],
                      ),
                    ),
                  ]),
              onPressed: () {
                pickParameters(context: context, count: 2).then((parameters) {
                  if (parameters != null) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                CorrelationScreen(parameters: parameters)));
                  }
                });
              },
            ),
            const SizedBox(height: 15),
            ToolButton(
              title: 'Floating Correlation',
              icon: const Icon(Icons.science_outlined, color: Colors.red),
              popupDescription: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text.rich(
                      TextSpan(
                        children: [
                          WidgetSpan(
                            child:
                                Icon(Icons.science_outlined, color: Colors.red),
                          ),
                          TextSpan(text: " Experimental "),
                          WidgetSpan(
                            child:
                                Icon(Icons.science_outlined, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                        'Floating interval Correlation of 2 parameters in time to think of causation.'),
                    SizedBox(height: 15),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                              text: "More instructions under ",
                              style: TextStyle(color: Colors.black)),
                          WidgetSpan(
                            child: Icon(Icons.info),
                          ),
                          TextSpan(
                              text: " in the section.",
                              style: TextStyle(color: Colors.black)),
                        ],
                      ),
                    ),
                  ]),
              onPressed: () {
                pickParameters(context: context, count: 2).then((parameters) {
                  if (parameters != null) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FloatingCorrelationScreen(
                                parameters: parameters)));
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
