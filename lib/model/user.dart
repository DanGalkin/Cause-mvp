class User {
  final String uid;
  String email;
  String displayName;
  Map<Object?, Object?> boards;
  List<String> boardsCreated;
  int boardLimit;

  User({
    required this.uid,
    this.email = '',
    this.displayName = '',
    this.boards = const {},
    this.boardsCreated = const [],
    this.boardLimit = 5,
  });

  User.fromMap(Map map)
      : uid = map['uid'],
        displayName = map['displayName'],
        email = map['email'],
        boards = map.containsKey('boards') ? map['boards'] : {},
        boardsCreated = map.containsKey('boardsCreated')
            ? List<String>.from(map['boardsCreated'])
            : [],
        boardLimit = map.containsKey('boardLimit') ? map['boardLimit'] : 5;

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'boards': boards,
      'boardsCreated': boardsCreated.asMap(),
      'boardLimit': boardLimit,
    };
  }
}
