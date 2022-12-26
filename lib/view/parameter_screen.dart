import 'package:cause_flutter_mvp/view/view_utilities/action_validation_utilities.dart';

import '../model/category_option.dart';
import '../view/view_utilities/input_validation_utilities.dart';
import './view_utilities/ui_widgets.dart';
import './view_utilities/picker_widgets.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../controllers/board_controller.dart';
import '../model/parameter.dart';
import '../model/board.dart';
import '../model/note.dart';

import './notes_list_screen.dart';

class ParameterScreen extends StatefulWidget {
  final Parameter parameter;
  final Board board;
  final Note? noteToEdit;

  const ParameterScreen(
      {required this.parameter, required this.board, this.noteToEdit, Key? key})
      : super(key: key);

  @override
  State<ParameterScreen> createState() => _ParameterScreenState();
}

class _ParameterScreenState extends State<ParameterScreen> {
  DateTime _moment = DateTime.now();
  DateTimeRange _duration =
      DateTimeRange(start: DateTime.now(), end: DateTime.now());
  double? _quantity;
  CategoryOption? _selectedCategory;

  late bool _isValueSelected;

  late bool _isRecording;

  //true, if the note is edited, false if created new note
  late bool _editScreen;

  late Note _note;

  late TextEditingController quantityController;

