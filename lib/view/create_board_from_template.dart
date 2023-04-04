import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/board_controller.dart';
import '../model/template.dart';
import 'boards_screen.dart';
import 'view_utilities/ui_widgets.dart';

class CreateFromTemplateScreen extends StatefulWidget {
  const CreateFromTemplateScreen({Key? key}) : super(key: key);

  @override
  State<CreateFromTemplateScreen> createState() =>
      _CreateFromTemplateScreenState();
}

class _CreateFromTemplateScreenState extends State<CreateFromTemplateScreen> {
  late TextEditingController _templateCode;
  bool _templateFound = false;
  bool _searchingTemplate = false;
  bool _showResults = false;
  Template? _template;

  @override
  void initState() {
    _templateCode = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create from Template')),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: 320,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  const Headline('Create a board from template:'),
                  TextField(
                    controller: _templateCode,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Template code',
                    ),
                  ),
                  const SizedBox(height: 15),
                  ToolButton(
                      title: _searchingTemplate == false
                          ? 'Check the code'
                          : 'Searching...',
                      icon: const Icon(Icons.question_mark),
                      onPressed: () async {
                        _searchingTemplate = true;
                        setState(() {});
                        _template = await _searchTemplate();
                        _showResults = true;
                        _searchingTemplate = false;
                        setState(() {});
                      }),
                  if (_showResults == true)
                    _template == null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              SizedBox(height: 20),
                              Headline(
                                  'Template not found. Please, check the code.')
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 20),
                              const Headline('Template found!'),
                              const Headline('Name:'),
                              Text(_template!.name),
                              const SizedBox(height: 15),
                              const Headline('Description:'),
                              Text(_template!.description ??
                                  'no description provided'),
                            ],
                          )
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: _template == null
              ? null
              : () {
                  //createBoardFromTemplate
                  Provider.of<BoardController>(context, listen: false)
                      .createBoardFromTemplate(_template!)
                      .then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Board ${_template!.name} created!'),
                      duration: const Duration(seconds: 2),
                    ));
                  });
                  //get back to boards
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const BoardsScreen()));
                },
          backgroundColor: _template == null ? Colors.grey : null,
          icon: const Icon(Icons.add),
          label: const Text('CREATE')),
    );
  }

  @override
  void dispose() {
    _templateCode.dispose();
    super.dispose();
  }

  //returns null if template does not exist
  Future<Template?> _searchTemplate() async {
    return await Provider.of<BoardController>(context, listen: false)
        .getTemplateById(_templateCode.text);
  }
}
