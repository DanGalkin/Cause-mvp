import 'package:cause_flutter_mvp/view/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './view/user_entry_screen.dart';

import './controllers/board_controller.dart';
import './services/firebase_services.dart';
import './services/service_locator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  setupGetIt();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => getIt<BoardController>()),
      ChangeNotifierProvider(create: (context) => getIt<FirebaseServices>())
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final firebaseState = getIt<FirebaseServices>();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
        valueListenable: firebaseState.initializedNotifier,
        builder: (context, firebaseInitialized, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Cause',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: !firebaseInitialized
                ? const Center(child: CircularProgressIndicator())
                : ValueListenableBuilder<bool>(
                    valueListenable: firebaseState.loggedInNotifier,
                    builder: (context, loggedIn, child) {
                      return loggedIn
                          ? const UserEntryScreen()
                          : const LoginScreen();
                    }),
          );
        });
  }
}
