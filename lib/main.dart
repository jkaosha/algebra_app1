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

  void _updateLocation(PointerEvent details) {
    setState(() {
      x = (details.localPosition.dx / 40.0).round() * 40.0;
      y = (details.localPosition.dy / 40.0).round() * 40.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                // decoration: BoxDecoration(
                //   border: Border.all(),
                // ),
                child: MouseRegion(
                  onHover: _updateLocation,
                  cursor: SystemMouseCursors.click,
                  child: SizedBox(
                    width: canvasWidth,
                    height: canvasHeight,
                    child: CustomPaint(
                      foregroundPainter: DataPointPainter(x, y),
                      painter: GridPainter(canvasWidth, canvasHeight),
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
  GridPainter(width, height) {
    _canvasWidth = width;
    _canvasHeight = height;
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
    double yv = 0.0;
    for (int i = 0; i <= 10; i++) {
      xv = _canvasWidth / 10.0 * i;
      yv = _canvasWidth / 10.0 * i;
      canvas.drawLine(
        Offset(xv, -.05 * _canvasWidth),
        Offset(xv, _canvasHeight),
        paint,
      );
      canvas.drawLine(
        Offset(0.0, yv),
        Offset(_canvasWidth * 1.05, yv),
        paint,
      );
    }

    canvas.drawLine(
      Offset(0.0, -.05 * _canvasWidth),
      Offset(0.0, _canvasHeight),
      paintAxes,
    );
    canvas.drawLine(
      Offset(0.0, _canvasHeight),
      Offset(_canvasWidth * 1.05, _canvasHeight),
      paintAxes,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class DataPointPainter extends CustomPainter {
  double _x = 0.0;
  double _y = 0.0;
  DataPointPainter(x, y) {
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
