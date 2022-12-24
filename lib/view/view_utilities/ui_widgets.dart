import 'package:flutter/material.dart';
import '../../model/parameter.dart';
import '../../model/note.dart';

import './text_utilities.dart';

import 'package:intl/intl.dart';

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

class ParameterButtonTitle extends StatelessWidget {
  const ParameterButtonTitle({
    super.key,
    required this.parameter,
  });
  final Parameter parameter;

  @override
  Widget build(BuildContext context) {
    Note? lastNote = parameter.lastNote;
    bool showLastNote = lastNote != null && parameter.decoration.showLastNote;
    return Container(
        height: 60,
        width: 320,
        decoration: BoxDecoration(
          color: parameter.decoration.color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
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
                        alignment: Alignment.centerLeft,
                        child: Text(
                          parameter.name,
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    if (showLastNote)
                      Flexible(
                        child: FittedBox(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            getLastNoteString(lastNote),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF7B7B7B),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ));
  }
}

class NoteTile extends StatelessWidget {
  const NoteTile({required this.note, required this.parameter, super.key});

  final Note note;
  final Parameter parameter;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (parameter.durationType == DurationType.duration)
          Text(
            '${DateFormat.yMMMd().add_Hm().format(note.duration!.start)} - ${DateFormat.yMMMd().add_Hm().format(note.duration!.end)}',
            style: const TextStyle(
              color: Color(0xFF7B7B7B),
            ),
          ),
        if (parameter.durationType == DurationType.moment)
          Row(
            children: [
              SizedBox(
                width: 170,
                child: Text(
                  DateFormat.yMMMd().add_Hm().format(note.moment!),
                  style: const TextStyle(
                    color: Color(0xFF7B7B7B),
                  ),
                ),
              ),
              Text(
                parameter.varType != VarType.categorical
                    ? note.value[parameter.varType.name]['value'].toString()
                    : note.value[parameter.varType.name]['name'],
                style: const TextStyle(
                  color: Color(0xFF7B7B7B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        IconButton(
          onPressed: () {
            // Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //         builder: (context) => EditNoteScreen(
            //               button: button,
            //               note: note,
            //             )));
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
    this.description = '',
    super.key,
  });
  final String title;
  final Icon icon;
  final VoidCallback onPressed;
  final String description;

  Future<void> _showDescription(BuildContext context) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text(title),
              content: Text(description),
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
                  if (description.isNotEmpty)
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
