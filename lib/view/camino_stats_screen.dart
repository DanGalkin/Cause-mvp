import 'package:cause_flutter_mvp/view/view_utilities/ui_widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

import '../controllers/board_controller.dart';
import '../model/board.dart';
import '../model/note.dart';
import '../model/parameter.dart';
import '../services/analytics_utilities/common_analytics_utilities.dart';
import 'view_utilities/text_utilities.dart';

class CaminoStatsScreen extends StatelessWidget {
  const CaminoStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camino Statistics')),
      body: const DailyCaminoStatsList(),
    );
  }
}

class DailyCaminoStatsList extends StatelessWidget {
  const DailyCaminoStatsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BoardController>(builder: (context, boards, child) {
      //check if there is a walk
      Board? walkBoard = findBoardByName(boards.boards, 'El Camino: Walk');
      print('walkBoard: ${walkBoard?.name}');
      Board? stopBoard = findBoardByName(boards.boards, 'El Camino: Stop');
      print('stopBoard: ${stopBoard?.name}');
      Board? equipBoard =
          findBoardByName(boards.boards, 'El Camino: Equipment');
      print('equipBoard: ${equipBoard?.name}');

      if (stopBoard == null) {
        return const Center(
            child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
              'Unfortunately, you dont have the board to analyze: "El Camino: Stop"'),
        ));
      }

      // understand what days there was a walk
      // find the Walk parameter
      Parameter? walkParam =
          findParameterByName(board: stopBoard, name: 'The Walk');

