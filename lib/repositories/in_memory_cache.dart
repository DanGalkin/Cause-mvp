import 'dart:convert';

import 'package:get_it/get_it.dart';
import '../services/firebase_services.dart';

import './local_storage.dart';
import 'package:nanoid/nanoid.dart';

class InMemoryCache {
  final _storage = <String, Map>{};
  final _localStorage = LocalStorage();

  Future<void> createBoard(String name) async {
    final id = nanoid(10);
    final uid = GetIt.I<FirebaseServices>().currentUser?.uid;
    final map = {
      'id': id,
      'name': name,
      'createdBy': uid,
      'permissions': {uid: 'all'},
    };
    _storage[id] = map;
    //GetIt.I<FirebaseServices>().createBoard(id, map);
  }

  void delete(Map item) {
    _storage.remove(item['id']);
    _saveToLocal();
  }

  //when user logs out
  void clearAll() {
    _storage.clear();
  }

  Map? get(String id) {
    return _storage[id];
  }

  void update(Map<String, dynamic> item) {
    _storage[item['id']] = item;
    _saveToLocal();
    //GetIt.I<FirebaseServices>().createBoard(item['id'], item);
  }

  List<Map> getAll() {
    return _storage.values.toList(growable: false);
  }

  //TODO: convert _storage to jsonString and save it in local storage
  void _saveToLocal() async {
    String json = jsonEncode(_storage);
    await _localStorage.writeJson(json);
  }

  //TODO: get json from a local Storage and convert it to _storage
  Future<Map<String, Map>> _getFromLocal() async {
    String json = await _localStorage.readFile();
    print('reading local: $json');
    Map<String, Map> storage = Map<String, Map>.from(jsonDecode(json));
    return storage;
  }

  // This is updating from localfile
  // Future<void> updateStorage() async {
  //   Map<String, Map> retrievedStorage = await _getFromLocal();
  //   _storage.addAll(retrievedStorage);
  // }

  //updateStorage from Firebase
  Future<void> updateStorage() async {
    //get boards of user
    Map<String, Map> boardsOfUser =
        await GetIt.I<FirebaseServices>().retreiveBoardsofCurrentUser();
    //add this boards to _storage
    _storage.addAll(boardsOfUser);
  }
}
