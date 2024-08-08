// ignore_for_file: file_names

import 'package:flutter/material.dart';

class Anterior extends CustomPainter {
  final bool isBlue;
  final Map<String, dynamic> conditions;
  final String label;

  Anterior(
      {required this.isBlue, required this.conditions, required this.label});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    Paint fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    Paint blackPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    Paint greenPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    Paint pinkPaint = Paint()
      ..color = Colors.pink
      ..style = PaintingStyle.fill;

    // Draw the outer box
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Define the four triangles
    Path mesialTriangle = Path();
    Path distalTriangle = Path();
    Path palatalTriangle = Path();
    Path bukalTriangle = Path();

    if (label.startsWith('1')) {
      // 11-18: mesial (right), distal (left), palatal (bottom), bukal (top)
      mesialTriangle = Path()
        ..moveTo(size.width, 0)
        ..lineTo(size.width / 2, size.height / 2)
        ..lineTo(size.width, size.height)
        ..close();

      distalTriangle = Path()
        ..moveTo(0, 0)
        ..lineTo(size.width / 2, size.height / 2)
        ..lineTo(0, size.height)
        ..close();

      palatalTriangle = Path()
        ..moveTo(0, size.height)
        ..lineTo(size.width / 2, size.height / 2)
        ..lineTo(size.width, size.height)
        ..close();

      bukalTriangle = Path()
        ..moveTo(0, 0)
        ..lineTo(size.width / 2, size.height / 2)
        ..lineTo(size.width, 0)
        ..close();
    } else if (label.startsWith('2')) {
      // 21-28: mesial (left), distal (right), palatal (bottom), bukal (top)
      mesialTriangle = Path()
        ..moveTo(0, 0)
        ..lineTo(size.width / 2, size.height / 2)
        ..lineTo(0, size.height)
        ..close();

      distalTriangle = Path()
        ..moveTo(size.width, 0)
        ..lineTo(size.width / 2, size.height / 2)
        ..lineTo(size.width, size.height)
        ..close();

      palatalTriangle = Path()
        ..moveTo(0, size.height)
        ..lineTo(size.width / 2, size.height / 2)
        ..lineTo(size.width, size.height)
        ..close();

      bukalTriangle = Path()
        ..moveTo(0, 0)
        ..lineTo(size.width / 2, size.height / 2)
        ..lineTo(size.width, 0)
        ..close();
    } else if (label.startsWith('3')) {
      // 31-38: mesial (left), distal (right), palatal (top), bukal (bottom)
      mesialTriangle = Path()
        ..moveTo(0, 0)
        ..lineTo(size.width / 2, size.height / 2)
        ..lineTo(0, size.height)
        ..close();

      distalTriangle = Path()
        ..moveTo(size.width, 0)
        ..lineTo(size.width / 2, size.height / 2)
        ..lineTo(size.width, size.height)
        ..close();

      palatalTriangle = Path()
        ..moveTo(0, 0)
        ..lineTo(size.width / 2, size.height / 2)
        ..lineTo(size.width, 0)
        ..close();

      bukalTriangle = Path()
        ..moveTo(0, size.height)
        ..lineTo(size.width / 2, size.height / 2)
        ..lineTo(size.width, size.height)
        ..close();
    } else if (label.startsWith('4')) {
      // 41-48: mesial (right), distal (left), palatal (top), bukal (bottom)
      mesialTriangle = Path()
        ..moveTo(size.width, 0)
        ..lineTo(size.width / 2, size.height / 2)
        ..lineTo(size.width, size.height)
        ..close();

      distalTriangle = Path()
        ..moveTo(0, 0)
        ..lineTo(size.width / 2, size.height / 2)
        ..lineTo(0, size.height)
        ..close();

      palatalTriangle = Path()
        ..moveTo(0, 0)
        ..lineTo(size.width / 2, size.height / 2)
        ..lineTo(size.width, 0)
        ..close();

      bukalTriangle = Path()
        ..moveTo(0, size.height)
        ..lineTo(size.width / 2, size.height / 2)
        ..lineTo(size.width, size.height)
        ..close();
    }

    // Function to get the correct paint based on condition
    Paint getPaint(String? condition) {
      switch (condition) {
        case 'karies':
          return blackPaint;
        case 'komposit':
          return greenPaint;
        case 'gic':
          return pinkPaint;
        default:
          return fillPaint;
      }
    }

    // Draw and fill the triangles based on conditions
    canvas.drawPath(mesialTriangle, getPaint(conditions['mesial']));
    canvas.drawPath(mesialTriangle, paint);

    canvas.drawPath(bukalTriangle, getPaint(conditions['bukal']));
    canvas.drawPath(bukalTriangle, paint);

    canvas.drawPath(distalTriangle, getPaint(conditions['distal']));
    canvas.drawPath(distalTriangle, paint);

    canvas.drawPath(palatalTriangle, getPaint(conditions['palatal']));
    canvas.drawPath(palatalTriangle, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
