import 'package:flutter/material.dart';
import '../../model/parameter.dart';
import '../../model/note.dart';
import '../../model/board.dart';
import '../parameter_screen.dart';

import './text_utilities.dart';

class Headline extends StatelessWidget {
  const Headline(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          text,
          textAlign: TextAlign.left,
          style: const TextStyle(
            color: Color(0xFF7B7B7B),
            fontWeight: FontWeight.w500,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class ParameterButtonTemplate extends StatelessWidget {
  const ParameterButtonTemplate({
    super.key,
    required this.parameter,
    this.onTap,
    this.subtitle,
    this.trailing,
  });
  final Parameter parameter;
  final VoidCallback? onTap;
  final Widget? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        width: 320,
        decoration: BoxDecoration(
          color: parameter.decoration.color,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.fromLTRB(13, 5, 5, 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              alignment: Alignment.center,
              width: 35,
              height: 35,
              child: Text(
                parameter.decoration.icon,
                style: const TextStyle(
                  fontSize: 25,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 30,
                    child: FittedBox(
                      //fit: BoxFit.fitWidth,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        parameter.name != '' ? parameter.name : ' ',
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  //show Last note, if this decoration option is on and parameter is not recorded
                  if (subtitle != null)
                    Flexible(
                      child: FittedBox(
                          alignment: Alignment.centerLeft, child: subtitle),
                    ),
                ],
              ),
            ),
            trailing != null ? trailing! : const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }
}

class ChartLabel extends StatelessWidget {
  const ChartLabel({required this.parameter, this.onTap, super.key});

  final Parameter parameter;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(3),
          height: 20,
          decoration: BoxDecoration(
            color: parameter.decoration.color,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(parameter.name, style: const TextStyle(fontSize: 12)),
        ));
  }
}

class RemovableParameterTitle extends StatelessWidget {
  const RemovableParameterTitle(
      {super.key, required this.parameter, required this.onRemove});

  final Parameter parameter;
  final void Function(Parameter parameter) onRemove;

  @override
  Widget build(BuildContext context) {
    return ParameterButtonTemplate(
        parameter: parameter,
        trailing: IconButton(
            icon: const Icon(Icons.delete_outlined, color: Color(0xFFFE4A49)),
            onPressed: () => onRemove(parameter)));
  }
}

class NoteTile extends StatelessWidget {
  const NoteTile(
      {required this.note,
      required this.board,
      required this.parameter,
      super.key});

  final Note note;
  final Parameter parameter;
  final Board board;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (parameter.durationType == DurationType.duration)
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                toContextualDuration(note.duration!),
                style: const TextStyle(
                  color: Color(0xFF7B7B7B),
                ),
              ),
              SizedBox(height: 5),
              Text(
                parameter.varType != VarType.categorical &&
                        parameter.varType != VarType.ordinal
                    ? note.value[parameter.varType.name]['value'].toString()
                    : note.value[parameter.varType.name]['name'],
                style: const TextStyle(
                  color: Color(0xFF7B7B7B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        if (parameter.durationType == DurationType.moment)
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 170,
                  child: Text(
                    toContextualMoment(note.moment!),
                    style: const TextStyle(
                      color: Color(0xFF7B7B7B),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    parameter.varType != VarType.categorical &&
                            parameter.varType != VarType.ordinal
                        ? note.value[parameter.varType.name]['value'].toString()
                        : note.value[parameter.varType.name]['name'],
                    style: const TextStyle(
                      color: Color(0xFF7B7B7B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        IconButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ParameterScreen(
                          board: board,
                          parameter: parameter,
                          noteToEdit: note,
                        )));
          },
          icon: const Icon(
            Icons.edit_note,
            color: Color(0xFF7B7B7B),
          ),
        ),
      ],
    );
  }
}

class ToolButton extends StatelessWidget {
  const ToolButton({
    required this.title,
    required this.icon,
    required this.onPressed,
    this.popupDescription,
    this.popupTitle,
    super.key,
  });
  final String title;
  final Icon icon;
  final VoidCallback onPressed;
  final Widget? popupDescription;
  final Widget? popupTitle;

  Future<void> _showDescription(BuildContext context) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
              title: popupTitle ?? Text(title),
              content: popupDescription,
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Ok'))
              ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Ink(
        height: 60,
        width: 320,
        decoration: BoxDecoration(
          color: const Color(0xFFEEEEEE),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFF2196F3),
          ),
        ),
        child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onPressed,
            child: Container(
              padding: const EdgeInsets.fromLTRB(13, 5, 5, 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      icon,
                      const SizedBox(width: 20),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  if (popupDescription != null)
                    IconButton(
                      icon: const Icon(Icons.info),
                      onPressed: () {
                        _showDescription(context);
                      },
                    ),
                ],
              ),
            )));
  }
}
