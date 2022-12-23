import 'package:flutter/material.dart';

Future<bool?> validateUserAction(
    {required BuildContext context, String validationText = ''}) async {
  bool? respond = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
              title: const Text('Just a check'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    Text(validationText),
                    const Text('Are you sure to continue?')
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('YES')),
                TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('NO')),
              ]),
      barrierDismissible: true);

  return respond ?? false;
}
