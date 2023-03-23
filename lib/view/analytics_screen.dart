import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import './view_utilities/ui_widgets.dart';
import './parameter_picker.dart';

import '../services/analytics_utilities/export_csv.dart';

import '../model/board.dart';
import 'parameter_picker_correlation.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({required this.board, super.key});

  final Board board;

  void _exportData(Board board) async {
    File file = await ExportCSV(board: board).writeCSV();
    await Share.shareFiles([file.path], text: 'Export Data');
    await file.delete();
  }

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
                title: 'Export Data',
                icon: const Icon(Icons.share),
                popupDescription: const Text(
                    'Export your gathered data in a simple csv format so you can play with it or share (with a coach or a doctor)'),
                onPressed: () {
                  _exportData(board);
                }),
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
                    // SizedBox(height: 15),
                    // Text.rich(
                    //   TextSpan(
                    //     children: [
                    //       TextSpan(
                    //           text: "More instructions under ",
                    //           style: TextStyle(color: Colors.black)),
                    //       WidgetSpan(
                    //         child: Icon(Icons.info),
                    //       ),
                    //       TextSpan(
                    //           text: " in the section.",
                    //           style: TextStyle(color: Colors.black)),
                    //     ],
                    //   ),
                    // ),
                  ]),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ParameterPicker()));
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
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const CorrelationParameterPicker()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
