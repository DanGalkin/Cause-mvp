import 'package:cause_flutter_mvp/model/category_option.dart';
import 'package:cause_flutter_mvp/services/firebase_services.dart';
import 'package:flutter/material.dart';
import 'package:nanoid/nanoid.dart';

import '../model/board.dart';
import '../model/parameter.dart';
import '../model/note.dart';
import '../model/button_decoration.dart';

import '../services/board_services.dart';
import '../services/service_locator.dart';

class BoardController extends ChangeNotifier {
  final services = getIt<BoardServices>();
  final fbServices = getIt<FirebaseServices>();

  //THERE ARE DIRECT CONTROLLER - FBSERVICES METHODS
  Map<String, Board> _boards = {};
  Map<String, dynamic> _boardSubscriptions = {};
  Map<String, Board> get boards => _boards;

  Future<void> updateBoardsOfCurrentUser() async {
    _boards = {};
    Map<String, Map> boardsOfUser =
        await getIt<FirebaseServices>().retreiveBoardsofCurrentUser();
    boardsOfUser.forEach(((key, value) {
      Board board = Board.fromMap(value);
      _boards[key] = board;
      listenToBoardUpdates(board);
    }));
  }

  listenToBoardUpdates(Board board) {
    var subscription = fbServices.database
        .ref()
        .child('boards/${board.id}')
        .onValue
        .listen((event) {
      print('board ${board.name} updated');
      print(event.snapshot.value);
      Board updatedBoard = Board.fromMap(event.snapshot.value as Map);
      _boards[board.id] = updatedBoard;
      notifyListeners();
    });
    _boardSubscriptions[board.id] = subscription;
  }

  //retreive user's boards from database
  Future<void> updateStorage() async {
    await services.updateStorage().whenComplete(() {
      notifyListeners();
    });
  }

  //create new board
  Future<void> createBoard({String name = ''}) async {
    final String uid = fbServices.currentUser!.uid;
    Board newBoard = Board(
        id: nanoid(10),
        name: name,
        createdBy: uid,
        params: <String, Parameter>{},
        permissions: {});
    await fbServices.createBoard(newBoard.toMap());
    await shareBoardByUid(newBoard, uid);
    listenToBoardUpdates(newBoard);
    //services.createBoard(name); not using yet
  }

  Future<void> shareBoardByUid(Board board, String uid,
      {String permission = 'all'}) async {
    fbServices.addUserToBoard(board.id, uid, permission: permission);
    fbServices.addBoardToUser(board.id, uid, permission: permission);
  }

  //delete board -> make the validation that a board a shared
  void removeBoard(Board board) {
    final String uid = fbServices.currentUser!.uid;
    _boards.remove(board.id);
    notifyListeners();

    //cancel subscription
    _boardSubscriptions[board.id].cancel();

    fbServices.removeUserFromBoard(board.id, uid);
    fbServices.removeBoardFromUser(board.id, uid);
  }

  Future<void> createParameter(
      Board board,
      String name,
      DurationType durationType,
      VarType varType,
      String? metric,
      CategoryOptionsList? categories,
      ButtonDecoration decoration) async {
    Parameter newParameter = Parameter(
      id: nanoid(10),
      createdTime: DateTime.now(),
      parentBoardId: board.id,
      name: name,
      durationType: durationType,
      varType: varType,
      metric: metric,
      categories: categories,
      notes: {},
      decoration: decoration,
    );
    board.params[newParameter.id] = newParameter;
    await fbServices.updateBoard(board.id, board.toMap());
  }

  void deleteParameter(Board board, Parameter parameter) {
    board.params.remove(parameter.id);
    fbServices.updateBoard(board.id, board.toMap());
  }

  void addNote(Board board, Parameter parameter, var time, var value) {
    final String newNoteId = nanoid(10);
    final DateTime nowTime = DateTime.now();
    final DurationType durationType = parameter.durationType;
    final VarType varType = parameter.varType;
    Map<String, Map<String, dynamic>> noteValue = {};
    DateTime? moment;
    DateTimeRange? duration;
    if (durationType == DurationType.duration) {
      moment = null;
      duration = time;
      noteValue = {
        'binary': {'value': true}
      };
    } else {
      switch (varType) {
        case VarType.binary:
          {
            moment = time;
            duration = null;
            noteValue = {
              'binary': {'value': true}
            };
          }
          break;
        case VarType.quantitative:
          {
            moment = time;
            duration = null;
            noteValue = {
              'quantitative': {'value': value, 'metric': parameter.metric}
            };
          }
          break;
        case VarType.categorical:
          {
            moment = time;
            duration = null;
            noteValue = {
              'categorical': {
                'id': value.id,
                'name': value.name,
              }
            };
          }
          break;
        default:
          {
            print('Invalid case');
          }
          break;
      }
    }
    Note newNote = Note(
      id: newNoteId,
      timeCreated: nowTime,
      paramId: parameter.id,
      durationType: durationType,
      moment: moment,
      duration: duration,
      varType: varType,
      value: noteValue,
    );
    board.params[parameter.id]!.notes[newNoteId] = newNote;
    fbServices.updateBoard(board.id, board.toMap());
  }

  Future<String?> uidByEmail(String email) async {
    return fbServices.uidByEmail(email);
  }

  //HERE THEY END
}
