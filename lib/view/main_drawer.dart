import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/board_controller.dart';
import '../services/firebase_services.dart';

import './boards_screen.dart';
import './board_screen.dart';

import '../model/board.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
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
}
