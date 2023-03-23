import 'package:flutter/material.dart';

class ContingencyMatrix extends StatelessWidget {
  const ContingencyMatrix({
    super.key,
    this.firstParamColor,
    this.secondParamColor,
    required this.n00,
    required this.n10,
    required this.n01,
    required this.n11,
  });

  final Color? firstParamColor;
  final Color? secondParamColor;
  final int n00;
  final int n10;
  final int n01;
  final int n11;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: Column(children: [
        //First Row
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Container(
            height: 49,
            width: 49,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(),
                left: BorderSide(),
              ),
              gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  stops: [
                    0.45,
                    0.55,
                  ],
                  colors: [
                    secondParamColor!,
                    firstParamColor!,
                  ]),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    Text(
                      '#1',
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: const [
                    Text('#2'),
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: 49,
            width: 109,
            decoration: BoxDecoration(
              color: firstParamColor,
              border: Border(top: BorderSide(), left: BorderSide()),
            ),
            child: Center(
              child: Icon(Icons.event_available),
            ),
          ),
          Container(
            height: 49,
            width: 109,
            decoration: BoxDecoration(
              color: firstParamColor,
              border: Border(
                top: BorderSide(),
                left: BorderSide(width: 1, color: Colors.black38),
              ),
            ),
            child: Center(
              child: Icon(Icons.event_busy),
            ),
          ),
          Container(
            height: 49,
            width: 49,
            decoration: BoxDecoration(
              border: Border(left: BorderSide()),
            ),
          ),
        ]),
        //SecondRow
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 49,
              width: 49,
              decoration: BoxDecoration(
                color: secondParamColor,
                border: Border(
                    top: BorderSide(width: 1), left: BorderSide(width: 1)),
              ),
              child: Icon(Icons.event_available),
            ),
            Container(
              height: 49,
              width: 109,
              decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(width: 1), left: BorderSide(width: 1)),
              ),
              child: Center(child: Text(n11.toString())),
            ),
            Container(
              height: 49,
              width: 109,
              decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(width: 1),
                    left: BorderSide(width: 1, color: Colors.black38)),
              ),
              child: Center(child: Text(n01.toString())),
            ),
            Container(
              height: 49,
              width: 49,
              decoration: BoxDecoration(
                color: secondParamColor,
                border: Border(left: BorderSide()),
              ),
              child: Center(child: Text((n11 + n01).toString())),
            ),
          ],
        ),
        //ThirdRow
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 49,
              width: 49,
              decoration: BoxDecoration(
                color: secondParamColor,
                border: Border(
                    top: BorderSide(width: 1, color: Colors.black38),
                    left: BorderSide(width: 1)),
              ),
              child: Icon(Icons.event_busy),
            ),
            Container(
              height: 49,
              width: 109,
              decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(width: 1, color: Colors.black38),
                    left: BorderSide(width: 1)),
              ),
              child: Center(child: Text(n10.toString())),
            ),
            Container(
              height: 49,
              width: 109,
              decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(width: 1, color: Colors.black38),
                    left: BorderSide(width: 1, color: Colors.black38)),
              ),
              child: Center(child: Text(n00.toString())),
            ),
            Container(
              height: 49,
              width: 49,
              decoration: BoxDecoration(
                color: secondParamColor,
                border: Border(
                    top: BorderSide(width: 1, color: Colors.black38),
                    left: BorderSide()),
              ),
              child: Center(child: Text((n10 + n00).toString())),
            ),
          ],
        ),
        //FourthRow
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 49,
              width: 49,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(width: 1),
                  left: BorderSide(width: 1, color: Colors.transparent),
                ),
              ),
            ),
            Container(
              height: 49,
              width: 109,
              decoration: BoxDecoration(
                color: firstParamColor,
                border: Border(top: BorderSide(width: 1)),
              ),
              child: Center(child: Text((n11 + n10).toString())),
            ),
            Container(
              height: 49,
              width: 109,
              decoration: BoxDecoration(
                color: firstParamColor,
                border: Border(
                    top: BorderSide(width: 1),
                    left: BorderSide(width: 1, color: Colors.black38)),
              ),
              child: Center(child: Text((n01 + n00).toString())),
            ),
            //this info is incorrect if we make adjustment with dayIntervalsToIgnore
            // Container(
            //   height: 49,
            //   width: 49,
            //   decoration: BoxDecoration(border: Border.all()),
            //   child: Center(child: Text((n10 + n11 + n00 + n01).toString())),
            // ),
          ],
        )
      ]),
    );
  }
}
