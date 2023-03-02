import 'dart:ui';

import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  double x = 0.0;
  double y = 0.0;
  double canvasWidth = 400;
  double canvasHeight = 400;
  MySIEquation eqns = MySIEquation();
  Map currentEquation = {};
  bool drawCursor = false;

  @override
  _MainAppState() {
    currentEquation = eqns.getNextEquation();
    _resetDataList();
    print(currentEquation);
  }

  List<List<bool>> dataList = [];

  void _resetDataList() {
    dataList = List.generate(
      11,
      (i) => List.generate(
        11,
        (j) => false,
        growable: false,
      ),
      growable: false,
    );
  }

  void _updateLocation(PointerEvent details) {
    setState(() {
      x = (details.localPosition.dx / 40.0).round() * 40.0;
      y = (details.localPosition.dy / 40.0).round() * 40.0;
      drawCursor = true;
    });
    //print((x/40).toString() + ", " + ((400-y)/40).toString());
  }

  void _toggleDataPoint() {
    int i = ((400 - y) / 40) as int;
    int j = x / 40 as int;
    setState(
        () => dataList[i][j] ? dataList[i][j] = false : dataList[i][j] = true);
    //print(dataList);
  }

  void nextEquation() {
    setState(() => currentEquation = eqns.getNextEquation());
    print(currentEquation);
  }

  bool checkAnswer() {
    bool correct = true;
    int numPoints = 0;
    for (int i = 0; i <= 10; i++) {
      // grab the dots for the data points
      var r = dataList[i];
      r.asMap().forEach((index, d) {
        if (d) {
          numPoints++;
        }
        if (d &&
            (i !=
                currentEquation['slope'] * index +
                    currentEquation['yIntercept'])) {
          correct = false;
        }
      });
    }
    print(correct && numPoints > 1);
    return (correct && numPoints > 1);
  }

  @override
  Widget build(BuildContext context) {
    String eqnString = "y = ";
    eqnString += currentEquation['slope'].sign < 0 ? "−" : "";

    eqnString += currentEquation['slope'].abs() != 1
        ? currentEquation['slope'].abs().toString()
        : "";

    eqnString += "x";

    eqnString += currentEquation['yIntercept'] != 0
        ? " + ${currentEquation['yIntercept']}"
        : "";

    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Graph $eqnString",
                style: const TextStyle(fontSize: 18),
              ),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: MouseRegion(
                  onHover: _updateLocation,
                  onExit: (p) {
                    setState(() => drawCursor = false);
                  },
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: _toggleDataPoint,
                    child: SizedBox(
                      width: canvasWidth,
                      height: canvasHeight,
                      child: CustomPaint(
                        foregroundPainter: CursorPainter(x, y, drawCursor),
                        painter:
                            GridPainter(canvasWidth, canvasHeight, dataList),
                      ),
                    ),
                  ),
                ),
              ),
              ActionButtons(
                checkAnswer: checkAnswer,
                nextEquation: nextEquation,
              ),
              TextButton(
                onPressed: () {
                  setState(() => _resetDataList());
                },
                child: const Text("Clear graph"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ActionButtons extends StatelessWidget {
  final dynamic checkAnswer;
  final dynamic nextEquation;
  const ActionButtons(
      {required this.checkAnswer, required this.nextEquation, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        TextButton(
          onPressed: () {
            bool correct = checkAnswer();
            showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                content: Text(correct ? "Correct!" : "Incorrect"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Close"),
                  ),
                ],
              ),
            );
          },
          child: const Text("Check Answer"),
        ),
        TextButton(
          onPressed: () {
            nextEquation();
          },
          child: const Text("Next Equation"),
        ),
      ],
    );
  }
}

class GridPainter extends CustomPainter {
  double _canvasWidth = 0.0;
  double _canvasHeight = 0.0;
  late List<List<bool>> _gridData;

