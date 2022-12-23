import '../repositories/in_memory_cache.dart';
import '../model/board.dart';
import '../model/parameter.dart';
import '../model/note.dart';

import 'package:nanoid/nanoid.dart';
import 'package:flutter/material.dart';

class BoardServices {
  final _repository = InMemoryCache();

  List<Board> getBoards() {
    return _repository.getAll().map((map) => Board.fromMap(map)).toList();
  }

  Future<void> updateStorage() async {
    await _repository.updateStorage();
  }

  Future<void> createBoard(String name) async {}

  saveBoard(Board board) {
    _repository.update(board.toMap());
  }

  deleteBoard(Board board) {
    _repository.delete(board.toMap());
  }

  // createParameter(
  //     Board board, String name, DurationType durationType, VarType varType,
  //     {String? metric, Map<String, String>? categories}) {
  //   String newParamId = nanoid(10);
  //   DateTime nowTime = DateTime.now();

  //   Parameter newParam = Parameter(
  //     id: newParamId,
  //     createdTime: nowTime,
  //     parentBoardId: board.id,
  //     name: name,
  //     durationType: durationType,
  //     varType: varType,
  //     metric: metric,
  //     categories: categories,
  //     notes: {},
  //   );

  //   board.params[newParamId] = newParam;
  //   saveBoard(board);
  // }

  deleteParameter(Board board, Parameter parameter) {
    board.params.remove(parameter.id);
    saveBoard(board);
  }

  addNote({
    required Board board,
    required Parameter parameter,
    required DateTime? moment,
    required DateTimeRange? duration,
    required Map<String, Map<String, dynamic>> value,
  }) {
    String newNoteId = nanoid(10);
    DateTime nowTime = DateTime.now();
    DurationType durationType = parameter.durationType;
    VarType varType = parameter.varType;

    Note newNote = Note(
      id: newNoteId,
      timeCreated: nowTime,
      paramId: parameter.id,
      durationType: durationType,
      moment: moment,
      duration: duration,
      varType: varType,
      value: value,
    );

    //this seems like a separate UPDATE PARAMETER function in the future
    print('Adding a new note to param: ${parameter.toMap()}');
    board.params[parameter.id]!.notes[newNoteId] = newNote;

    saveBoard(board);
  }
}
