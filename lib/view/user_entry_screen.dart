import 'package:flutter/material.dart';

import '../services/service_locator.dart';

import '../controllers/board_controller.dart';
import '../view/boards_screen.dart';

class UserEntryScreen extends StatefulWidget {
  const UserEntryScreen({Key? key}) : super(key: key);

  @override
  State<UserEntryScreen> createState() => _UserEntryScreenState();
}

class _UserEntryScreenState extends State<UserEntryScreen> {
  bool _storageUpdatedAfterStart = false;
  final boardController = getIt<BoardController>();

  @override
  void initState() {
    super.initState();

    _syncStorage();
  }

  void _syncStorage() async {
    if (!mounted) return;

    boardController.updateBoardsOfCurrentUser().whenComplete(() {
      setState(() {
        _storageUpdatedAfterStart = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_storageUpdatedAfterStart == true) {
      return const BoardsScreen();
    } else {
      return _buildWhileLoading();
    }
  }

  Widget _buildWhileLoading() {
    return Scaffold(
        appBar: AppBar(title: const Text('Syncing with database...')),
        body: const Center(child: CircularProgressIndicator()));
  }
}
