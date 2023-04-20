import 'package:flutter/material.dart';

import '../controllers/board_controller.dart';
import '../services/firebase_services.dart';
import '../services/service_locator.dart';
import 'login_screen.dart';
import 'main_drawer.dart';
import 'view_utilities/action_validation_utilities.dart';

import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String? email = getIt<FirebaseServices>().currentUser?.email;
    String? uid = getIt<FirebaseServices>().currentUser?.uid;
    return Scaffold(
        appBar: AppBar(
            title:
                Expanded(child: FittedBox(child: Text(email ?? 'Settings')))),
        drawer: const MainDrawer(),
        body: ListView(children: [
          ListTile(
            title: const Text('Logout'),
            trailing: const Icon(Icons.logout),
            onTap: () {
              validateUserAction(
                      context: context,
                      validationText: 'You will be logged out.')
                  .then((result) {
                if (result == true) {
                  getIt<FirebaseServices>().signOut().then((_) =>
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                          (route) => false));
                }
              });
            },
          ),
          const Divider(),
          ListTile(
              title: const Text('Delete account'),
              trailing: const Icon(Icons.delete),
              onTap: () {
                validateUserAction(
                        context: context,
                        validationText:
                            'This action will delete your account and data entangled with it.')
                    .then((result) {
                  if (result == true) {
                    getIt<BoardController>().deleteCurrentUser().then((_) =>
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()),
                            (route) => false));
                  }
                });
              }),
          const Divider(),
          ListTile(
              title: const Text('Privacy policy'),
              trailing: const Icon(Icons.privacy_tip),
              onTap: () async {
                final Uri url = Uri.parse('https://wata.fun/#/cause-privacy');
                if (!await launchUrl(url,
                    mode: LaunchMode.externalApplication)) {
                  throw Exception('Could not launch $url');
                }
              }),
          const Divider(),
        ]));
  }
}
