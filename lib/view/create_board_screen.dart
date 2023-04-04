import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/board_controller.dart';
import 'create_board_from_template.dart';
import 'view_utilities/ui_widgets.dart';

class CreateBoardScreen extends StatefulWidget {
  const CreateBoardScreen({Key? key}) : super(key: key);

  @override
  State<CreateBoardScreen> createState() => _CreateBoardScreenState();
}

class _CreateBoardScreenState extends State<CreateBoardScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create new Board')),
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
                  const Headline('Create new from scratch:'),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Name of new board',
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
                  const SizedBox(height: 40),
                  const Headline('Or copy from template:'),
                  ToolButton(
                      title: 'Enter template code',
                      icon: const Icon(Icons.offline_share),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const CreateFromTemplateScreen()));
                      })
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: createBoard,
          icon: const Icon(Icons.add),
          label: const Text('CREATE')),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void createBoard() {
    String name = _nameController.text;
    String description = _descriptionController.text;
    Provider.of<BoardController>(context, listen: false)
        .createBoard(name: name, description: description);
    //setState(() {}); // refactor: do I need it?
    Navigator.pop(context);
  }
}
