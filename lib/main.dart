import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Analog Clock',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ClockScreen(),
    );
  }
}

class ClockScreen extends StatefulWidget {
  @override
  _ClockScreenState createState() => _ClockScreenState();
}

class _ClockScreenState extends State<ClockScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late DateTime _currentTime;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    )..repeat();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(Duration(seconds: 1), _updateTime);
  }

  void _updateTime(Timer timer) {
    setState(() {
      _currentTime = DateTime.now();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Analog Clock')),
      body: Center(
        child: ClockFace(currentTime: _currentTime),
      ),
    );
  }
}

class ClockFace extends StatelessWidget {
  final DateTime currentTime;

  ClockFace({required this.currentTime});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(300, 300),
      painter: ClockPainter(currentTime: currentTime),
    );
  }
}

class ClockPainter extends CustomPainter {
  final DateTime currentTime;

  ClockPainter({required this.currentTime});

  @override
  void paint(Canvas canvas, Size size) {
    // Paints
    Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    Paint hourHandPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    Paint minuteHandPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    Paint secondHandPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    Paint tickPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    // Draw the clock circle
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2, paint);

    // Draw the ticks (minute markers)
    for (int i = 0; i < 60; i++) {
      double angle = (i * 6 - 90) * pi / 180; // 6 degree increments
      double innerRadius = size.width / 2 * 0.85;
      double outerRadius = size.width / 2;
      double x1 = size.width / 2 + innerRadius * cos(angle);
      double y1 = size.height / 2 + innerRadius * sin(angle);
      double x2 = size.width / 2 + outerRadius * cos(angle);
      double y2 = size.height / 2 + outerRadius * sin(angle);
      if (i % 5 == 0) {
        // Draw bigger tick for minutes
        tickPaint.strokeWidth = 3;
      } else {
        tickPaint.strokeWidth = 1;
      }
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), tickPaint);
    }

    // Draw the numbers around the clock
    _drawNumbers(canvas, size);

    // Draw hour hand
    double hourAngle = (currentTime.hour % 12) * 30 + (currentTime.minute / 60) * 30;
    _drawHand(canvas, size, hourHandPaint, hourAngle, 0.5);

    // Draw minute hand
    double minuteAngle = currentTime.minute * 6 + (currentTime.second / 60) * 6;
    _drawHand(canvas, size, minuteHandPaint, minuteAngle, 0.7);

    // Draw second hand
    double secondAngle = currentTime.second * 6;
    _drawHand(canvas, size, secondHandPaint, secondAngle, 0.8);
  }

  void _drawHand(Canvas canvas, Size size, Paint paint, double angle, double lengthFactor) {
    double angleInRadians = (angle - 90) * pi / 180;
    double centerX = size.width / 2;
    double centerY = size.height / 2;
    double handLength = size.width / 2 * lengthFactor;
    double endX = centerX + handLength * cos(angleInRadians);
    double endY = centerY + handLength * sin(angleInRadians);

    canvas.drawLine(Offset(centerX, centerY), Offset(endX, endY), paint);
  }

  void _drawNumbers(Canvas canvas, Size size) {
    TextStyle textStyle = TextStyle(
      color: Colors.black,
      fontSize: 24,
      fontWeight: FontWeight.bold,
    );

    double radius = size.width / 2 * 0.75;

    for (int i = 1; i <= 12; i++) {
      double angle = (i * 30 - 90) * pi / 180;
      double x = size.width / 2 + radius * cos(angle);
      double y = size.height / 2 + radius * sin(angle);

      TextPainter textPainter = TextPainter(
        text: TextSpan(text: i.toString(), style: textStyle),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
