import 'package:flutter/material.dart';

class ButtonDecoration {
  Color color;
  String icon;

  ButtonDecoration({required this.color, this.icon = ''});

  ButtonDecoration.fromMap(Map map)
      : color = Color(map['color']),
        icon = map['icon'];

  Map<String, dynamic> toMap() {
    return {
      'color': color.value,
      'icon': icon,
    };
  }
}
