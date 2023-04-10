import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../controllers/board_controller.dart';
import '../model/board.dart';
import '../services/analytics_utilities/export_csv.dart';
import '../services/firebase_services.dart';
import '../services/service_locator.dart';
import 'share_edit_screen.dart';
import 'view_utilities/ui_widgets.dart';

class SharingBoardScreen extends StatefulWidget {
  const SharingBoardScreen({required this.board, super.key});

  final Board board;

  @override
  State<SharingBoardScreen> createState() => _SharingBoardScreenState();
}

class _SharingBoardScreenState extends State<SharingBoardScreen> {
  late Future<String> _creator;
  late Future<List<String>> _collaborators;
  late String? _templateId;
  late bool _userIsCreator;

  @override
  void initState() {
    _creator = _getCreatorEmail();
    _collaborators = _getCollaboratorsEmails();
    _templateId = widget.board.templateId;
    _userIsCreator =
        getIt<FirebaseServices>().currentUser?.uid == widget.board.createdBy;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Sharing: ${widget.board.name}')),
        body: Padding(
            padding: const EdgeInsets.all(15),
            child: Scrollbar(
                child: SingleChildScrollView(
                    child: Center(
                        child: SizedBox(
                            width: 320,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildCollaboratorOption(context),
                                _buildDivider(),
                                _buildTemplateOption(context),
                                _buildDivider(),
                                _buildExportOption(context),
                              ],
                            )))))));
  }

  Future<String> _getCreatorEmail() async {
    String? retrievedEmail =
        await getIt<FirebaseServices>().emailByUid(widget.board.createdBy);
    return retrievedEmail ?? 'user does not exist';
  }

  Future<List<String>> _getCollaboratorsEmails() async {
    Map permissions = widget.board.permissions;
    List<String> emails = [];
    for (String uid in permissions.keys) {
      String? email = await getIt<FirebaseServices>().emailByUid(uid);
      if (email != null) emails.add(email);
    }
    return emails;
  }

  Widget _buildCollaboratorOption(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 15),
        const TitleLine('1. Collaborate (full sharing)'),
        //Shared with info HERE
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Headline('Creator:'),
            //get the
            FutureBuilder(
                future: _creator,
                builder: (context, AsyncSnapshot<String> creator) {
                  return Text(creator.data ?? '...loading');
                }),
            const SizedBox(height: 10),
            //if there are any collaborators, show section
            if (widget.board.permissions.isNotEmpty)
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Headline('Collaborators:'),
                FutureBuilder(
                    future: _collaborators,
                    builder:
                        (context, AsyncSnapshot<List<String>> collaborators) {
                      if (collaborators.hasData) {
                        return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (String email in collaborators.data!)
                                Column(
                                  children: [
                                    Text(email),
                                    const SizedBox(height: 10),
                                  ],
                                )
                            ]);
                      } else {
                        return const Text('...loading');
                      }
                    }),
              ]),
            const SizedBox(height: 10),
          ],
        ),

        //Share edit via email button
        ToolButton(
            title: 'Share edit via email',
            icon: const Icon(Icons.send),
            disabled: !_userIsCreator,
            onDisabledTap: () {
              _showNotCreatorDialog(context);
            },
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ShareEditScreen(board: widget.board),
                )),
            popupDescription: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                    'Collaborators will have the permission to add new notes and change parameters (data structure) of the board.'),
                SizedBox(height: 10),
                Text('They will see your data and be able to modify it.'),
                SizedBox(height: 10),
                Text(
                    'They will not have rights to share the board with other collaborators or create/update board template.'),
              ],
            )),
      ],
    );
  }

  Widget _buildTemplateOption(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TitleLine('2. Share template'),
          ToolButton(
              title: _templateId != null
                  ? 'Update template'
                  : 'Share board template',
              icon: const Icon(Icons.offline_share),
              disabled: !_userIsCreator,
              onDisabledTap: () {
                _showNotCreatorDialog(context);
              },
              onPressed: () {
                getIt<BoardController>()
                    .updateTemplateFromBoard(widget.board)
                    .then((value) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        'Board template ${_templateId == null ? 'created' : 'updated'}.'),
                    duration: const Duration(seconds: 2),
                  ));

                  setState(() {
                    _templateId = value;
                  });
                });
              },
              popupDescription: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                      'With generated template code other users will be able to create their own boards with the data structure of this board.'),
                  SizedBox(height: 10),
                  Text(
                      'Your data will not be included. Only the data structure: empty parameters and their properties.'),
                ],
              )),
          if (_templateId != null)
            Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),
                  Headline(
                      'Last updated: ${DateFormat.yMMMd().add_Hm().format(widget.board.templateUpdatedTime!)}'),
                  const SizedBox(height: 15),
                  ToolButton(
                      title: 'Template code: $_templateId',
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        //copy code to clipboard
                        Clipboard.setData(ClipboardData(text: _templateId))
                            .then((_) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text('Template code copied to clipboard.'),
                            duration: Duration(seconds: 2),
                          ));
                        });
                        //notify that code copied
                      }),
                ])
        ]);
  }

  Widget _buildDivider() {
    return Column(children: const [
      SizedBox(height: 20),
      Divider(
        thickness: 2,
      ),
      SizedBox(height: 20),
    ]);
  }

  Widget _buildExportOption(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TitleLine('3. Share raw data'),
        ToolButton(
            title: 'Export Data in .csv',
            icon: const Icon(Icons.share),
            popupDescription: const Text(
                'Export your gathered data in a simple csv format so you can play with it or share (with a coach or a doctor)'),
            onPressed: () {
              exportCSVData(widget.board);
            }),
      ],
    );
  }

  Future<void> _showNotCreatorDialog(BuildContext context) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
              title: const Text('Sorry'),
              content: const Text(
                  'Only the creator of the board can use this sharing option'),
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
