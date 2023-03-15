import 'package:flutter/material.dart';
import '../model/parameter.dart';

import './view_utilities/chart_widgets.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({required this.parameters, super.key});

  final List<Parameter> parameters;

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chart (with Zoom and Move)')),
      body: SingleChildScrollView(
        child: Center(
          child: ChartWidget(parameters: widget.parameters),
        ),
      ),
    );
  }
}
