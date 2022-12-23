class CategoryOption {
  final String id;
  final String name;
  // final String? parameterId;
  // final int? orderNumber;

  CategoryOption({
    required this.id,
    required this.name,
    // this.parameterId,
    // this.orderNumber,
  });

  CategoryOption.fromMap(map)
      : id = map['id'],
        name = map['name'];
  // parameterId = map['parameterId'],
  // orderNumber = map['orderNumber'];

  Map toMap() {
    return {
      'id': id,
      'name': name,
      // 'orderNumber': orderNumber,
      // 'parameterId': parameterId,
    };
  }
}

class CategoryOptionsList {
  final List<CategoryOption> list;
  CategoryOptionsList({
    required this.list,
  });

  void addOption(CategoryOption option) {
    list.add(option);
  }

  void removeOption(CategoryOption option) {
    list.remove(option);
  }

  CategoryOptionsList.fromMap(map)
      : list = List<CategoryOption>.from(
            map.map((optionMap) => CategoryOption.fromMap(optionMap)));

  Map toMap() {
    return list.asMap().map(
        (index, categoryOption) => MapEntry(index, categoryOption.toMap()));
  }
}
