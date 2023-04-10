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
import 'view_utilities/ui_widgets.dart';

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
  late TextEditingController _nameController;
  late TextEditingController _metricController;
  late TextEditingController _categoryController;
  late TextEditingController _categoryEditController;
  late TextEditingController _descriptionController;

  late ScrollController _descriptionScrollController;

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
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _metricController = TextEditingController();
    _categoryController = TextEditingController();
    _categoryEditController = TextEditingController();

    _descriptionScrollController = ScrollController();

    //set parameter props when editing
    _editScreen = widget.parameter != null ? true : false;
    if (_editScreen) {
      _parameter = widget.parameter!;
      _nameController.text = _parameter.name;
      _descriptionController.text = _parameter.description;
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
        _metricController.text = _parameter.metric!;
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Step> steps = [
      Step(
        title: _step < 1
            ? const Text('Give a name and description')
            : Text('Name: ${_nameController.text}'),
        content: _buildNameInput(),
      ),
      Step(
          title: _step < 2
              ? const Text('Select Duration type')
              : Text('Duration type: ${_selectedDurationType.name}'),
          subtitle: const Text(
              'Does this parameter occurs as just a moment or the an interval of time?'),
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
        subtitle: const Text('What type would be the value of this parameter?'),
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
    ];

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
              ? const SizedBox
                  .shrink() // no controls when editing: just FAB to SAVE EDIT
              : Row(children: [
                  details.currentStep != (steps.length - 1)
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
        steps: steps,
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
    return Column(
      children: [
        const SizedBox(height: 5),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 15),
        TextField(
          controller: _descriptionController,
          scrollController: _descriptionScrollController,
          keyboardType: TextInputType.multiline,
          minLines: 2,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Description (optional)',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
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
          secondary: DescriptionButton(
            popupTitle: const Text('What is Moment type?'),
            description: _momentDescription(),
          ),
        ),
        RadioListTile<DurationType>(
          title: const Text('Duration'),
          value: DurationType.duration,
          groupValue: _selectedDurationType,
          onChanged: (DurationType? value) {
            setState(() {
              _selectedDurationType = value!;
            });
          },
          secondary: DescriptionButton(
            popupTitle: const Text('What is Duration?'),
            description: _durationDescription(),
          ),
        ),
      ],
    );
  }

  Widget _buildDataTypeInput() {
    return Column(
      children: [
        RadioListTile<VarType>(
          title: const Text('Binary'),
          value: VarType.binary,
          groupValue: _selectedVarType,
          onChanged: (VarType? value) {
            setState(() {
              _selectedVarType = value!;
            });
          },
          secondary: DescriptionButton(
            popupTitle: const Text('What is Binary?'),
            description: _binaryDescription(),
          ),
        ),
        RadioListTile<VarType>(
          title: const Text('Quantitative'),
          value: VarType.quantitative,
          groupValue: _selectedVarType,
          onChanged: (VarType? value) {
            setState(() {
              _selectedVarType = value!;
            });
          },
          secondary: DescriptionButton(
            popupTitle: const Text('What is Quantitative?'),
            description: _quantitativeDescription(),
          ),
        ),
        RadioListTile<VarType>(
          title: const Text('Ordinal'),
          value: VarType.ordinal,
          groupValue: _selectedVarType,
          onChanged: (VarType? value) {
            setState(() {
              _selectedVarType = value!;
            });
          },
          secondary: DescriptionButton(
            popupTitle: const Text('What is Ordinal type?'),
            description: _ordinalDescription(),
          ),
        ),
        RadioListTile<VarType>(
          title: const Text('Categorical'),
          value: VarType.categorical,
          groupValue: _selectedVarType,
          onChanged: (VarType? value) {
            setState(() {
              _selectedVarType = value!;
            });
          },
          secondary: DescriptionButton(
            popupTitle: const Text('What is Categorical type?'),
            description: _categoricalDescription(),
          ),
        ),
        RadioListTile<VarType>(
          title: const Text('Unstructured'),
          value: VarType.unstructured,
          groupValue: _selectedVarType,
          onChanged: (VarType? value) {
            setState(() {
              _selectedVarType = value!;
            });
          },
          secondary: DescriptionButton(
            popupTitle: const Text('What is Unstructured type?'),
            description: _unstructuredDescription(),
          ),
        ),
      ],
    );
  }

  Widget _buildDataPropsInput(BuildContext context) {
    switch (_selectedVarType) {
      case VarType.binary:
        return Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              child: const Text(
                  "Binary parameter doesn't need additional properties. The fact of the occurance is already its value."),
            ),
            const SizedBox(height: 15),
          ],
        );
      case VarType.unstructured:
        return Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              child: const Text(
                  'Your input for unstructured parameter will be plain text.'),
            ),
            const SizedBox(height: 15),
          ],
        );
      case VarType.quantitative:
        return Column(children: [
          const SizedBox(height: 5),
          TextField(
            controller: _metricController,
            decoration: const InputDecoration(
              labelText: 'Select a metric (kg, ml, pcs, times, etc.)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 15),
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
    _nameController.dispose();
    _metricController.dispose();
    _categoryController.dispose();
    _categoryEditController.dispose();
    _descriptionController.dispose();

    _descriptionScrollController.dispose();
    super.dispose();
  }

  Widget _buildCategoryCreator(BuildContext context) {
    return Column(children: [
      Container(
          alignment: Alignment.centerLeft,
          child: const Text('Create categories for your parameter:')),
      const SizedBox(height: 15),
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Type new and click `+ Add`',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          TextButton(
              child: const Text('+ Add'),
              onPressed: () {
                //create category
                CategoryOption newCategoryOption = CategoryOption(
                  id: nanoid(10),
                  name: _categoryController.text,
                );
                //add to categories list
                _categoryOptions.addOption(newCategoryOption);
                //clear
                _categoryController.clear();
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
              //TODO bad - shouldn't have direct access to the list of _categoryoptions
              final CategoryOption item =
                  _categoryOptions.list.removeAt(oldIndex);
              _categoryOptions.list.insert(newIndex, item);
            });
          },
          shrinkWrap: true,
        ),
      ),
      const SizedBox(height: 15),
    ]);
  }

  void _createNewParameter(BuildContext context) {
    String paramName = _nameController.text;

    Provider.of<BoardController>(context, listen: false).createParameter(
        widget.board,
        paramName,
        _selectedDurationType,
        _selectedVarType,
        _metricController.text,
        _categoryOptions,
        _descriptionController.text,
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
          _nameController.text,
          _metricController.text,
          _categoryOptions,
          _descriptionController.text,
          ButtonDecoration(
              color: _color, icon: _icon, showLastNote: _showLastNote));

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${_nameController.text} : parameter edited!'),
        duration: const Duration(seconds: 2),
      ));
    }
  }

  void _onColorButtonTap(buttonColor) {
    setState(() {
      _color = buttonColor;
    });
  }

  Widget _buildDecorationInput(BuildContext context) {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          ColorCircleButton(
            onTap: _onColorButtonTap,
            color: Colors.grey[200]!,
            selectedColor: _color,
          ),
          ColorCircleButton(
            onTap: _onColorButtonTap,
            color: Colors.deepOrange[200]!,
            selectedColor: _color,
          ),
          ColorCircleButton(
            onTap: _onColorButtonTap,
            color: Colors.orange[200]!,
            selectedColor: _color,
          ),
          ColorCircleButton(
            onTap: _onColorButtonTap,
            color: Colors.lightGreen[200]!,
            selectedColor: _color,
          ),
          ColorCircleButton(
            onTap: _onColorButtonTap,
            color: Colors.cyan[200]!,
            selectedColor: _color,
          ),
        ]),
        const SizedBox(height: 15),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          ColorCircleButton(
            onTap: _onColorButtonTap,
            color: Colors.indigo[200]!,
            selectedColor: _color,
          ),
          ColorCircleButton(
            onTap: _onColorButtonTap,
            color: Colors.pink[200]!,
            selectedColor: _color,
          ),
          ColorCircleButton(
            onTap: _onColorButtonTap,
            color: Colors.blueGrey[200]!,
            selectedColor: _color,
          ),
          ColorCircleButton(
            onTap: _onColorButtonTap,
            color: Colors.yellow[200]!,
            selectedColor: _color,
          ),
          ColorCircleButton(
            onTap: _onColorButtonTap,
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

//This should be in ui widgets
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

//DESCRIPTIONS
Widget _momentDescription() {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: const [
      Text.rich(
        TextSpan(children: [
          TextSpan(text: 'Select '),
          TextSpan(
              text: 'Moment', style: TextStyle(fontWeight: FontWeight.w500)),
          TextSpan(text: ' if the duration of the parameter/event/occurance '),
          TextSpan(
              text: 'doesn’t', style: TextStyle(fontWeight: FontWeight.w500)),
          TextSpan(text: ' important for your research.'),
        ]),
      ),
      SizedBox(height: 10),
      Text(
          'For example, I do morning exercises for 15 minutes, but duration is not important for me - the fact of the exercises is.'),
      SizedBox(height: 10),
      Text.rich(TextSpan(children: [
        TextSpan(
            text:
                'On the other hand, if I run 3 km everyday, and I want to know the duration time of my activity, I choose the '),
        TextSpan(
            text: 'Duration', style: TextStyle(fontWeight: FontWeight.w500)),
        TextSpan(text: ' option. '),
      ])),
    ],
  );
}

