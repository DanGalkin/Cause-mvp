import './parameter.dart';

class Board {
  final String id;
  String name;
  String createdBy;
  Map<String, Parameter> params;
  Map<String, String> permissions;

  Board(
      {required this.id,
      this.name = '',
      required this.createdBy,
      this.params = const <String, Parameter>{},
      required this.permissions});

  Board.fromMap(Map map)
      : id = map['id'],
        name = map['name'] ?? '',
        createdBy = map['createdBy'],
        params = map.containsKey('params')
            ? Map<String, Parameter>.from(map['params']
                .map((id, map) => MapEntry(id, Parameter.fromMap(map))))
            : <String, Parameter>{},
        permissions = Map<String, String>.from(map['permissions']);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdBy': createdBy,
      'params': params.map(
        (id, parameter) => MapEntry(id, parameter.toMap()),
      ),
      'permissions': permissions,
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
