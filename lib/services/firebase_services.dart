import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cause_flutter_mvp/firebase_options.dart';
import 'package:flutter/cupertino.dart';

class FirebaseServices extends ChangeNotifier {
  FirebaseServices() {
    init();
  }

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;
  User? get currentUser => FirebaseAuth.instance.currentUser;

  final initializedNotifier = ValueNotifier<bool>(false);
  final loggedInNotifier = ValueNotifier<bool>(false);

  late FirebaseDatabase database;

  Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    initializedNotifier.value = true;

    database = FirebaseDatabase.instance;

    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
    ]);

    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loggedIn = true;
        loggedInNotifier.value = true;
      } else {
        _loggedIn = false;
        loggedInNotifier.value = false;
      }
      notifyListeners();
    });
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> createUser(
      {required String uid,
      required String email,
      required String displayName}) async {
    print('creating new user: $email');
    DatabaseReference userRef = database.ref('users/$uid');
    userRef.set(
        {'uid': uid, 'email': email, 'displayName': displayName, 'boards': {}});
  }

  Future<void> createBoard(boardMap) async {
    print('saving board: ${boardMap['id']}');
    DatabaseReference boardRef = database.ref('boards/${boardMap['id']}');
    print(boardMap);
    await boardRef.set(boardMap);
    if (boardMap['createdBy'] != null) {
      addBoardToUser(
          boardMap['id'],
          boardMap[
              'createdBy']); //this is definetely the logic for firebasedatabase
    }
  }

  //the logic is wrong
  Future<void> updateBoard(String id, Map<String, dynamic> map) async {
    print('updating board: $id');
    print(map);
    DatabaseReference boardRef = database.ref('boards/$id');
    boardRef.update(map);
  }

  Future<void> addBoardToUser(String boardId, String uid,
      {String permission = 'all'}) async {
    DatabaseReference userBoardsRef = database.ref('users/$uid/boards');
    userBoardsRef.update({boardId: 'all'});
  }

  Future<void> addUserToBoard(String boardId, String uid,
      {String permission = 'all'}) async {
    DatabaseReference boardPermissionsRef =
        database.ref('boards/$boardId/permissions');
    boardPermissionsRef.update({uid: permission});
  }

  Future<void> removeUserFromBoard(String boardId, String uid) async {
    DatabaseReference userRefToRemove =
        database.ref('boards/$boardId/permissions/$uid');
    userRefToRemove.remove();
  }

  Future<void> removeBoardFromUser(String boardId, String uid) async {
    DatabaseReference boardRefToRemove =
        database.ref('users/$uid/boards/$boardId');
    boardRefToRemove.remove();
  }

  Future<Map<String, Map>> retreiveBoardsofCurrentUser() async {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    Map<String, Map> boards = <String, Map>{};

    if (uid == null) {
      return {};
    }

    final userBoardsSnapshot = await database.ref().child('users/$uid').get();
    if (!userBoardsSnapshot.exists) {
      print('no user Snapshot in Firebase');
      return {};
    }

    final Map userBoards = userBoardsSnapshot.value as Map;
    if (!userBoards.containsKey('boards')) {
      print('no boards for user in Firebase DB');
      return {};
    }

    for (String boardId in userBoards['boards'].keys) {
      final boardSnapshot = await database.ref().child('boards/$boardId').get();
      if (!boardSnapshot.exists) {
        continue;
      }
      final Map board = boardSnapshot.value as Map;
      boards[boardId] = board;
    }
    return boards;
  }

  Future<String?> uidByEmail(String email) async {
    DatabaseReference usersRef = database.ref().child('users');
    Map users = {};
    await usersRef.get().then(
      (snapshot) {
        users = snapshot.value as Map;
      },
    );
    print('Users : $users');
    print('searching for $email');
    String? uid = users.keys
        .firstWhere((key) => users[key]['email'] == email, orElse: () => null);
    print('result: $uid');
    return uid;
  }
}
