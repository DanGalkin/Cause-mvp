import 'package:cause_flutter_mvp/services/firebase_services.dart';
import 'package:cause_flutter_mvp/view/view_utilities/ui_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../model/board.dart';
import './create_board_screen.dart';
import './board_screen.dart';
import '../controllers/board_controller.dart';
import 'edit_board_screen.dart';
import 'main_drawer.dart';
import 'view_utilities/action_validation_utilities.dart';

class BoardsScreen extends StatelessWidget {
  const BoardsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<BoardController, FirebaseServices>(
        builder: (context, boards, fbservices, child) {
      return Scaffold(
          appBar: AppBar(
            title: Text(fbservices.loggedIn
                ? 'Your boards, ${fbservices.currentUser!.displayName}'
                : 'Hi, visitor!'),
          ),
          drawer: const MainDrawer(),
          body: Scrollbar(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: boards.boards.isEmpty
                  //Widget shown when user has no boards at all
                  ? Center(
                      child: SizedBox(
                        width: 320,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            SizedBox(
                              width: 320,
                              child: Center(
                                child: Headline(
                                  'You have no boards: create one with +BOARD button below.',
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            SizedBox(
                              width: 320,
                              child: Headline(
                                  'Board - is a workspace for gathering and analyzing data to solve the problem you posed.'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: boards.boards.length + 1,
                      itemBuilder: ((context, index) {
                        if (index == boards.boards.length) {
                          //here is a footer with a hint and space for a FAB
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              SizedBox(height: 10),
                              SizedBox(
                                width: 320,
                                child: Center(
                                  child: Text(
                                    '<-- Swipe left the Board button to edit or delete',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 184, 184, 184),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 50),
                            ],
                          );
                        } else {
                          //here is a builder of slidable board buttons
                          Board board = boards.boards.values.toList()[index];
                          return Slidable(
                            key: ValueKey(board.id),
                            endActionPane: ActionPane(
                              motion: const DrawerMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (context) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                EditBoardScreen(
                                                  board: board,
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
                                            'This board will be deleted from your boards. Other collaborators will still have access to it.');
                                    if (validated == true) {
                                      boards.removeBoard(board);
                                    }
                                  },
                                  backgroundColor: const Color(0xFFFE4A49),
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: 'Delete',
                                ),
                              ],
                            ),
                            child: Center(child: BoardButton(board: board)),
                          );
                        }
                      }),
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 15),
                    ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            label: const Text('BOARD'),
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: ((context) => const CreateBoardScreen()),
                  ));
            },
          ));
    });
  }
}

class BoardButton extends StatelessWidget {
  const BoardButton({required this.board, super.key});

  final Board board;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: ((context) => BoardScreen(board: board))));
        },
        child: Container(
            height: 60,
            width: 320,
            decoration: BoxDecoration(
                color: Colors.blue[700],
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 1,
                    spreadRadius: 1,
                    offset: Offset(0, 1),
                  ),
                ]),
            padding: const EdgeInsets.only(left: 25, right: 15),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 30,
                      child: FittedBox(
                        //fit: BoxFit.fitWidth,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          board.name != '' ? board.name : ' ',
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  board.hasDescription
                      ? IconButton(
                          icon: const Icon(Icons.info, color: Colors.white),
                          onPressed: () => _showDescription(context),
                        )
                      : const SizedBox(width: 25),
                ])));
  }

  Future<void> _showDescription(BuildContext context) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text('${board.name}: Description'),
              content: Text(board.description!),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Ok'))
              ]);
        });
  }
}
