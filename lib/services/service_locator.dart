import '../controllers/board_controller.dart';

import '../services/firebase_services.dart';
import '../services/board_services.dart';

import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupGetIt() {
  getIt.registerSingleton<FirebaseServices>(FirebaseServices());

  getIt.registerSingleton<BoardServices>(BoardServices());

  getIt.registerSingleton<BoardController>(BoardController());
}
