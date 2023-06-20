import 'dart:io';

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cause_flutter_mvp/firebase_options.dart';
import 'package:firebase_ui_oauth_apple/firebase_ui_oauth_apple.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
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

    String clientId = Platform.isAndroid
        ? '925271095354-adsqb6ssnf1i0hi3b932thmbofj6209q.apps.googleusercontent.com'
        : '925271095354-rs29eei351m6tb1itsc22uesr0pag5pv.apps.googleusercontent.com';

    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
      GoogleProvider(clientId: clientId),
      if (Platform.isIOS) AppleProvider()
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

  Future<Map?> getCurrentUserMap() async {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return null;
    }

    return await getUserMapByUid(uid);
  }

  Future<void> updateUser(Map<String, dynamic> userMap) async {
    DatabaseReference userRef =
        database.ref().child('users').child(userMap['uid']);
    userRef.update(userMap);
  }

  Future<Map?> getUserMapByUid(String uid) async {
    DatabaseReference userRef = database.ref().child('users').child(uid);
    DataSnapshot userSnapshot = await userRef.get();
    if (userSnapshot.exists) {
      return userSnapshot.value as Map;
    } else {
      return null;
    }
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
    notifyListeners();
  }

  Future<void> addUserToBoard(String boardId, String uid,
      {String permission = 'all'}) async {
    DatabaseReference boardPermissionsRef =
        database.ref('boards/$boardId/permissions');
    boardPermissionsRef.update({uid: permission});
    notifyListeners();
  }

  Future<void> removeUserFromBoard(String boardId, String uid) async {
    DatabaseReference userRefToRemove =
        database.ref('boards/$boardId/permissions/$uid');
    userRefToRemove.remove();
    notifyListeners();
  }

  Future<void> removeBoardFromUser(String boardId, String uid) async {
    DatabaseReference boardRefToRemove =
        database.ref('users/$uid/boards/$boardId');
    boardRefToRemove.remove();
    notifyListeners();
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

  Future<String?> emailByUid(String uid) async {
    Map? user = await getUserMapByUid(uid);
    if (user == null) {
      return null;
    }

    if (user.containsKey('email')) {
      return user['email'];
    } else {
      return null;
    }
  }

  Future<void> createTemplate(templateMap) async {
    print('creating Template: ${templateMap['name']}');
    DatabaseReference templateRef =
        database.ref('templates/${templateMap['id']}');
    await templateRef.set(templateMap);
  }

  Future<void> updateTemplate(Map<String, dynamic> templateMap) async {
    String id = templateMap['id'];
    print('updating template: $id');
    print(templateMap);
    DatabaseReference templateRef = database.ref('templates/$id');
    templateRef.update(templateMap);
  }

  Future<Map> getTempateMapById(String id) async {
    DatabaseReference templateRef = database.ref('templates/$id');
    Map template = {};

    await templateRef.get().then(
      (snapshot) {
        if (!snapshot.exists) {
          return {};
        }
        template = snapshot.value as Map;
      },
    );
    return template;
  }
}
