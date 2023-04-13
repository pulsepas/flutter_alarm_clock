import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_alarm_clock/app/data/theme_data.dart';

class ClockView extends StatefulWidget {
  final double? size;

  const ClockView({Key? key, this.size}) : super(key: key);

  @override
  _ClockViewState createState() => _ClockViewState();
}

class _ClockViewState extends State<ClockView> {
  late Timer timer;

  @override
  void initState() {
    this.timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    this.timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: widget.size,
        height: widget.size,
        child: Transform.rotate(
          angle: -pi / 2,
          child: CustomPaint(
            painter: ClockPainter(),
          ),
        ),
      ),
    );
  }
}

class ClockPainter extends CustomPainter {
  var dateTime = DateTime.now();

  //60sec - 360, 1 sec - 6degrees
  //60min - 360, 1 min - 6degrees
  //12hours - 360, 1 hour - 30degrees, 60min - 30degrees, 1 min - 0.5degrees
  double getStartAngle(int hour) {
    if (hour >= 1 && hour < 5) {
      return pi / 6; // Wood - Green
    } else if (hour >= 5 && hour < 9) {
      return 0; // Metal - Grey
    } else if (hour >= 9 && hour < 13) {
      return -pi / 6; // Earth - Orange
    } else if (hour >= 13 && hour < 17) {
      return -pi / 2; // Fire - Red
    } else if (hour >= 17 && hour < 21) {
      return -2 * pi / 3; // Water - Blue
    } else {
      return -5 * pi / 6; // Lightning - Magenta
    }
  }

  void drawInnerColoredArcs(Canvas canvas, Offset center, double radius) {
    double arcAngle = 2 * pi / 6;
    List<Color> colors = [
      Colors.grey,
      Colors.orange,
      Colors.red,
      Colors.blue,
      Colors.purple,
      Colors.green,
    ];

    int hour = dateTime.hour;
    double startAngle = getStartAngle(hour);

    bool isAM = hour >= 1 && hour < 13;
    double innerRadius;
    double strokeWidth = radius * 0.15;

    for (int i = 0; i < 6; i++) {
      innerRadius = isAM ? radius * 0.5 : radius * 0.65;

      var arcPaint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: innerRadius + strokeWidth / 2),
        startAngle + i * arcAngle,
        arcAngle,
        false,
        arcPaint,
      );
    }

    for (int i = 0; i < 6; i++) {
      innerRadius = !isAM ? radius * 0.5 : radius * 0.65;

      var arcPaint = Paint()
        ..color = colors[i].withOpacity(!isAM ? 0.4 : 1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: innerRadius + strokeWidth / 2),
        startAngle + i * arcAngle,
        arcAngle,
        false,
        arcPaint,
      );
    }
  }

  void drawColoredSectors(Canvas canvas, Offset center, double radius) {
    var sectorPaint1 = Paint()..color = Colors.red.withOpacity(0.3);
    var sectorPaint2 = Paint()..color = Colors.green.withOpacity(0.3);
    var sectorPaint3 = Paint()..color = Colors.blue.withOpacity(0.3);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.75),
      0,
      2 * pi / 3,
      true,
      sectorPaint1,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.75),
      2 * pi / 3,
      2 * pi / 3,
      true,
      sectorPaint2,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.75),
      4 * pi / 3,
      2 * pi / 3,
      true,
      sectorPaint3,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    var centerX = size.width / 2;
    var centerY = size.height / 2;
    var center = Offset(centerX, centerY);
    var radius = min(centerX, centerY);

    var fillBrush = Paint()..color = CustomColors.clockBG;
    var outlineBrush = Paint()
      ..color = CustomColors.clockOutline
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width / 20;
    var centerDotBrush = Paint()..color = CustomColors.clockOutline;

    var secHandBrush = Paint()
      ..color = CustomColors.secHandColor!
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width / 60;

    var minHandBrush = Paint()
      ..shader = RadialGradient(colors: [
        CustomColors.minHandStatColor,
        CustomColors.minHandEndColor
      ]).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width / 30;

    var hourHandBrush = Paint()
      ..shader = RadialGradient(colors: [
        CustomColors.hourHandStatColor,
        CustomColors.hourHandEndColor
      ]).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width / 24;

    var dashBrush = Paint()
      ..color = CustomColors.clockOutline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(center, radius * 0.75, fillBrush);
    canvas.drawCircle(center, radius * 0.75, outlineBrush);

    var hourHandX = centerX +
        radius *
            0.4 *
            cos((dateTime.hour * 30 + dateTime.minute * 0.5) * pi / 180);
    var hourHandY = centerY +
        radius *
            0.4 *
            sin((dateTime.hour * 30 + dateTime.minute * 0.5) * pi / 180);
    canvas.drawLine(center, Offset(hourHandX, hourHandY), hourHandBrush);

    var minHandX = centerX + radius * 0.6 * cos(dateTime.minute * 6 * pi / 180);
    var minHandY = centerY + radius * 0.6 * sin(dateTime.minute * 6 * pi / 180);
    canvas.drawLine(center, Offset(minHandX, minHandY), minHandBrush);

    var secHandX = centerX + radius * 0.6 * cos(dateTime.second * 6 * pi / 180);
    var secHandY = centerY + radius * 0.6 * sin(dateTime.second * 6 * pi / 180);
    canvas.drawLine(center, Offset(secHandX, secHandY), secHandBrush);

    canvas.drawCircle(center, radius * 0.12, centerDotBrush);

    var outerRadius = radius;
    var innerRadius = radius * 0.9;
    for (var i = 0; i < 360; i += 12) {
      var x1 = centerX + outerRadius * cos(i * pi / 180);
      var y1 = centerY + outerRadius * sin(i * pi / 180);

      var x2 = centerX + innerRadius * cos(i * pi / 180);
      var y2 = centerY + innerRadius * sin(i * pi / 180);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), dashBrush);
    }
    drawInnerColoredArcs(canvas, center, radius);
    //  drawColoredSectors(canvas, center, radius * 0.75);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
