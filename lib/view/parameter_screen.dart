import '../model/category_option.dart';
import '../view/view_utilities/input_validation_utilities.dart';
import './view_utilities/ui_widgets.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../controllers/board_controller.dart';
import '../model/parameter.dart';
import '../model/board.dart';

import 'package:intl/intl.dart';

import './notes_list_screen.dart';

class ParameterScreen extends StatefulWidget {
  final Parameter parameter;
  final Board board;

  const ParameterScreen(
      {required this.parameter, required this.board, Key? key})
      : super(key: key);

  @override
  State<ParameterScreen> createState() => _ParameterScreenState();
}

class _ParameterScreenState extends State<ParameterScreen> {
  DateTime _moment = DateTime.now();
  DateTime _momentStart = DateTime.now();
  DateTime _momentEnd = DateTime.now();
  double? _quantity;
  String? _selectedCategoryId;
  CategoryOption? _selectedCategory;

  late bool _isValueSelected;

  late TextEditingController quantityController;

  @override
  void initState() {
    _isValueSelected =
        widget.parameter.varType == VarType.binary ? true : false;
    super.initState();
    quantityController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final Parameter parameter = widget.parameter;

    return Scaffold(
      appBar: AppBar(title: const Text('Enter new note'), actions: [
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
      floatingActionButton: FloatingActionButton.extended(
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

  Widget _buildTimeSelector() {
    if (widget.parameter.durationType == DurationType.moment) {
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
                    final DateTime newTime =
                        await _getDateSelection(initialDateTime: _moment);
                    if (newTime != _moment) {
                      bool validationResult =
                          await _validateMomentSelection(newTime);
                      if (validationResult == true) {
                        setState(() {
                          _moment = newTime;
                        });
                      }
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.date_range,
                          size: 24, color: Colors.blue),
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
                    final DateTime newTime =
                        await _getTimeSelection(initialDateTime: _moment);
                    if (newTime != _moment) {
                      bool validationResult =
                          await _validateMomentSelection(newTime);
                      if (validationResult == true) {
                        setState(() {
                          _moment = newTime;
                        });
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
    } else {
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
                    final DateTime newTime =
                        await _getDateSelection(initialDateTime: _momentStart);
                    if (newTime != _momentStart) {
                      final bool validationResult =
                          await _validateDurationSelection(newTime, _momentEnd);
                      if (validationResult) {
                        setState(() {
                          _momentStart = newTime;
                        });
                      }
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.date_range,
                          size: 24, color: Colors.blue),
                      const SizedBox(width: 12),
                      Text(DateFormat.MMMd().format(_momentStart),
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
                    final DateTime newTime =
                        await _getTimeSelection(initialDateTime: _momentStart);
                    if (newTime != _momentStart) {
                      final bool validationResult =
                          await _validateDurationSelection(newTime, _momentEnd);
                      if (validationResult) {
                        setState(() {
                          _momentStart = newTime;
                        });
                      }
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.schedule, size: 24, color: Colors.blue),
                      const SizedBox(width: 12),
                      Text(DateFormat.Hm().format(_momentStart),
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
                    final DateTime newTime =
                        await _getDateSelection(initialDateTime: _momentEnd);
                    if (newTime != _momentEnd) {
                      bool validationResult = await _validateDurationSelection(
                          _momentStart, newTime);
                      if (validationResult) {
                        setState(() {
                          _momentEnd = newTime;
                        });
                      }
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.date_range,
                          size: 24, color: Colors.blue),
                      const SizedBox(width: 12),
                      Text(DateFormat.MMMd().format(_momentEnd),
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
                    final DateTime newTime =
                        await _getTimeSelection(initialDateTime: _momentEnd);
                    if (newTime != _momentEnd) {
                      bool validationResult = await _validateDurationSelection(
                          _momentStart, newTime);
                      if (validationResult) {
                        setState(() {
                          _momentEnd = newTime;
                        });
                      }
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.schedule, size: 24, color: Colors.blue),
                      const SizedBox(width: 12),
                      Text(DateFormat.Hm().format(_momentEnd),
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
  }

  Future<DateTime> _getDateSelection(
      {required DateTime initialDateTime}) async {
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
      {required DateTime initialDateTime}) async {
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
                groupValue: _selectedCategoryId,
                onChanged: ((String? value) => setState(() {
                      _selectedCategoryId = option.id;
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
        ? DateTimeRange(start: _momentStart, end: _momentEnd)
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
    Provider.of<BoardController>(context, listen: false)
        .addNote(widget.board, widget.parameter, time, value);

    Navigator.pop(context);
    //notify user that note is created
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${widget.parameter.name} : new note added!'),
      duration: Duration(seconds: 2),
    ));
  }
}
