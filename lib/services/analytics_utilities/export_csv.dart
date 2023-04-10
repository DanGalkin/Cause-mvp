import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';

import '../../model/board.dart';
import '../../model/parameter.dart';
import '../../model/note.dart';

void exportCSVData(Board board) async {
  File file = await ExportCSV(board: board).writeCSV();
  await Share.shareFiles([file.path], text: 'Export Data');
  await file.delete();
}

class ExportCSV {
  ExportCSV({
    required this.board,
  });

  final Board board;

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File(
        '$path/${board.name} export ${DateTime.now().millisecondsSinceEpoch}.csv');
  }

  //requir4ed context - should provide in the first place?
  String get _csv {
    List<List<dynamic>> listOfLists = [
      [
        'Parameter',
        'Moment (formatted)',
        'Start time (formatted)',
        'End time (formatted)',
        'Value',
      ]
    ];
    for (Parameter parameter in board.params.values) {
      List<List<dynamic>> buttonListOfList = parameter.notes.values
          .map((Note note) => [
                parameter.name,
                note.moment != null
                    ? DateFormat.yMMMd().add_Hm().format(note.moment!)
                    : '',
                note.duration?.start != null
                    ? DateFormat.yMMMd().add_Hm().format(note.duration!.start)
                    : '',
                note.duration?.start != null
                    ? DateFormat.yMMMd().add_Hm().format(note.duration!.end)
                    : '',
                parameter.varType != VarType.categorical
                    ? note.value[parameter.varType.name]['value'].toString()
                    : note.value[parameter.varType.name]['name'],
              ])
          .toList();
      listOfLists = [...listOfLists, ...buttonListOfList];
    }
    return const ListToCsvConverter().convert(listOfLists);
  }

  Future<File> writeCSV() async {
    final file = await _localFile;
    return file.writeAsString(_csv);
  }
}
