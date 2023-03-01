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

  var dataList = List.generate(
    10,
    (i) => List.generate(
      10,
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
    print(dataList);
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
                  child: GestureDetector(
                    onTap: _toggleDataPoint,
                    child: SizedBox(
                      width: canvasWidth,
                      height: canvasHeight,
                      child: CustomPaint(
                        foregroundPainter: DataPointPainter(x, y),
                        painter:
                            GridPainter(canvasWidth, canvasHeight, dataList),
                      ),
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
    double yv = 0.0;
    List<Offset> dataPoints = [];

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

    for (int i = 0; i < 10; i++) {
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
    var paint1 = Paint()
      ..color = Colors.red
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10;
    canvas.drawPoints(PointMode.points, dataPoints, paint1);
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
