import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/board_controller.dart';

import './view_utilities/ui_widgets.dart';

import '../model/parameter.dart';
import '../model/note.dart';
import '../model/board.dart';

class NotesListScreen extends StatelessWidget {
  const NotesListScreen(
      {required this.board, required this.parameter, Key? key})
      : super(key: key);
  final Board board;
  final Parameter parameter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Notes of:  ${parameter.decoration.icon}  ${parameter.name}'),
        backgroundColor: parameter.decoration.color,
        foregroundColor: Colors.black,
      ),
      body: Consumer<BoardController>(builder: (context, boards, child) {
        Parameter syncedParam = boards.boards[board.id]!.params[parameter.id]!;
        return Padding(
          padding: const EdgeInsets.all(15.0),
          child: ListView.separated(
            itemCount: syncedParam.notes.keys.length,
            itemBuilder: (context, index) {
              String noteId = syncedParam.notes.keys.elementAt(index);
              Note note = syncedParam.notes[noteId]!;
              return NoteTile(
                note: note,
                parameter: parameter,
              );
            },
            separatorBuilder: (context, index) => const Divider(),
          ),
        );
      }),
    );
  }
}
