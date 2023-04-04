import './parameter.dart';

class Template {
  final String id;
  String name; // it is the name of the board the template is created from
  String createdBy; // uid of the user who shared a template
  String? description;
  final String fromBoardId; // id of the board the template created from
  DateTime updatedTime; //when the template was last updated
  Map<String, Parameter> params;
  int copyCount; // how many times this template was used to create a board

  Template(
      {required this.id,
      this.name = '',
      required this.createdBy,
      this.description,
      required this.fromBoardId,
      required this.updatedTime,
      this.params = const <String, Parameter>{},
      this.copyCount = 0});

  Template.fromMap(Map map)
      : id = map['id'],
        name = map['name'] ?? '',
        createdBy = map['createdBy'],
        description = map['description'],
        fromBoardId = map['fromBoardId'],
        updatedTime = DateTime.fromMillisecondsSinceEpoch(map['updatedTime']),
        params = map.containsKey('params')
            ? Map<String, Parameter>.from(map['params']
                .map((id, map) => MapEntry(id, Parameter.fromMap(map))))
            : <String, Parameter>{},
        copyCount = map['copyCount'];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdBy': createdBy,
      'description': description,
      'fromBoardId': fromBoardId,
      'updatedTime': updatedTime.millisecondsSinceEpoch,
      'params': params.map(
        (id, parameter) => MapEntry(id, parameter.toMap()),
      ),
      'copyCount': copyCount,
    };
  }
}
