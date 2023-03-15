import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import './view_utilities/ui_widgets.dart';
import './parameter_picker.dart';

import '../services/analytics_utilities/export_csv.dart';

import '../model/board.dart';

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
        // leading: IconButton(
        //     icon: const Icon(Icons.arrow_back),
        //     onPressed: () {
        //       Navigator.pop(context);
        //     }),
        title: const Text('Analytics'),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 15),

            /// correlation button screen
            // ToolButton(
            //   title: 'Correlation: day-day',
            //   icon: const Icon(Icons.backup_table),
            //   description:
            //       'This tool calculates 2x2 contingency matrix of days selected parameters has or has not occured. It helps understanding pattern of relation. Also, phi coefficient is calculated giving a sense of strength of relation.',
            //   onPressed: () {
            //     Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //             builder: (context) => const CorrelationDDScreen()));
            //   },
            // ),
            // const SizedBox(height: 15),
            ToolButton(
                title: 'Export Data',
                icon: const Icon(Icons.share),
                description:
                    'Export your gathered data in a simple csv format so you can play with it or share (with a coach or a doctor)',
                onPressed: () {
                  _exportData(board);
                }),
            const SizedBox(height: 15),
            ToolButton(
              title: '2-parameter chart',
              icon: const Icon(Icons.insights),
              description:
                  'Get a sense of correlation with the chart of 2 parameters of your choice.',
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ParameterPicker()));
              }, //show param picker and then make a graph
            ),
          ],
        ),
      ),
    );
  }
}
