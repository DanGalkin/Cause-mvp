import 'package:cause_flutter_mvp/services/firebase_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../model/board.dart';
import '../model/parameter.dart';
import '../controllers/board_controller.dart';
import '../services/service_locator.dart';

import './view_utilities/ordering_utilities.dart';
import './view_utilities/action_validation_utilities.dart';
import './view_utilities/text_utilities.dart';

import './boards_screen.dart';
import './create_parameter_screen.dart';
import './parameter_screen.dart';
import './share_board_screen.dart';
import './analytics_screen.dart';

import '../../model/note.dart';

import 'package:intl/intl.dart';

class BoardScreen extends StatelessWidget {
  final Board board;
  const BoardScreen({Key? key, required this.board}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<FirebaseServices, BoardController>(
        builder: (context, fbServices, boards, child) {
      Board syncedBoard = boards.boards[board.id]!;
      return Scaffold(
        appBar: AppBar(
          title: Text('Board: ${syncedBoard.name}'),
          actions: [
            IconButton(
                icon: const Icon(Icons.analytics),
                tooltip: 'Analytics',
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              AnalyticsScreen(board: syncedBoard)));
                }),
            if (fbServices.currentUser!.uid == syncedBoard.createdBy)
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ShareBoardScreen(board: syncedBoard),
                    )),
              )
          ],
        ),
        body: _buildParameters(context),
        drawer: _buildDrawer(context),
        floatingActionButton: FloatingActionButton.extended(
            label: const Text('PARAMETER'),
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateParameterScreen(board: board),
                ))),
      );
    });
  }

  Widget _buildDrawer(BuildContext context) {
    return Consumer2<BoardController, FirebaseServices>(
        builder: (context, boards, fbServices, child) {
      return Drawer(
        child: ListView(padding: EdgeInsets.zero, children: [
          DrawerHeader(
            child: GestureDetector(
                child: RichText(
                    text: TextSpan(
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.w700),
                        children: [
                      const TextSpan(
                          text: 'Your boards,',
                          style:
                              TextStyle(decoration: TextDecoration.underline)),
                      TextSpan(text: ' ${fbServices.currentUser!.displayName}!')
                    ])),
                onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BoardsScreen(),
                    ))),
          ),
          for (Board board in boards.boards.values)
            ListTile(
              title: Text(board.name),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BoardScreen(board: board),
                    ));
              },
            )
        ]),
      );
    });
  }

  Widget _buildParameters(BuildContext context) {
    return Consumer<BoardController>(builder: (context, boards, child) {
      Board syncedBoard = boards.boards[board.id]!;
      List<Parameter> paramList = orderedParamList(syncedBoard);
      return Scrollbar(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: ListView.separated(
            itemCount: paramList.length + 1,
            itemBuilder: (context, index) {
              if (index == paramList.length) {
                return const SizedBox(height: 50);
              } else {
                Parameter parameter = paramList[index];
                return Slidable(
                  key: ValueKey(parameter.id),
                  endActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CreateParameterScreen(
                                        board: syncedBoard,
                                        parameter: parameter,
                                      )));
                        },
                        backgroundColor: Colors.grey.shade700,
                        foregroundColor: Colors.white,
                        icon: Icons.edit_note,
                        label: 'Edit',
                      ),
                      SlidableAction(
                        onPressed: (context) async {
                          bool? validated = await validateUserAction(
                              context: context,
                              validationText:
                                  'Parameter and all its notes will be deleted for all users.');
                          if (validated == true) {
                            getIt<BoardController>()
                                .deleteParameter(syncedBoard, parameter);
                          }
                        },
                        backgroundColor: const Color(0xFFFE4A49),
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                    ],
                  ),
                  child: Center(
                    child: ParameterButton(
                      parameter: parameter,
                      board: syncedBoard,
                    ),
                  ),
                );
              }
            },
            separatorBuilder: ((context, index) => const SizedBox(height: 15)),
          ),
        ),
      );
    });
  }
}

class ParameterButton extends StatelessWidget {
  const ParameterButton({
    super.key,
    required this.parameter,
    required this.board,
  });
  final Parameter parameter;
  final Board board;

  @override
  Widget build(BuildContext context) {
    Note? lastNote = parameter.lastNote;
    bool showLastNote = lastNote != null && parameter.decoration.showLastNote;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ParameterScreen(parameter: parameter, board: board)),
        );
      },
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
                        parameter.name,
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  //show Last note, if this decoration option is on and parameter is not recorded
                  if (showLastNote && parameter.recordState.recording == false)
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
                  if (parameter.recordState.recording == true)
                    Flexible(
                      child: FittedBox(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          showStartOfRecording(parameter),
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
            if (parameter.durationType == DurationType.duration &&
                parameter.recordState.recording == false)
              IconButton(
                  onPressed: () {
                    getIt<BoardController>().startRecording(board, parameter);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content:
                          Text('${parameter.name} : recording has started!'),
                      duration: const Duration(seconds: 2),
                    ));
                  },
                  icon: const Icon(Icons.play_arrow_outlined,
                      color: Colors.green)),
            if (parameter.durationType == DurationType.duration &&
                parameter.recordState.recording == true)
              Row(
                children: [
                  IconButton(
                      onPressed: () {
                        getIt<BoardController>()
                            .addRecordingNote(board, parameter);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              '${parameter.name} : note added and recording stopped.'),
                          duration: const Duration(seconds: 2),
                        ));
                      },
                      icon: const Icon(Icons.pause_outlined,
                          color: Colors.green)),
                  IconButton(
                      onPressed: () {
                        getIt<BoardController>()
                            .cancelRecording(board, parameter);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              '${parameter.name} : recording was cancelled!'),
                          duration: const Duration(seconds: 2),
                        ));
                      },
                      icon:
                          const Icon(Icons.cancel_outlined, color: Colors.red)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
