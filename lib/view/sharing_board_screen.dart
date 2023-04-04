import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../controllers/board_controller.dart';
import '../model/board.dart';
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

  @override
  void initState() {
    _creator = _getCreatorEmail();
    _collaborators = _getCollaboratorsEmails();
    _templateId = widget.board.templateId;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<FirebaseServices, BoardController>(
        builder: (context, fbServices, boards, child) {
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
                                  const SizedBox(height: 15),
                                  //Shared with info HERE
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Headline('Creator:'),
                                      //get the
                                      FutureBuilder(
                                          future: _creator,
                                          builder: (context,
                                              AsyncSnapshot<String> creator) {
                                            return Text(
                                                creator.data ?? '...loading');
                                          }),
                                      const SizedBox(height: 10),
                                      //if there are any collaborators, show section
                                      if (widget.board.permissions.isNotEmpty)
                                        Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Headline('Collaborators:'),
                                              FutureBuilder(
                                                  future: _collaborators,
                                                  builder: (context,
                                                      AsyncSnapshot<
                                                              List<String>>
                                                          collaborators) {
                                                    if (collaborators.hasData) {
                                                      return Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            for (String email
                                                                in collaborators
                                                                    .data!)
                                                              Column(
                                                                children: [
                                                                  Text(email),
                                                                  const SizedBox(
                                                                      height:
                                                                          10),
                                                                ],
                                                              )
                                                          ]);
                                                    } else {
                                                      return const Text(
                                                          '...loading');
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
                                      onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ShareEditScreen(
                                                    board: widget.board),
                                          )),
                                      popupDescription: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Text(
                                              'Collaborators will have the permission to add new notes and change parameters (data structure) of the board.'),
                                          SizedBox(height: 10),
                                          Text(
                                              'They will not have rights to share the board edit or board template.'),
                                        ],
                                      )),
                                  const SizedBox(height: 20),
                                  const Divider(),
                                  const SizedBox(height: 20),
                                  //Share board template section HERE
                                  ToolButton(
                                      title: _templateId != null
                                          ? 'Update template'
                                          : 'Share board template',
                                      icon: const Icon(Icons.offline_share),
                                      onPressed: () {
                                        boards
                                            .updateTemplateFromBoard(
                                                widget.board)
                                            .then((value) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            content: Text(
                                                'Board template ${_templateId == null ? 'created' : 'updated'}.'),
                                            duration:
                                                const Duration(seconds: 2),
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
                                              'This action will generate a code. With this code other users will be able to create boards with the data structure of this board.'),
                                          SizedBox(height: 10),
                                          Text(
                                              'Your data will not be included. Only the data structure: empty parameters and their properties.'),
                                        ],
                                      )),
                                  if (_templateId != null)
                                    Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 15),
                                          Headline(
                                              'Last updated: ${DateFormat.yMMMd().add_Hm().format(widget.board.templateUpdatedTime!)}'),
                                          const SizedBox(height: 15),
                                          ToolButton(
                                              title:
                                                  'Template code: $_templateId',
                                              icon: const Icon(Icons.copy),
                                              onPressed: () {
                                                //copy code to clipboard
                                                Clipboard.setData(ClipboardData(
                                                        text: _templateId))
                                                    .then((_) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                          const SnackBar(
                                                    content: Text(
                                                        'Template code copied to clipboard.'),
                                                    duration:
                                                        Duration(seconds: 2),
                                                  ));
                                                });
                                                //notify that code copied
                                              }),
                                        ])
                                ],
                              )))))));
    });
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
}
