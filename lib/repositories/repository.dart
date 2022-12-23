abstract class Repository {
  Map create();
  Map? get(String id);
  List<Map> getAll();

  void update(Model item);
  void delete(Model item);
  updateStorage();
}

class Model {
  final String id;
  final Map data;

  const Model({
    required this.id,
    this.data = const {},
  });

  Model.fromMap(Map<String, dynamic> map)
      : id = map.keys.first,
        data = Map.from(map.values.first);

  Map toMap() => {id: data};
}