      if (walkParam == null) {
        return const Center(
            child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
              'Unfortunately, there is no "Walk" parameter in "El Camino: Stop". We cannot analize the days of your camino.'),
        ));
      }

      //check if there is any walk note
      if (!walkParam.hasEvents) {
        return const Center(
            child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('It seems. that you have not started your Camino yet.'),
        ));
      }

      //get Walk Notes
      List<Note> walkNotes = walkParam.notesOrderedByTime;
      //The total Map date -> gathered parameter
      Map<DateTime, List<Note>> walkStats = {};
      for (Note note in walkNotes) {
        DateTime dayOfNote = startOfDay(momentOfNote(note));
        if (walkStats.containsKey(dayOfNote)) {
          walkStats[dayOfNote]!.add(note);
        } else {
          walkStats[dayOfNote] = [note];
        }
      }

      //create an ordered list from a set of unique dates of Walk
      List<DateTime> orderedWalkDays = walkStats.keys.toList();
      orderedWalkDays.sort((a, b) {
        return a.compareTo(b);
      });

      //get Distance Notes
      Map<DateTime, List<Note>> distanceStats = {};
      if (walkBoard != null) {
        Parameter? distanceParam =
            findParameterByName(board: walkBoard, name: 'Distance');
        if (distanceParam != null) {
          List<Note>? distanceNotes = distanceParam.notesOrderedByTime;
          for (Note note in distanceNotes) {
            DateTime dayOfNote = startOfDay(momentOfNote(note));
            if (distanceStats.containsKey(dayOfNote)) {
              distanceStats[dayOfNote]!.add(note);
            } else {
              distanceStats[dayOfNote] = [note];
            }
          }
        }
      }

      //get Spend Notes
      Map<DateTime, List<Note>> spendStats = {};
      if (equipBoard != null) {
        Parameter? spendParam =
            findParameterByName(board: equipBoard, name: 'Money');
        print(spendParam);
        if (spendParam != null) {
          List<Note>? spendNotes = spendParam.notesOrderedByTime;
          for (Note note in spendNotes) {
            DateTime dayOfNote = startOfDay(momentOfNote(note));
            if (spendStats.containsKey(dayOfNote)) {
              spendStats[dayOfNote]!.add(note);
            } else {
              spendStats[dayOfNote] = [note];
            }
          }
        }
      }

      //get Emotion Notes
      Map<DateTime, List<Note>> emotionStats = {};
      Parameter? emotionParam =
          findParameterByName(board: stopBoard, name: 'Emotion');
      if (emotionParam != null) {
        List<Note>? emotionNotes = emotionParam.notesOrderedByTime;
        for (Note note in emotionNotes) {
          DateTime dayOfNote = startOfDay(momentOfNote(note));
          if (emotionStats.containsKey(dayOfNote)) {
            emotionStats[dayOfNote]!.add(note);
          } else {
            emotionStats[dayOfNote] = [note];
          }
        }
      }

      //get Physical Notes
      Map<DateTime, List<Note>> physicalStats = {};
      Parameter? physicalParam =
          findParameterByName(board: stopBoard, name: 'Physical Condition');
      if (physicalParam != null) {
        List<Note>? physicalNotes = physicalParam.notesOrderedByTime;
        for (Note note in physicalNotes) {
          DateTime dayOfNote = startOfDay(momentOfNote(note));
          if (physicalStats.containsKey(dayOfNote)) {
            physicalStats[dayOfNote]!.add(note);
          } else {
            physicalStats[dayOfNote] = [note];
          }
        }
      }

      //get Sleep Notes
      Map<DateTime, List<Note>> sleepStats = {};
      Parameter? sleepParam =
          findParameterByName(board: stopBoard, name: 'Sleep');
      if (sleepParam != null) {
        List<Note>? sleepNotes = sleepParam.notesOrderedByTime;
        for (Note note in sleepNotes) {
          DateTime dayOfNote = startOfDay(momentOfNote(note));
          if (sleepStats.containsKey(dayOfNote)) {
            sleepStats[dayOfNote]!.add(note);
          } else {
            sleepStats[dayOfNote] = [note];
          }
        }
      }

      return Scrollbar(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: ListView.separated(
            itemCount: orderedWalkDays.length,
            itemBuilder: ((context, index) {
              int realIndex = orderedWalkDays.length - index - 1;
              DateTime day = orderedWalkDays[realIndex];
              //calculate total duration of walks
              //Duration walkTime
              Duration dailyTotalWalk = const Duration();
              List<Note>? dailyWalkNotes = walkStats[day];
              if (dailyWalkNotes != null) {
                for (Note note in dailyWalkNotes) {
                  dailyTotalWalk = dailyTotalWalk + note.duration!.duration;
                }
              }

              //calculate total distance
              double totalDistance = 0;
              List<Note>? dailyDistanceNotes = distanceStats[day];
              if (dailyDistanceNotes != null) {
                for (Note distanceNote in dailyDistanceNotes) {
                  totalDistance += distanceNote.value['quantitative']['value'];
                }
              }

              //calculate total money spent
              double totalSpent = 0;
              List<Note>? dailySpendNotes = spendStats[day];
              if (dailySpendNotes != null) {
                for (Note spendNote in dailySpendNotes) {
                  totalSpent += spendNote.value['quantitative']['value'];
                }
              }

              //get daily emotions values
              List<String> dailyEmotions = [];
              List<Note>? dailyEmotionNotes = emotionStats[day];
              if (dailyEmotionNotes != null) {
                for (Note emotionNote in dailyEmotionNotes) {
                  dailyEmotions.add(emotionNote.value['categorical']['name']);
                }
              }

              //get daily physical values
              List<String> dailyPhysical = [];
              List<Note>? dailyPhysicalNotes = physicalStats[day];
              if (dailyPhysicalNotes != null) {
                for (Note physicalNote in dailyPhysicalNotes) {
                  dailyPhysical.add(physicalNote.value['categorical']['name']);
                }
              }

              //get daily physical values
              List<Note>? dailySleepNotes = sleepStats[day];
              Duration? dailySleepDuration;
              String? dailySleepQuality;
              if (dailySleepNotes != null) {
                Note firstSleepNote = dailySleepNotes.last;
                dailySleepDuration = firstSleepNote.duration!.duration;
                dailySleepQuality = firstSleepNote.value['ordinal']['name'];
              }

              return CaminoDayStatsTemplate(
                dayIndex: realIndex + 1,
                date: orderedWalkDays[realIndex],
                totalWalk: dailyTotalWalk,
                totalDistance: totalDistance,
                totalSpent: totalSpent,
                dailyEmotions: dailyEmotions,
                dailyPhysical: dailyPhysical,
                dailySleepDuration: dailySleepDuration,
                dailySleepQuality: dailySleepQuality,
              );
            }),
            separatorBuilder: (context, index) => const SizedBox(height: 15),
          ),
        ),
      );
    });
  }
}

