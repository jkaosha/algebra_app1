import 'dart:ui';

import 'package:flutter/material.dart';

import 'dart:math';

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

  var dataList = List.generate(
    11,
    (i) => List.generate(
      11,
      (j) => false,
      growable: false,
    ),
    growable: false,
  );

  void _updateLocation(PointerEvent details) {
    setState(() {
      x = (details.localPosition.dx / 40.0).round() * 40.0;
      y = (details.localPosition.dy / 40.0).round() * 40.0;
    });
    //print((x/40).toString() + ", " + ((400-y)/40).toString());
  }

  void _toggleDataPoint() {
    int i = ((400 - y) / 40) as int;
    int j = x / 40 as int;
    dataList[i][j] ? dataList[i][j] = false : dataList[i][j] = true;
    //print(dataList);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MouseRegion(
                onHover: _updateLocation,
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: _toggleDataPoint,
                  child: SizedBox(
                    width: canvasWidth,
                    height: canvasHeight,
                    child: CustomPaint(
                      foregroundPainter: CursorPainter(x, y),
                      painter: GridPainter(canvasWidth, canvasHeight, dataList),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
  CursorPainter(x, y) {
    _x = x;
    _y = y;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var paint1 = Paint()
      ..color = Colors.blue
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10;
    canvas.drawPoints(PointMode.points, [Offset(_x, _y)], paint1);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class MySIEquation {
  double slope = 0.0;
  double yIntercept = 0.0;
  bool forceInteger = true;
  bool forceFirstQuadrant = true;
  Random r = Random();

  MySIEquation() {
    slope = (-1) ^ (r.nextInt(1)) * (r.nextInt(5) + 1) as double;
    yIntercept = slope.sign * -1 * r.nextInt((10 - slope.abs()) as int);
  }
}

class MyEquations {
  late List<MySIEquation> _equationList;
}
