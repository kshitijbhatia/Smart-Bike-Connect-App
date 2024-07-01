import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProgressIndicatorView extends StatefulWidget {
  const ProgressIndicatorView({super.key});

  @override
  State<ProgressIndicatorView> createState() => _ProgressIndicatorViewState();
}

class _ProgressIndicatorViewState extends State<ProgressIndicatorView> with TickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    controller.addListener(() {});
    controller.repeat();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RotationTransition(
        turns: Tween(begin: 0.0, end: 1.0).animate(controller),
        child:  GradientCircularProgressIndicator(
          radius: 25,
          gradientColors: const [
            Color.fromRGBO(17, 58, 202, 1.0),
            Color.fromRGBO(17, 58, 202, 0.0),
          ],
          strokeWidth: 5.5.h,
        ),
      ),
    );
  }
}
class GradientCircularProgressIndicator extends StatelessWidget {
  final double radius;
  final List<Color>? gradientColors;
  final double strokeWidth;

  const GradientCircularProgressIndicator({
    this.radius = 0.0,
    this.gradientColors,
    this.strokeWidth = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.fromRadius(radius),
      painter: GradientCircularProgressPainter(
        radius: radius,
        gradientColors: gradientColors,
        strokeWidth: strokeWidth,
      ),
    );
  }
}

class GradientCircularProgressPainter extends CustomPainter {
  GradientCircularProgressPainter({
    this.radius = 0.0,
    this.gradientColors,
    this.strokeWidth = 8.0,
  });
  final double radius;
  final List<Color>? gradientColors;
  final double strokeWidth;
  double pi = 3.1415926535897932;
  @override
  void paint(Canvas canvas, Size size) {
    size = Size.fromRadius(radius);
    double offset = strokeWidth / 2;
    Rect rect = Offset(offset, offset) &
    Size(size.width - strokeWidth, size.height - strokeWidth);
    var paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    paint.shader =
        SweepGradient(colors: gradientColors!, startAngle: 0.0, endAngle: 2 * pi)
            .createShader(rect);
    canvas.drawArc(rect, 0.0, 2 * pi, false, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
