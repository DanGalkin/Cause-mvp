import './parameter.dart';

class Board {
  final String id;
  String name;
  String createdBy;
  String? description;
  Map<String, Parameter> params;
  Map<String, String> permissions;
  String? templateId;
  DateTime? templateUpdatedTime;

  Board(
      {required this.id,
      this.name = '',
      this.description,
      required this.createdBy,
      this.params = const <String, Parameter>{},
      required this.permissions,
      this.templateId,
      this.templateUpdatedTime});

  bool get hasDescription => description != null;

  Board.fromMap(Map map)
      : id = map['id'],
        name = map['name'] ?? '',
        description = map['description'],
        createdBy = map['createdBy'],
        params = map.containsKey('params')
            ? Map<String, Parameter>.from(map['params']
                .map((id, map) => MapEntry(id, Parameter.fromMap(map))))
            : <String, Parameter>{},
        permissions = Map<String, String>.from(map['permissions']),
        templateId = map['templateId'],
        templateUpdatedTime = map['templateUpdatedTime'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['templateUpdatedTime'])
            : null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdBy': createdBy,
      'params': params.map(
        (id, parameter) => MapEntry(id, parameter.toMap()),
      ),
      'permissions': permissions,
      'templateId': templateId,
      'templateUpdatedTime': templateUpdatedTime?.millisecondsSinceEpoch,
    };
  }

  //If I ever try model system here again ->
  // Board.fromModel(Model model)
  //     : id = model.id,
  //       name = model.data['name'] ?? '',
  //       params = model.data['params'] != null
  //           ? Map<String, Parameter>.from(
  //               model.data['params'].map((id, paramMap) {
  //               return MapEntry(
  //                   id, Parameter.fromMap(paramMap));
  //             }))
  //           : <String, Parameter>{};

  // Model toModel() => Model(id: id, data: {
  //       'name': name,
  //       'params':
  //           params.map(((id, param) => MapEntry(id, param.toModel().toMap()))),
  //     });
}
