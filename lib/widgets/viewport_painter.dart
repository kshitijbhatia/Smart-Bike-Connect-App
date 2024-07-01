import 'package:flutter/material.dart';

class ViewportPainter extends CustomPainter {
  ViewportPainter(this.viewport);
  final Rect viewport;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white
      ..strokeWidth = 1;

    canvas.drawRect(viewport, paint);
  }

  @override
  bool shouldRepaint(covariant ViewportPainter oldDelegate) =>
      oldDelegate.viewport != viewport;
}


String googleUrl(int z, int x, int y) {
  //Google Maps
  final url =
      'https://www.google.com/maps/vt/pb=!1m4!1m3!1i$z!2i$x!3i$y!2m3!1e0!2sm!3i420120488!3m7!2sen!5e1105!12m4!1e68!2m2!1sset!2sRoadmap!4e0!5m1!1e0!23i4111425';
  return url;
}