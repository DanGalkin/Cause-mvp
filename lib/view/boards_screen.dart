import 'package:cause_flutter_mvp/services/firebase_services.dart';
import 'package:cause_flutter_mvp/view/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/board.dart';
import './create_board_screen.dart';
import './board_screen.dart';
import '../controllers/board_controller.dart';
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
                ? 'Your boards, ${fbservices.currentUser!.displayName}:'
                : 'Hi, visitor!'),
            automaticallyImplyLeading: false,
            actions: [
              fbservices.loggedIn
                  ? IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () {
                        fbservices.signOut().then((_) {
                          Navigator.of(context)
                              .pushReplacement(MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ));
                        });
                      },
                    )
                  : IconButton(
                      icon: const Icon(Icons.login),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ));
                      }),
            ],
          ),
          body: ListView.separated(
            itemCount: boards.boards.length,
            itemBuilder: ((context, index) => Dismissible(
                  key: ValueKey(boards.boards[index]),
                  background: Container(color: Colors.red),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) {
                    return validateUserAction(
                        context: context,
                        validationText:
                            'This board will be deleted from your boards. Other users can still have access to it.');
                  },
                  onDismissed: (_) {
                    Provider.of<BoardController>(context, listen: false)
                        .removeBoard(boards.boards.values.toList()[index]);
                  },
                  child: ListTile(
                    title: Text(
                      boards.boards.values.toList()[index].name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: ((context) => BoardScreen(
                                  board:
                                      boards.boards.values.toList()[index]))));
                    },
                  ),
                )),
            separatorBuilder: (context, index) => const Divider(),
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
