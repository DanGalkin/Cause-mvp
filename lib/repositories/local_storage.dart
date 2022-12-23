import 'dart:io';

import 'package:path_provider/path_provider.dart';

class LocalStorage {
  //save json string to file

  //locate documents folder
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  //get a File to cause_storage.json in doc folder
  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/cause_storage.json');
  }

  Future<File> writeJson(String json) async {
    final file = await _localFile;
    return file.writeAsString(json);
  }

  //retrieve json string from cause_storage
  Future<String> readFile() async {
    try {
      final file = await _localFile;
      bool fileExists = await file.exists();
      if (fileExists) {
        return file.readAsString();
      } else {
        return '{}';
      }
    } catch (e) {
      return '{}';
    }
  }
}