  @override
  void initState() {
    quantityController = TextEditingController();

    _editScreen = widget.noteToEdit != null;
    //set state if creating new note
    if (!_editScreen) {
      _isValueSelected =
          widget.parameter.varType == VarType.binary ? true : false;
      _isRecording = widget.parameter.recordState.recording;
      if (_isRecording) {
        _duration = DateTimeRange(
            start: widget.parameter.recordState.startedAt!,
            end: DateTime.now());
      }
    }
    //set state if editing existing note
    if (_editScreen) {
      _note = widget.noteToEdit!;
      _isValueSelected = true;
      _note.durationType == DurationType.moment
          ? _moment = _note.moment!
          : _duration = _note.duration!;

      if (_note.varType == VarType.categorical) {
        _selectedCategory = CategoryOption.fromMap(_note.value['categorical']);
      }

      if (_note.varType == VarType.quantitative) {
        _quantity = _note.value['quantitative']['value'].toDouble();
        quantityController.text = _quantity!.toString();
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Parameter parameter = widget.parameter;

    return Scaffold(
      appBar: AppBar(
          title: Text(_editScreen ? 'Edit note' : 'Enter new note'),
          actions: [
            IconButton(
              icon: const Icon(Icons.view_list),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NotesListScreen(
                            board: widget.board, parameter: parameter)));
              },
            )
          ]),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
              child: SizedBox(
            width: 320,
            child: Column(
              children: [
                ParameterButtonTitle(parameter: parameter),
                const SizedBox(height: 25),
                _buildTimeSelector(),
                const SizedBox(height: 25),
                _buildValueSelector(),
                const SizedBox(height: 50),
              ],
            ),
          )),
        ),
      ),
      floatingActionButton: _editScreen
          ? _deleteEditFABs(context)
          : FloatingActionButton.extended(
              onPressed: _isValueSelected
                  ? () {
                      _submitNoteCreation(context);
                    }
                  : null,
              backgroundColor: _isValueSelected ? null : Colors.grey,
              label: const Text('SAVE NOTE'),
              icon: const Icon(Icons.add),
            ),
    );
  }

  Widget _deleteEditFABs(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton.extended(
          heroTag: 'DELETE',
          onPressed: () {
            _validateAndDelete(context);
          },
          backgroundColor: const Color(0xFFB3261E),
          label: const Text('DELETE NOTE'),
          icon: const Icon(Icons.delete),
        ),
        SizedBox(width: 20),
        FloatingActionButton.extended(
          heroTag: 'EDIT',
          onPressed: _isValueSelected
              ? () {
                  _submitNoteCreation(context);
                }
              : null,
          backgroundColor: _isValueSelected ? null : Colors.grey,
          label: const Text('SAVE EDIT'),
          icon: const Icon(Icons.edit),
        ),
      ],
    );
  }

  Widget _buildTimeSelector() {
    if (widget.parameter.durationType == DurationType.moment) {
      return MomentPicker(
          initialDateTime: _moment,
          onChange: (newMoment) {
            setState(() {
              _moment = newMoment;
            });
          });
    } else {
      return DurationPicker(
        initialDateTimeRange: _duration,
        onChange: (newDuration) {
          setState(() {
            _duration = newDuration;
          });
        },
      );
    }
  }

  Widget _buildValueSelector() {
    final Parameter param = widget.parameter;
    if (param.varType == VarType.binary ||
        param.durationType == DurationType.duration) {
      return const Headline(
          'The default binary value is true. The fact of event occurance will be saved.');
    } else if (param.varType == VarType.quantitative) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Headline('Enter your value in ${param.metric}'),
          TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                TextInputFormatter.withFunction((oldValue, newValue) {
                  final newText = newValue.text;
                  if (isDecimalNumberInputValid(newText) || newText.isEmpty) {
                    return newValue;
                  } else {
                    return oldValue;
                  }
                })
              ],
              onChanged: (value) {
                if (value.isNotEmpty) {
                  setState(() {
                    if (!_isValueSelected) {
                      _isValueSelected = true;
                    }
                    _quantity = double.parse(value);
                  });
                } else if (_isValueSelected) {
                  setState(() {
                    _isValueSelected = false;
                  });
                }
              }),
        ],
      );
    } else if (param.varType == VarType.categorical) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Headline('Select an option'),
          if (param.categories!.list.isEmpty)
            const Headline(
                'Oops.. No options has been provided on creation of parameter(((')
          else
            for (CategoryOption option in param.categories!.list)
              RadioListTile<String>(
                title: Text(option.name),
                value: option.id,
                groupValue: _selectedCategory?.id,
                onChanged: ((String? value) => setState(() {
                      _selectedCategory = option;
                      if (!_isValueSelected) {
                        _isValueSelected = true;
                      }
                    })),
              )
        ],
      );
    } else {
      return Container();
    }
  }

  @override
  void dispose() {
    quantityController.dispose();
    super.dispose();
  }

  void _submitNoteCreation(BuildContext context) {
    var time = widget.parameter.durationType == DurationType.duration
        ? _duration
        : _moment;
    late var value;
    switch (widget.parameter.varType) {
      case VarType.binary:
        {
          value = true;
        }
        break;
      case VarType.quantitative:
        {
          value = _quantity;
        }
        break;
      case VarType.categorical:
        {
          value = _selectedCategory;
        }
        break;
      default:
        {
          value = null;
        }
        break;
    }

    if (_editScreen == false) {
      Provider.of<BoardController>(context, listen: false)
          .addNote(widget.board, widget.parameter, time, value);

      Navigator.pop(context);
      //notify user that note is created
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${widget.parameter.name} : new note added!'),
        duration: const Duration(seconds: 2),
      ));

      //if parameter has been recorded, cancel the record
      if (_isRecording) {
        Provider.of<BoardController>(context, listen: false)
            .cancelRecording(widget.board, widget.parameter);
      }
    } else {
      Provider.of<BoardController>(context, listen: false)
          .editNote(widget.board, widget.parameter, _note, time, value);

      Navigator.pop(context);
      //notify user that note is created
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${widget.parameter.name} : note edited!'),
        duration: const Duration(seconds: 2),
      ));
    }
  }

  void _validateAndDelete(BuildContext context) async {
    bool? validated = await validateUserAction(
        context: context,
        validationText: 'This note will be deleted for all users.');
    if (validated == true) {
      Provider.of<BoardController>(context, listen: false)
          .deleteNote(widget.board, widget.parameter, _note);

      Navigator.pop(context);
      //notify user that note is deleted
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${widget.parameter.name} : note deleted!'),
        duration: const Duration(seconds: 2),
      ));
    }
  }
}
