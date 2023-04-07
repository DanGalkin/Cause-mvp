import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/board_controller.dart';
import '../model/board.dart';

class EditBoardScreen extends StatefulWidget {
  const EditBoardScreen({required this.board, Key? key}) : super(key: key);

  final Board board;

  @override
  State<EditBoardScreen> createState() => _EditBoardScreenState();
}

class _EditBoardScreenState extends State<EditBoardScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    _nameController = TextEditingController();
    _nameController.text = widget.board.name;

    _descriptionController = TextEditingController();
    _descriptionController.text = widget.board.description ?? '';

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final board = widget.board;
    return Scaffold(
      appBar: AppBar(title: Text('${board.name}: edit Board')),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: 320,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Name',
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Description',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () => updateBoardInfo(board).then((_) {
                Navigator.pop(context);
              }),
          icon: const Icon(Icons.edit),
          label: const Text('SAVE')),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> updateBoardInfo(Board board) async {
    String name = _nameController.text;
    String? description =
        _descriptionController.text == '' ? null : _descriptionController.text;
    await Provider.of<BoardController>(context, listen: false)
        .updateBoardInfo(board: board, name: name, description: description);
  }
}
