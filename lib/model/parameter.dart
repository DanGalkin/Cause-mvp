import './note.dart';
import './button_decoration.dart';
import './category_option.dart';

class Parameter {
  final String id;
  final DateTime createdTime;
  String parentBoardId;
  String name;
  VarType varType;
  DurationType durationType;
  String? metric;
  CategoryOptionsList?
      categories; //for ordinal VarType the order in a list matters
  Map<String, Note> notes;
  ButtonDecoration decoration;
  RecordState recordState;
  String description;

  Parameter({
    required this.id,
    required this.createdTime,
    required this.parentBoardId,
    this.name = '',
    this.varType = VarType.binary,
    this.durationType = DurationType.moment,
    this.metric,
    this.categories,
    required this.notes,
    required this.decoration,
    this.recordState = const RecordState(),
    this.description = '',
  });

  List<Note> get notesOrderedByTime {
    List<Note> noteList = notes.values.toList();

    if (durationType == DurationType.moment) {
      noteList.sort((a, b) => b.moment!.compareTo(a.moment!));
    }

    if (durationType == DurationType.duration) {
      noteList.sort((a, b) => b.duration!.end.compareTo(a.duration!.end));
    }

    return noteList;
  }

  Note? get lastNote {
    List<Note> orderedNoteList = notesOrderedByTime;
    return orderedNoteList.isNotEmpty ? orderedNoteList.first : null;
  }

  // Parameter.fromModel(Model model)
  //     : id = model.id,
  //       createdTime =
  //           DateTime.fromMillisecondsSinceEpoch(model.data['createdTime']),
  //       name = model.data['name'],
  //       varType = VarType.values.byName(model.data['varType']),
  //       durationType = DurationType.values.byName(model.data['durationType']),
  //       metric = model.data['metric'],
  //       categories = model.data['categories'];

  // Model toModel() => Model(id: id, data: {
  //       'createdTime': createdTime.millisecondsSinceEpoch,
  //       'name': name,
  //       'varType': varType.name,
  //       'durationType': durationType.name,
  //       'metric': metric,
  //       'categories': categories,
  //     });

  Parameter.fromMap(map)
      : id = map['id'],
        createdTime = DateTime.fromMillisecondsSinceEpoch(map['createdTime']),
        parentBoardId = map['parentBoardId'],
        name = map['name'],
        varType = VarType.values.byName(map['varType']),
        durationType = DurationType.values.byName(map['durationType']),
        metric = map['metric'],
        categories = map.containsKey('categories')
            ? CategoryOptionsList.fromMap(map['categories'])
            : null,
        notes = map.containsKey('notes')
            ? Map<String, Note>.from(map['notes']
                .map((id, noteMap) => MapEntry(id, Note.fromMap(noteMap))))
            : <String, Note>{},
        decoration = ButtonDecoration.fromMap(map['decoration']),
        recordState = map.containsKey('recordState')
            ? RecordState.fromMap(map['recordState'])
            : const RecordState(),
        description = map.containsKey('description') ? map['description'] : '';

  Map toMap() {
    return {
      'id': id,
      'createdTime': createdTime.millisecondsSinceEpoch,
      'parentBoardId': parentBoardId,
      'name': name,
      'varType': varType.name,
      'durationType': durationType.name,
      'metric': metric,
      'categories': categories?.toMap(),
      'notes': notes.map((id, note) => MapEntry(id, note.toMap())),
      'decoration': decoration.toMap(),
      'recordState': recordState.toMap(),
      'description': description,
    };
  }
}

class RecordState {
  final bool recording;
  final DateTime? startedAt;
  final String? startedByUserId;

  const RecordState(
      {this.recording = false, this.startedAt, this.startedByUserId});

  RecordState.fromMap(Map map)
      : recording = map['recording'] == 'true',
        startedAt = map['startedAt'] == 'null'
            ? null
            : DateTime.fromMillisecondsSinceEpoch(map['startedAt']),
        startedByUserId =
            map['startedByUserId'] == 'null' ? null : map['startedByUserId'];

  Map toMap() {
    return {
      'recording': recording.toString(),
      'startedAt': startedAt?.millisecondsSinceEpoch ?? 'null',
      'startedByUserId': startedByUserId.toString(),
    };
  }
}

enum VarType {
  binary,
  ordinal,
  categorical,
  quantitative,
  unstructured,
}

enum DurationType {
  moment,
  duration,
}
