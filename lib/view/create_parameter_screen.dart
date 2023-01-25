import 'dart:async';

import 'package:cause_flutter_mvp/model/category_option.dart';
import 'package:cause_flutter_mvp/view/view_utilities/action_validation_utilities.dart';
import 'package:flutter/material.dart';
import 'package:nanoid/nanoid.dart';
import 'package:provider/provider.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:dotted_border/dotted_border.dart';

import '../controllers/board_controller.dart';
import '../model/board.dart';
import '../model/button_decoration.dart';
import '../model/parameter.dart';
import './view_utilities/pickers.dart';

class CreateParameterScreen extends StatefulWidget {
  final Board board;
  final Parameter? parameter;

  const CreateParameterScreen({Key? key, required this.board, this.parameter})
      : super(key: key);

  @override
  State<CreateParameterScreen> createState() => _CreateParameterScreenState();
}

class _CreateParameterScreenState extends State<CreateParameterScreen> {
  int _step = 0;
  late TextEditingController nameController;
  late TextEditingController metricController;
  late TextEditingController categoryController;
  late TextEditingController _categoryEditController;

  DurationType _selectedDurationType = DurationType.moment;
  VarType _selectedVarType = VarType.binary;

  CategoryOptionsList _categoryOptions = CategoryOptionsList(list: []);
  Color _color = Colors.grey[200]!;
  String _icon = '';
  bool _showLastNote = false;

  //props for editing
  late bool _editScreen;
  late Parameter _parameter;

