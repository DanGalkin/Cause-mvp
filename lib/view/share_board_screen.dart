import 'package:cause_flutter_mvp/view/view_utilities/ui_widgets.dart';
import 'package:flutter/material.dart';
import '../model/board.dart';
import '../services/service_locator.dart';
import '../controllers/board_controller.dart';

class ShareBoardScreen extends StatefulWidget {
  const ShareBoardScreen({required this.board, super.key});
  final Board board;

  @override
  State<ShareBoardScreen> createState() => _ShareBoardScreenState();
}

class _ShareBoardScreenState extends State<ShareBoardScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Share board: ${widget.board.name}')),
      body: Padding(
          padding: const EdgeInsets.all(15),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 15),
                const Headline('Input email to share with:'),
                TextField(controller: _controller),
              ],
            ),
          )),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.share),
        label: const Text('Share'),
        onPressed: () {
          _validateAndShare(widget.board, _controller.text, context);
        },
      ),
    );
  }

  Future<void> _validateAndShare(
      Board board, String email, BuildContext context) async {
    //if email doesn't exist
    String? uid = await getIt<BoardController>().uidByEmail(email);
    //show notification and do nothing
    if (uid == null) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Email not found :('),
              content: const Text(
                  'To share a board you should input email of a user that already using Cause'),
              actions: [
                TextButton(
                    child: const Text('Ok'),
                    onPressed: () => Navigator.of(context).pop())
              ],
            );
          },
          barrierDismissible: true);
    } else {
      await getIt<BoardController>().shareBoardByUid(board, uid);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Board ${board.name} shared with $email')));
    }
  }
}
