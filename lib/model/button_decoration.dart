import 'package:flutter/material.dart';

class ButtonDecoration {
  Color color;
  String icon;
  bool showLastNote;

  ButtonDecoration(
      {required this.color, this.icon = '', this.showLastNote = false});

  ButtonDecoration.fromMap(Map map)
      : color = Color(map['color']),
        icon = map['icon'],
        showLastNote = map.containsKey('showLastNote')
            ? map['showLastNote'] == 'true'
            : false;

  Map<String, dynamic> toMap() {
    return {
      'color': color.value,
      'icon': icon,
      'showLastNote': showLastNote.toString(),
    };
  }
}