  @override
  void initState() {
    nameController = TextEditingController();
    metricController = TextEditingController();
    categoryController = TextEditingController();
    _categoryEditController = TextEditingController();

    _editScreen = widget.parameter != null ? true : false;
    if (_editScreen) {
      _parameter = widget.parameter!;
      nameController.text = _parameter.name;
      _icon = _parameter.decoration.icon;
      _color = _parameter.decoration.color;
      _showLastNote = _parameter.decoration.showLastNote;
      _selectedVarType = _parameter.varType;
      _selectedDurationType = _parameter.durationType;

      if (_parameter.varType == VarType.categorical ||
          _parameter.varType == VarType.ordinal) {
        _categoryOptions = _parameter.categories!;
      }

      if (_parameter.varType == VarType.quantitative) {
        metricController.text = _parameter.metric!;
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(_editScreen
              ? 'Edit parameter: ${_parameter.name}'
              : 'Create new parameter')),
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
          if (_editScreen == false) {
            if (value <= _step) {
              setState(() {
                _step = value;
              });
            }
          } else {
            setState(() {
              _step = value;
            });
          }
        },
        controlsBuilder: ((context, details) {
          return _editScreen
              ? const SizedBox.shrink()
              : Row(children: [
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
                ? const Text('Give a name')
                : Text('Name: ${nameController.text}'),
            content: _buildNameInput(),
          ),
          Step(
              title: _step < 2
                  ? const Text('Select Duration type')
                  : Text('Duration type: ${_selectedDurationType.name}'),
              content: _editScreen
                  ? Container(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Duration type is fixed. You cannot change it yet.',
                        textAlign: TextAlign.left,
                      ),
                    )
                  : _buildDurationTypeInput()),
          Step(
            title: _step < 3
                ? const Text('Select Data type')
                : Text('Data type: ${_selectedVarType.name}'),
            content: _editScreen
                ? Container(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Data type is fixed. You cannot change it yet.',
                      textAlign: TextAlign.left,
                    ),
                  )
                : _buildDataTypeInput(),
          ),
          Step(
            title: const Text('Select Data properties'),
            content: _buildDataPropsInput(context),
          ),
          Step(
            title: const Text('Choose decoration'),
            content: _buildDecorationInput(context),
          ),
        ],
      ),
      floatingActionButton: _editScreen
          ? FloatingActionButton.extended(
              label: const Text('SAVE EDIT'),
              icon: const Icon(Icons.edit),
              onPressed: _validateAndSave,
            )
          : null,
    );
  }

  Widget _buildNameInput() {
    return TextField(controller: nameController);
  }

  Widget _buildDurationTypeInput() {
    return Column(
      children: [
        RadioListTile<DurationType>(
          title: const Text('Moment'),
          value: DurationType.moment,
          groupValue: _selectedDurationType,
          onChanged: (DurationType? value) {
            setState(() {
              _selectedDurationType = value!;
            });
          },
        ),
        RadioListTile<DurationType>(
          title: const Text('Duration'),
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
          Container(
            alignment: Alignment.centerLeft,
            child: const Text(
                'If a parameter track a duration it can only have a binary value. I.e. it only occurs or not.'),
          ),
        RadioListTile<VarType>(
          title: const Text('Binary'),
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
          title: const Text('Quantitative'),
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
          title: const Text('Ordinal'),
          value: VarType.ordinal,
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
          title: const Text('Categorical'),
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
        RadioListTile<VarType>(
          title: const Text('Unstructured'),
          value: VarType.unstructured,
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
        return Container(
          alignment: Alignment.centerLeft,
          child: const Text(
              'No need for additional properties for binary parameter. It either occured, or not.'),
        );
      case VarType.unstructured:
        return Container(
          alignment: Alignment.centerLeft,
          child: const Text(
              'Your input for unstructured parameter will be plain text.'),
        );
      case VarType.quantitative:
        return Column(children: [
          const Text('Select a metric (kg, ml, pcs, times, etc.)'),
          TextField(
            controller: metricController,
          ),
        ]);
      case VarType.categorical:
        return _buildCategoryCreator(context);
      case VarType.ordinal:
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
    _categoryEditController.dispose();
    super.dispose();
  }

  Widget _buildCategoryCreator(BuildContext context) {
    return Column(children: [
      Container(
          alignment: Alignment.centerLeft,
          child: const Text('Create categories for your parameter:')),
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
      SizedBox(
        child: ReorderableListView.builder(
          buildDefaultDragHandles: false,
          itemCount: _categoryOptions.list.length,
          itemBuilder: ((context, index) {
            final CategoryOption category = _categoryOptions.list[index];
            String orderNumber = _selectedVarType == VarType.ordinal
                ? '${(index + 1).toString()}. '
                : '';
            return ListTile(
              key: ValueKey(category.name),
              title: Text('$orderNumber${category.name}'),
              trailing: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showCategoryEditDialog(
                            context, category, _categoryOptions)),
                    ReorderableDragStartListener(
                        index: index, child: const Icon(Icons.drag_indicator)),
                  ]),
            );
          }),
          onReorder: (int oldIndex, int newIndex) {
            setState(() {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              //TODO very bad - shouldn't have direct access to the list of _categoryoptions
              final CategoryOption item =
                  _categoryOptions.list.removeAt(oldIndex);
              _categoryOptions.list.insert(newIndex, item);
            });
          },
          shrinkWrap: true,
        ),
      )
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
        ButtonDecoration(
            color: _color, icon: _icon, showLastNote: _showLastNote));

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$paramName : parameter created!'),
      duration: const Duration(seconds: 2),
    ));

    Navigator.pop(context);
  }

  void _validateAndSave() async {
    bool? validated = await validateUserAction(
        context: context,
        validationText:
            'The parameter properties will be changed for every board user.');
    if (validated == true) {
      Provider.of<BoardController>(context, listen: false).editParameter(
          widget.board,
          _parameter,
          nameController.text,
          metricController.text,
          _categoryOptions,
          ButtonDecoration(
              color: _color, icon: _icon, showLastNote: _showLastNote));

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${nameController.text} : parameter edited!'),
        duration: const Duration(seconds: 2),
      ));
    }
  }

  void onColorButtonTap(buttonColor) {
    setState(() {
      _color = buttonColor;
    });
  }

  Widget _buildDecorationInput(BuildContext context) {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          ColorCircleButton(
            onTap: onColorButtonTap,
            color: Colors.grey[200]!,
            selectedColor: _color,
          ),
          ColorCircleButton(
            onTap: onColorButtonTap,
            color: Colors.deepOrange[200]!,
            selectedColor: _color,
          ),
          ColorCircleButton(
            onTap: onColorButtonTap,
            color: Colors.orange[200]!,
            selectedColor: _color,
          ),
          ColorCircleButton(
            onTap: onColorButtonTap,
            color: Colors.lightGreen[200]!,
            selectedColor: _color,
          ),
          ColorCircleButton(
            onTap: onColorButtonTap,
            color: Colors.cyan[200]!,
            selectedColor: _color,
          ),
        ]),
        const SizedBox(height: 15),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          ColorCircleButton(
            onTap: onColorButtonTap,
            color: Colors.indigo[200]!,
            selectedColor: _color,
          ),
          ColorCircleButton(
            onTap: onColorButtonTap,
            color: Colors.pink[200]!,
            selectedColor: _color,
          ),
          ColorCircleButton(
            onTap: onColorButtonTap,
            color: Colors.blueGrey[200]!,
            selectedColor: _color,
          ),
          ColorCircleButton(
            onTap: onColorButtonTap,
            color: Colors.yellow[200]!,
            selectedColor: _color,
          ),
          ColorCircleButton(
            onTap: onColorButtonTap,
            color: Colors.purple[200]!,
            selectedColor: _color,
          ),
        ]),
        const SizedBox(height: 20),
        //Icon selector
        InkWell(
          onTap: () {
            showDialog(
                context: context,
                builder: (context) => EmogiPickerDialog(
                      onEmojiSelected: (emoji) => setState(() {
                        _icon = emoji.emoji;
                      }),
                    ));
          }, //show emoji picker
          child: SizedBox(
            child: Row(children: <Widget>[
              //dotted box with an Image selected
              DottedBorder(
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(3),
                  color: const Color(0xFFBABABA),
                  strokeWidth: 1,
                  child: Container(
                    alignment: Alignment.center,
                    width: 35,
                    height: 35,
                    child: Text(
                      _icon,
                      style: const TextStyle(
                        fontSize: 25,
                      ),
                    ),
                  )),
              const SizedBox(
                width: 18,
              ),
              const Text('Icon: click to choose',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF818181),
                  )),
            ]),
          ),
        ),
        const SizedBox(height: 15),
        //ShowLastnote switcher
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          SizedBox(
            width: 37,
            child: Switch(
              value: _showLastNote,
              onChanged: (value) {
                setState(() {
                  _showLastNote = value;
                });
              },
            ),
          ),
          const SizedBox(
            width: 18,
          ),
          const Text('Show time of the last note',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF818181),
              )),
        ]),
        const SizedBox(height: 15),
      ],
    );
  }

  Future<void> _showCategoryEditDialog(BuildContext context,
      CategoryOption category, CategoryOptionsList categoryOptions) {
    _categoryEditController.text = category.name;
    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
              title: const Text('Edit category name'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    const Text(
                        'Edit the name of category only in case of mistype or better description.'),
                    const SizedBox(height: 10),
                    const Text(
                        'If you need the whole another category: delete this one and create new.'),
                    const SizedBox(height: 10),
                    TextField(
                      autofocus: true,
                      controller: _categoryEditController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () async {
                      bool? validated = await validateUserAction(
                          context: context,
                          validationText:
                              'This will delete the category for all users.');
                      if (validated == true) {
                        categoryOptions.removeOption(category);
                        setState(() {});
                        Navigator.pop(context);
                      }
                    },
                    child: const Text(
                      'Delete category',
                      style: TextStyle(color: Color(0xFFB3261E)),
                    )),
                TextButton(
                    onPressed: () {
                      category.name = _categoryEditController.text;
                      setState(() {});
                      Navigator.pop(context);
                    },
                    child: const Text('Save edit'))
              ]);
        });
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