Board? findBoardByName(Map<String, Board> boards, String name) {
  return boards.values.firstWhereOrNull((board) => board.name == name);
}

Parameter? findParameterByName({required Board board, required String name}) {
  return board.params.values.firstWhereOrNull((param) => param.name == name);
}

//gets the note moment. If the note is durational, it gets the end time
DateTime momentOfNote(Note note) {
  if (note.durationType == DurationType.moment) {
    return note.moment!;
  } else {
    return note.duration!.end;
  }
}

class CaminoDayStatsTemplate extends StatelessWidget {
  const CaminoDayStatsTemplate(
      {required this.dayIndex,
      required this.date,
      required this.totalWalk,
      required this.totalDistance,
      required this.totalSpent,
      required this.dailyEmotions,
      required this.dailyPhysical,
      this.dailySleepDuration,
      this.dailySleepQuality,
      super.key});

  final int dayIndex;
  final DateTime date;
  final Duration totalWalk;
  final double totalDistance;
  final double totalSpent;
  final List<String> dailyEmotions;
  final List<String> dailyPhysical;
  final Duration? dailySleepDuration;
  final String? dailySleepQuality;

  @override
  Widget build(BuildContext context) {
    String totalWalkString = printDuration(totalWalk);
    String averageSpeed = NumberFormat("##0.0#")
        .format((totalDistance / totalWalk.inMinutes * 60));
    String printTotalSpent = NumberFormat("##0.0#").format(totalSpent);

    String printEmotions = '';
    for (String emotion in dailyEmotions.reversed.toList()) {
      printEmotions += '${extractEmojis(emotion)} | ';
    }

    String printPhysical = '';
    for (String condition in dailyPhysical.reversed.toList()) {
      printPhysical += '$condition | ';
    }

    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: Color(0xFFFFF4D5),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Headline('Day ${dayIndex.toString()}: ${toContextualDate(date)}'),
          const SizedBox(height: 10),
          Text('Total Walk time: $totalWalkString'),
          const SizedBox(height: 10),
          Text('Distance: $totalDistance km'),
          const SizedBox(height: 10),
          Text('Average Speed: $averageSpeed km/h'),
          const SizedBox(height: 10),
          if (dailyEmotions.isNotEmpty)
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Emotions: $printEmotions'),
              const SizedBox(height: 10),
            ]),
          if (dailyPhysical.isNotEmpty)
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Physical: $printPhysical'),
              const SizedBox(height: 10),
            ]),
          if (dailySleepDuration != null && dailySleepQuality != null)
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                  'Sleep: ${printDuration(dailySleepDuration!)} | $dailySleepQuality'),
              const SizedBox(height: 10),
            ]),
          Text('Total Spent: $printTotalSpent euro'),
        ],
      ),
    );
  }
}

String printDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  return "${twoDigits(duration.inHours)}:$twoDigitMinutes";
}

String extractEmojis(String text) {
  RegExp rx = RegExp(
      r'[\p{Extended_Pictographic}\u{1F3FB}-\u{1F3FF}\u{1F9B0}-\u{1F9B3}]',
      unicode: true);
  return rx.allMatches(text).map((z) => z.group(0)).toList().join("");
}