  GridPainter(width, height, gridData) {
    _canvasWidth = width;
    _canvasHeight = height;
    _gridData = gridData;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;
    final paintAxes = Paint()
      ..color = Colors.black
      ..strokeWidth = 3;

    double xv = 0.0;
    double yh = 0.0;
    List<Offset> dataPoints = [];

    for (int i = 0; i <= 10; i++) {
      xv = _canvasWidth / 10.0 * i;
      yh = _canvasHeight / 10.0 * i;
      canvas.drawLine(
        Offset(xv, -.05 * _canvasWidth),
        Offset(xv, _canvasHeight),
        paint,
      );
      final TextPainter textPainter = TextPainter(
        text: TextSpan(text: i.toString()),
        textAlign: TextAlign.right,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: size.width * 0.1);
      textPainter.paint(canvas, Offset(xv - 4, _canvasHeight + 5));
      textPainter.paint(canvas, Offset(-20, _canvasHeight - i * 40.0 - 6));

      canvas.drawLine(
        Offset(0.0, yh),
        Offset(_canvasWidth * 1.05, yh),
        paint,
      );
      // grab the dots for the data points
      var r = _gridData[i];
      r.asMap().forEach((index, d) => {
            if (d)
              {
                dataPoints.add(Offset(
                  index * 40.0,
                  400 - i * 40 as double,
                ))
              }
          });
    }
    final TextPainter textPainterY = TextPainter(
      text: const TextSpan(text: "y"),
      textAlign: TextAlign.right,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width * 0.1);
    // thick line for y-axis
    canvas.drawLine(
      Offset(0.0, -.05 * _canvasWidth),
      Offset(0.0, _canvasHeight),
      paintAxes,
    );
    textPainterY.paint(canvas, const Offset(-5.0, -45.0));

    final TextPainter textPainterX = TextPainter(
      text: const TextSpan(text: "x"),
      textAlign: TextAlign.right,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width * 0.1);
    // thick line for x-axis
    canvas.drawLine(
      Offset(0.0, _canvasHeight),
      Offset(_canvasWidth * 1.05, _canvasHeight),
      paintAxes,
    );
    textPainterX.paint(canvas, Offset(_canvasWidth + 30, _canvasHeight - 10));

    var paint1 = Paint()
      ..color = Colors.red
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10;
    canvas.drawPoints(PointMode.points, dataPoints, paint1);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class CursorPainter extends CustomPainter {
  double _x = 0.0;
  double _y = 0.0;
  bool _drawCursor = false;
  CursorPainter(x, y, drawCursor) {
    _x = x;
    _y = y;
    _drawCursor = drawCursor;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var paint1 = Paint()
      ..color = Colors.blue
      ..strokeCap = StrokeCap.round
      ..strokeWidth = _drawCursor ? 10 : 0;
    canvas.drawPoints(PointMode.points, [Offset(_x, _y)], paint1);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class MySIEquation {
  static final List<int> _slopes = [
    -3,
    -3,
    -2,
    -2,
    -2,
    -2,
    -2,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    2,
    2,
    2,
    2,
    2,
    3,
    3
  ];
  static final List<int> _yIntercepts = [
    10,
    9,
    10,
    9,
    8,
    7,
    6,
    10,
    9,
    8,
    7,
    6,
    5,
    4,
    3,
    7,
    6,
    5,
    4,
    3,
    2,
    1,
    0,
    4,
    3,
    2,
    1,
    0,
    1,
    0
  ];
  static List<Map> siEquationParams = [];
  int _xDataMax = 3;
  double _slope = 0.0;
  double _yIntercept = 0.0;
  bool _forceInteger = true;
  bool _forceFirstQuadrant = true;
  int currentEquation = 0;

  MySIEquation() {
    _slopes.asMap().forEach((index, s) => {
          siEquationParams.add(
            {
              'slope': s,
              'yIntercept': _yIntercepts[index],
            },
          )
        });
    siEquationParams.shuffle();
    print(siEquationParams[currentEquation]);
  }

  Map getNextEquation() {
    if (currentEquation == siEquationParams.length) {
      siEquationParams.shuffle();
      currentEquation = 0;
    }
    currentEquation++;
    return (siEquationParams[currentEquation - 1]);
  }
}
