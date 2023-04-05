import '../services/firebase_services.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import './user_entry_screen.dart';
import '../services/service_locator.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SignInScreen(actions: [
      AuthStateChangeAction(((context, state) async {
        if (state is SignedIn || state is UserCreated) {
          var user = (state is SignedIn)
              ? state.user
              : (state as UserCreated).credential.user;
          if (user == null) {
            return;
          }
          if (state is UserCreated) {
            final String displayName = user.email!.split('@')[0];
            user.updateDisplayName(displayName);
            getIt<FirebaseServices>().createUser(
              uid: user.uid,
              email: user.email!,
              displayName: displayName,
            );
          }
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const UserEntryScreen()));
        }
      }))
    ]);
  }
}
