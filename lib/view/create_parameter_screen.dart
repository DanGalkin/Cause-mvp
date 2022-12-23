import 'dart:async';

import 'package:cause_flutter_mvp/model/category_option.dart';
import 'package:flutter/material.dart';
import 'package:nanoid/nanoid.dart';
import 'package:provider/provider.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

import '../controllers/board_controller.dart';
import '../model/board.dart';
import '../model/button_decoration.dart';
import '../model/parameter.dart';
import './view_utilities/pickers.dart';

class CreateParameterScreen extends StatefulWidget {
  final Board board;
  const CreateParameterScreen({Key? key, required this.board})
      : super(key: key);

  @override
  State<CreateParameterScreen> createState() => _CreateParameterScreenState();
}

class _CreateParameterScreenState extends State<CreateParameterScreen> {
  int _step = 0;
  late TextEditingController nameController;
  late TextEditingController metricController;
  late TextEditingController categoryController;
  DurationType _selectedDurationType = DurationType.moment;
  VarType _selectedVarType = VarType.binary;
  final CategoryOptionsList _categoryOptions = CategoryOptionsList(list: []);
  Color color = Colors.grey[200]!;
  String _icon = '';

  @override
  void initState() {
    nameController = TextEditingController();
    metricController = TextEditingController();
    categoryController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Create new parameter')),
        body: Stepper(
          currentStep: _step,
          onStepContinue: () {
            setState(() {
              _step++;
            });
          },
          onStepCancel: () {
            if (_step > 0) {
              setState(() {
                _step--;
              });
            }
          },
          onStepTapped: (value) {
            if (value <= _step) {
              setState(() {
                _step = value;
              });
            }
          },
          controlsBuilder: ((context, details) {
            return Row(children: [
              //magical number 4 - is the last step index - should be refactored
              details.currentStep != 4
                  ? ElevatedButton(
                      onPressed: details.onStepContinue,
                      child: const Text('NEXT'),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        _createNewParameter(context);
                      },
                      child: const Text('CREATE & CONTINUE'))
            ]);
          }),
          steps: [
            Step(
              title: _step < 1
                  ? Text('Give a name')
                  : Text('Name: ${nameController.text}'),
              content: _buildNameInput(),
            ),
            Step(
                title: _step < 2
                    ? Text('Select Duration type')
                    : Text('Duration type: ${_selectedDurationType.name}'),
                content: _buildDurationTypeInput()),
            Step(
              title: _step < 3
                  ? Text('Select Data type')
                  : Text('Data type: ${_selectedVarType.name}'),
              content: _buildDataTypeInput(),
            ),
            Step(
              title: Text('Select Data properties'),
              content: _buildDataPropsInput(context),
            ),
            Step(
              title: Text('Choose decoration'),
              content: _buildDecorationInput(context),
            ),
          ],
        ));
  }

  Widget _buildNameInput() {
    return TextField(controller: nameController);
  }

  Widget _buildDurationTypeInput() {
    return Column(
      children: [
        RadioListTile<DurationType>(
          title: Text('Moment'),
          value: DurationType.moment,
          groupValue: _selectedDurationType,
          onChanged: (DurationType? value) {
            setState(() {
              _selectedDurationType = value!;
            });
          },
        ),
        RadioListTile<DurationType>(
          title: Text('Duration'),
          value: DurationType.duration,
          groupValue: _selectedDurationType,
          onChanged: (DurationType? value) {
            setState(() {
              _selectedDurationType = value!;
              _selectedVarType = VarType.binary;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDataTypeInput() {
    return Column(
      children: [
        if (_selectedDurationType == DurationType.duration)
          Text(
              'If a parameter track a duration it can only have a binary value. I.e. it only occurs or not.'),
        RadioListTile<VarType>(
          title: Text('Binary'),
          value: VarType.binary,
          groupValue: _selectedVarType,
          onChanged: _selectedDurationType == DurationType.duration
              ? null
              : (VarType? value) {
                  setState(() {
                    _selectedVarType = value!;
                  });
                },
        ),
        RadioListTile<VarType>(
          title: Text('Quantitative'),
          value: VarType.quantitative,
          groupValue: _selectedVarType,
          onChanged: _selectedDurationType == DurationType.duration
              ? null
              : (VarType? value) {
                  setState(() {
                    _selectedVarType = value!;
                  });
                },
        ),
        RadioListTile<VarType>(
          title: Text('Categorical'),
          value: VarType.categorical,
          groupValue: _selectedVarType,
          onChanged: _selectedDurationType == DurationType.duration
              ? null
              : (VarType? value) {
                  setState(() {
                    _selectedVarType = value!;
                  });
                },
        ),
      ],
    );
  }

  Widget _buildDataPropsInput(BuildContext context) {
    switch (_selectedVarType) {
      case VarType.binary:
        return const Text(
            'No need for additional properties for binary parameter. It either occured, or not.');
      case VarType.quantitative:
        return Column(children: [
          const Text('Select a metric (kg, ml, pcs, times, etc.)'),
          TextField(
            controller: metricController,
          ),
        ]);
      case VarType.categorical:
        return _buildCategoryCreator(context);
      default:
        return const Text('No need for additional properties.');
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    metricController.dispose();
    categoryController.dispose();
    super.dispose();
  }

  Widget _buildCategoryCreator(BuildContext context) {
    return Column(children: [
      const Text('Create categories for your parameter:'),
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: categoryController,
            ),
          ),
          TextButton(
              child: const Text('+ Add'),
              onPressed: () {
                //create category
                CategoryOption newCategoryOption = CategoryOption(
                  id: nanoid(10),
                  name: categoryController.text,
                );
                //add to categories list
                _categoryOptions.addOption(newCategoryOption);
                //clear
                categoryController.clear();
                //update state to show new category
                setState(() {});
              }),
        ],
      ),
      Column(children: [
        for (CategoryOption option in _categoryOptions.list)
          ListTile(
              title: Text(option.name),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  _categoryOptions.removeOption(option);
                  setState(() {});
                },
              ))
      ]),
    ]);
  }

  void _createNewParameter(BuildContext context) {
    String paramName = nameController.text;

    Provider.of<BoardController>(context, listen: false).createParameter(
        widget.board,
        paramName,
        _selectedDurationType,
        _selectedVarType,
        metricController.text,
        _categoryOptions,
        ButtonDecoration(color: color, icon: _icon));

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$paramName : parameter created!'),
      duration: const Duration(seconds: 2),
    ));

    Navigator.pop(context);
  }

  void onColorButtonTap(buttonColor) {
    setState(() {
      color = buttonColor;
    });
  }

  Widget _buildDecorationInput(BuildContext context) {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          ColorCircleButton(
            onTap: onColorButtonTap,
            color: Colors.grey[200]!,
            selectedColor: color,
          ),
          ColorCircleButton(
            onTap: onColorButtonTap,
            color: Colors.deepOrange[200]!,
            selectedColor: color,
          ),
          ColorCircleButton(
            onTap: onColorButtonTap,
            color: Colors.orange[200]!,
            selectedColor: color,
          ),
          ColorCircleButton(
            onTap: onColorButtonTap,
            color: Colors.lightGreen[200]!,
            selectedColor: color,
          ),
          ColorCircleButton(
            onTap: onColorButtonTap,
            color: Colors.cyan[200]!,
            selectedColor: color,
          ),
        ]),
        const SizedBox(height: 15),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          ColorCircleButton(
            onTap: onColorButtonTap,
            color: Colors.indigo[200]!,
            selectedColor: color,
          ),
          ColorCircleButton(
            onTap: onColorButtonTap,
            color: Colors.pink[200]!,
            selectedColor: color,
          ),
          ColorCircleButton(
            onTap: onColorButtonTap,
            color: Colors.blueGrey[200]!,
            selectedColor: color,
          ),
          ColorCircleButton(
            onTap: onColorButtonTap,
            color: Colors.yellow[200]!,
            selectedColor: color,
          ),
          ColorCircleButton(
            onTap: onColorButtonTap,
            color: Colors.purple[200]!,
            selectedColor: color,
          ),
        ]),
        const SizedBox(height: 15),
        TextButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) => EmogiPickerDialog(
                        onEmojiSelected: (emoji) => setState(() {
                          _icon = emoji.emoji;
                        }),
                      ));
            },
            child: Text('Choose icon: $_icon')),
        const SizedBox(height: 15),
      ],
    );
  }
}

class ColorCircleButton extends StatelessWidget {
  const ColorCircleButton({
    super.key,
    required this.onTap,
    required this.color,
    required this.selectedColor,
  });

  final Function onTap;
  final Color color;
  final Color selectedColor;

  bool isSelected() {
    return (color == selectedColor);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(color),
      child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: isSelected()
                  ? Border.all(width: 1, color: Colors.black)
                  : null),
          child: Center(
              child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  )))),
    );
  }
}
