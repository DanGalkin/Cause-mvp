import './parameter.dart';
import 'package:flutter/material.dart';

class Note {
  //Note own id
  final String id;
  //time of creation
  final DateTime timeCreated;
  //Parent parameter id
  final String paramId;

  //time - durationType
  DurationType durationType;
  //moment (datetime) or duration (datetime range)
  DateTime? moment;
  DateTimeRange? duration;

  //value - varType and subtree of values
  VarType varType;
  Map<String, dynamic> value;
  //keys are: binary, categorical, quantitative
  //Categorical value is a map id -> category name
  //Quantitative value is a map: quantity -> input value
  //   metric -> metric value

  Note({
    required this.id,
    required this.timeCreated,
    required this.paramId,
    required this.durationType,
    required this.moment,
    required this.duration,
    required this.varType,
    required this.value,
  });

  Note.fromMap(map)
      : id = map['id'],
        timeCreated = DateTime.fromMillisecondsSinceEpoch(map['timeCreated']),
        paramId = map['paramId'],
        durationType = DurationType.values.byName(map['durationType']),
        moment = map['moment'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['moment'])
            : null,
        duration = map['duration'] != null
            ? DateTimeRange(
                start: DateTime.fromMillisecondsSinceEpoch(
                    map['duration']['start']),
                end:
                    DateTime.fromMillisecondsSinceEpoch(map['duration']['end']),
              )
            : null,
        varType = VarType.values.byName(map['varType']),
        value = Map<String, dynamic>.from(map['value']);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timeCreated': timeCreated.millisecondsSinceEpoch,
      'paramId': paramId,
      'durationType': durationType.name,
      'moment': moment?.millisecondsSinceEpoch,
      'duration': duration != null
          ? {
              'start': duration!.start.millisecondsSinceEpoch,
              'end': duration!.end.millisecondsSinceEpoch
            }
          : null,
      'varType': varType.name,
      'value': value,
    };
  }

  // Note.duration({
  //   required this.id,
  //   required this.timeCreated,
  //   required this.paramId,
  //   required this.duration,
  // })  : durationType = DurationType.duration,
  //       varType = VarType.binary,
  //       moment = null,
  //       value = {
  //         'binary': {'value': true}
  //       };
}
