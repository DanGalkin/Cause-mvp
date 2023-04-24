import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../controllers/board_controller.dart';
import '../services/firebase_services.dart';

import './boards_screen.dart';
import './board_screen.dart';

import '../model/board.dart';
import 'login_screen.dart';
import 'settings_screen.dart';
import 'view_utilities/ui_widgets.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<BoardController, FirebaseServices>(
        builder: (context, boards, fbServices, child) {
      final String? userName = fbServices.currentUser?.displayName;
      final String? email = fbServices.currentUser?.email;
      return Drawer(
        child: ListView(padding: EdgeInsets.zero, children: [
          DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: FittedBox(
                          alignment: Alignment.centerLeft,
                          fit: BoxFit.scaleDown,
                          child: GestureDetector(
                            onTap: () {
                          Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const BoardsScreen()));
                        },
                            child: Text(
                              userName ?? 'Hi, visitor!',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const SettingsScreen()));
                          },
                          icon:
                              const Icon(Icons.settings, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: FittedBox(
                                alignment: Alignment.centerLeft,
                                fit: BoxFit.scaleDown,
                                child: Text(email ?? ' ',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    )),
                              ),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _showContactUsDialog(context);
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white,
                          ),
                          icon:
                              const Icon(Icons.help_outline_outlined, size: 16),
                          label: const Text('Contact us'),
                        )
                      ],
                    ),
                  ),
                ],
              )),
          ListTile(
              title: const Text('All boards',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const BoardsScreen()));
              }),
          for (Board board in boards.boards.values)
            ListTile(
              title: Text(board.name),
              onTap: () {
                Navigator.pop(context);
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

  Future<void> _showContactUsDialog(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Bug? Question? Request?'),
              content: SingleChildScrollView(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Advice? Write to me, if you have any:'),
                  const SizedBox(height: 8),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        emailMe();
                        // Clipboard.setData(
                        //         const ClipboardData(text: 'dangalkin@hey.com'))
                        //     .then((_) {
                        //   ScaffoldMessenger.of(context)
                        //       .showSnackBar(const SnackBar(
                        //     content: Text('Email copied to clipboard.'),
                        //     duration: Duration(seconds: 2),
                        //   ));
                        // });
                      },
                      child: const Text('dangalkin@hey.com'))
                ],
              )),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK')),
              ],
            ));
  }
}