Widget _durationDescription() {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: const [
      Text.rich(
        TextSpan(children: [
          TextSpan(text: 'Select '),
          TextSpan(
              text: 'Duration', style: TextStyle(fontWeight: FontWeight.w500)),
          TextSpan(text: ' if the duration of the parameter/event/occurance '),
          TextSpan(text: 'does', style: TextStyle(fontWeight: FontWeight.w500)),
          TextSpan(
              text:
                  ' important for your research. Even when the event might be shortlived.'),
        ]),
      ),
      SizedBox(height: 10),
      Text(
          'You will be able to set start and end time of the event, or live record it.'),
      SizedBox(height: 10),
      Text(
          'Examples are: sleeping/reading/working/walking/headache/meditating time and etc.'),
    ],
  );
}

Widget _binaryDescription() {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: const [
      Text.rich(
        TextSpan(children: [
          TextSpan(text: 'Select '),
          TextSpan(
              text: 'Binary', style: TextStyle(fontWeight: FontWeight.w500)),
          TextSpan(
              text:
                  ' if the only important thing you track is the fact of occurrence: whether it was, or it wasn’t. It is yes or no, that is why it is called '),
          TextSpan(
              text: 'Binary', style: TextStyle(fontWeight: FontWeight.w500)),
        ]),
      ),
      SizedBox(height: 10),
      Text(
          "Examples: I had a coffee, changed kid's diapers, played with a dog and etc."),
    ],
  );
}

