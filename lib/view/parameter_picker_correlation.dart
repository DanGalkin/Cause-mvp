import 'package:flutter/material.dart';

import '../model/parameter.dart';
import '../model/board.dart';

import '../controllers/board_controller.dart';

import './view_utilities/ui_widgets.dart';

import '../services/service_locator.dart';
import 'chart_screen.dart';
import 'correlation_screen.dart';

class CorrelationParameterPicker extends StatefulWidget {
  const CorrelationParameterPicker({this.pickCount = 2, super.key});

  //how many parameter should be picked. It is a validation criteria
  //for proceeding after user's pick
  final int pickCount;

  @override
  State<CorrelationParameterPicker> createState() =>
      _CorrelationParameterPickerState();
}

class _CorrelationParameterPickerState
    extends State<CorrelationParameterPicker> {
  final List<Parameter> _picked = [];

  @override
  Widget build(BuildContext context) {
    bool validToProceed = _picked.length == widget.pickCount;

    return Scaffold(
      appBar: AppBar(title: Text('Choose ${widget.pickCount} parameters')),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SizedBox(
              width: 320,
              child: Column(children: [
                if (_picked.isNotEmpty)
                  Column(children: [
                    SelectedParametersList(
                        selected: _picked,
                        onRemove: (parameter) {
                          _picked.remove(parameter);
                          setState(() {});
                        },
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (oldIndex < newIndex) {
                              newIndex -= 1;
                            }
                            final Parameter item = _picked.removeAt(oldIndex);
                            _picked.insert(newIndex, item);
                          });
                        }),
                    const Divider(),
                    const SizedBox(height: 15),
                  ]),
                ParamFromBoardSelector(onSelect: (param) {
                  _picked.add(param);
                  setState(() {});
                }),
              ])),
        ),
      )),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CorrelationScreen(parameters: _picked),
              ));
        },
        label: const Text('NEXT'),
        icon: const Icon(Icons.arrow_forward),
        backgroundColor: validToProceed ? null : Colors.grey,
      ),
    );
  }
}

class SelectedParametersList extends StatelessWidget {
  const SelectedParametersList(
      {required this.selected,
      required this.onRemove,
      required this.onReorder,
      super.key});

  final List<Parameter> selected;

  final void Function(Parameter) onRemove;
  final void Function(int, int) onReorder;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Headline('Selected parameters (reorderable):'),
        ReorderableListView.builder(
          itemCount: selected.length,
          itemBuilder: ((context, index) => Column(
                key: ValueKey('$index'),
                children: [
                  const SizedBox(height: 5),
                  RemovableParameterTitle(
                      key: ValueKey('$index'),
                      parameter: selected[index],
                      onRemove: onRemove),
                  const SizedBox(height: 5),
                ],
              )),
          onReorder: onReorder,
          shrinkWrap: true,
        ),
      ],
    );
  }
}

class ParamFromBoardSelector extends StatelessWidget {
  const ParamFromBoardSelector({required this.onSelect, super.key});

  final void Function(Parameter) onSelect;

  @override
  Widget build(BuildContext context) {
    List<Board> boards = getIt<BoardController>().boards.values.toList();
    return Column(mainAxisSize: MainAxisSize.min, children: [
      const Headline('Select a parameter from board:'),
      const SizedBox(height: 15),
      Column(children: [
        ...boards.map((board) => Column(
              children: [
                ListTile(
                  title: Text(
                    board.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () async {
                    Parameter? selected =
                        await _showParameterSelectionDialog(board, context);
                    if (selected != null) onSelect(selected);
                  },
                ),
                const Divider(),
              ],
            ))
      ]),
    ]);
  }

  Future<Parameter?> _showParameterSelectionDialog(
      Board board, BuildContext context) async {
    return showDialog<Parameter>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
          content: board.params.isNotEmpty
              ? Container(
                  height: 800,
                  width: 320,
                  child: ListView.separated(
                    itemCount: board.params.length,
                    itemBuilder: (context, index) {
                      Parameter parameter = board.params.values.toList()[index];
                      return ParameterButtonTemplate(
                          parameter: parameter,
                          onTap: () {
                            Navigator.of(context).pop(parameter);
                          });
                    },
                    separatorBuilder: ((context, index) =>
                        const SizedBox(height: 15)),
                    shrinkWrap: true,
                  ),
                )
              : const Text('This board has no parameters')),
    );
  }
}