Widget _quantitativeDescription() {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: const [
      Text.rich(
        TextSpan(children: [
          TextSpan(text: 'Select '),
          TextSpan(
              text: 'Quantitative',
              style: TextStyle(fontWeight: FontWeight.w500)),
          TextSpan(
              text:
                  ', when the value is a number. One the next step you will choose its metric.'),
        ]),
      ),
      SizedBox(height: 10),
      Text(
          "Examples: calories intaken (cal), pushups made (pcs), distance ran (km), water drank (ml) and etc."),
    ],
  );
}

Widget _ordinalDescription() {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: const [
      Text.rich(
        TextSpan(children: [
          TextSpan(text: 'Select '),
          TextSpan(
              text: 'Ordinal', style: TextStyle(fontWeight: FontWeight.w500)),
          TextSpan(
              text:
                  ' if the value differs within a set of ordered values. My headache may be 1.light, 2.heavy and 3.severe - these are ordered possible values. One the next step you will formulate values for this parameter.'),
        ]),
      ),
      SizedBox(height: 10),
      Text(
          "Examples: grade received on exam, rating of the film I’ve watched, the strength of pain."),
    ],
  );
}

Widget _categoricalDescription() {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: const [
      Text.rich(
        TextSpan(children: [
          TextSpan(text: 'Select '),
          TextSpan(
              text: 'Categorical',
              style: TextStyle(fontWeight: FontWeight.w500)),
          TextSpan(
              text:
                  ' if the value differs within a set of unordered values. The coffee you drink might be Latte, Capuccino, Espresso or Macchiato. This set of values cannot be ordered. One the next step you will formulate categories for this parameter.'),
        ]),
      ),
      SizedBox(height: 10),
      Text(
          "Examples: Bristol stool chart, negative emotions experienced, type of yoga attended and etc."),
    ],
  );
}

Widget _unstructuredDescription() {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: const [
      Text.rich(
        TextSpan(children: [
          TextSpan(text: 'Select '),
          TextSpan(
              text: 'Unsctructured',
              style: TextStyle(fontWeight: FontWeight.w500)),
          TextSpan(
              text:
                  ' if the value might be non of the above type. During the input you will type a plain text as a value.'),
        ]),
      ),
      SizedBox(height: 10),
      Text(
          "Examples: the name of the game you played, your big thought, the person you had a deep talk with and etc."),
    ],
  );
}
