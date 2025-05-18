// ignore_for_file: file_names

import 'package:flutter/material.dart';

class Posterior extends CustomPainter {
  final bool isBlue;
  final Map<String, dynamic> conditions;
  final String label;

  Posterior(
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

    // Define the four trapezoids
    Path mesialTrapezoid = Path();
    Path distalTrapezoid = Path();
    Path palatalTrapezoid = Path();
    Path bukalTrapezoid = Path();

    if (label.startsWith('1')) {
      // 11-18: mesial (right), distal (left), palatal (bottom), bukal (top)
      mesialTrapezoid = Path()
        ..moveTo(size.width, 0)
        ..lineTo(size.width / 2, size.height / 2)
        ..lineTo(size.width, size.height)
        ..close();

      distalTrapezoid = Path()
        ..moveTo(0, 0)
        ..lineTo(size.width / 2, size.height / 2)
        ..lineTo(0, size.height)
        ..close();

      palatalTrapezoid = Path()
        ..moveTo(0, size.height)
        ..lineTo(size.width / 4, 3 * size.height / 4)
        ..lineTo(3 * size.width / 4, 3 * size.height / 4)
        ..lineTo(size.width, size.height)
        ..close();

      bukalTrapezoid = Path()
        ..moveTo(0, 0)
        ..lineTo(size.width / 4, size.height / 4)
        ..lineTo(3 * size.width / 4, size.height / 4)
        ..lineTo(size.width, 0)
        ..close();
    } else if (label.startsWith('2')) {
      // 21-28: mesial (left), distal (right), palatal (bottom), bukal (top)
      mesialTrapezoid = Path()
        ..moveTo(0, 0)
        ..lineTo(size.width / 2, size.height / 2)
        ..lineTo(0, size.height)
        ..close();

      distalTrapezoid = Path()
        ..moveTo(size.width, 0)
        ..lineTo(size.width / 2, size.height / 2)
        ..lineTo(size.width, size.height)
        ..close();

      palatalTrapezoid = Path()
        ..moveTo(0, size.height)
        ..lineTo(size.width / 4, 3 * size.height / 4)
        ..lineTo(3 * size.width / 4, 3 * size.height / 4)
        ..lineTo(size.width, size.height)
        ..close();

      bukalTrapezoid = Path()
        ..moveTo(0, 0)
        ..lineTo(size.width / 4, size.height / 4)
        ..lineTo(3 * size.width / 4, size.height / 4)
        ..lineTo(size.width, 0)
        ..close();
    } else if (label.startsWith('3')) {
      // 31-38: mesial (left), distal (right), palatal (top), bukal (bottom)
      mesialTrapezoid = Path()
        ..moveTo(0, 0)
        ..lineTo(size.width / 2, size.height / 2)
        ..lineTo(0, size.height)
        ..close();

      distalTrapezoid = Path()
        ..moveTo(size.width, 0)
        ..lineTo(size.width / 2, size.height / 2)
        ..lineTo(size.width, size.height)
        ..close();

      palatalTrapezoid = Path()
        ..moveTo(0, 0)
        ..lineTo(size.width / 4, size.height / 4)
        ..lineTo(3 * size.width / 4, size.height / 4)
        ..lineTo(size.width, 0)
        ..close();

      bukalTrapezoid = Path()
        ..moveTo(0, size.height)
        ..lineTo(size.width / 4, 3 * size.height / 4)
        ..lineTo(3 * size.width / 4, 3 * size.height / 4)
        ..lineTo(size.width, size.height)
        ..close();
    } else if (label.startsWith('4')) {
      // 41-48: mesial (right), distal (left), palatal (top), bukal (bottom)
      mesialTrapezoid = Path()
        ..moveTo(size.width, 0)
        ..lineTo(size.width / 2, size.height / 2)
        ..lineTo(size.width, size.height)
        ..close();

      distalTrapezoid = Path()
        ..moveTo(0, 0)
        ..lineTo(size.width / 2, size.height / 2)
        ..lineTo(0, size.height)
        ..close();

      palatalTrapezoid = Path()
        ..moveTo(0, 0)
        ..lineTo(size.width / 4, size.height / 4)
        ..lineTo(3 * size.width / 4, size.height / 4)
        ..lineTo(size.width, 0)
        ..close();

      bukalTrapezoid = Path()
        ..moveTo(0, size.height)
        ..lineTo(size.width / 4, 3 * size.height / 4)
        ..lineTo(3 * size.width / 4, 3 * size.height / 4)
        ..lineTo(size.width, size.height)
        ..close();
    }

    // Define the occlusal area
    Path occlusalArea = Path()
      ..moveTo(size.width / 4, size.height / 4)
      ..lineTo(3 * size.width / 4, size.height / 4)
      ..lineTo(3 * size.width / 4, 3 * size.height / 4)
      ..lineTo(size.width / 4, 3 * size.height / 4)
      ..close();

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

    // Draw and fill the trapezoids based on conditions
    canvas.drawPath(mesialTrapezoid, getPaint(conditions['mesial']));
    canvas.drawPath(mesialTrapezoid, paint);

    canvas.drawPath(bukalTrapezoid, getPaint(conditions['bukal']));
    canvas.drawPath(bukalTrapezoid, paint);

    canvas.drawPath(distalTrapezoid, getPaint(conditions['distal']));
    canvas.drawPath(distalTrapezoid, paint);

    canvas.drawPath(palatalTrapezoid, getPaint(conditions['palatal']));
    canvas.drawPath(palatalTrapezoid, paint);

    // Draw and fill the occlusal area based on condition
    canvas.drawPath(occlusalArea, getPaint(conditions['oclusal']));
    canvas.drawPath(occlusalArea, paint);

    // Check if 'CFR' is selected for 'teks_bawah' and draw the hash symbol (#)
    if (conditions['teks_bawah'] == 'CFR') {
      final textPainter = TextPainter(
        text: const TextSpan(
          text: '#',
          style: TextStyle(fontSize: 48, color: Colors.black),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(minWidth: 0, maxWidth: size.width);
      textPainter.paint(
        canvas,
        Offset((size.width - textPainter.width) / 2,
            (size.height - textPainter.height) / 2),
      );
    }

    // Check if 'RRX' is selected for 'teks_bawah' and draw the diagonal check mark
    if (conditions['teks_bawah'] == 'RRX') {
      Paint checkMarkPaint = Paint()
        ..color = Colors.black
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;

      // Draw the diagonal check mark (V shape)
      Path checkMarkPath = Path();
      checkMarkPath.moveTo(size.width * 0.2, size.height * 0.6);
      checkMarkPath.lineTo(size.width * 0.4, size.height * 0.85);
      checkMarkPath.lineTo(size.width * 0.7, size.height * 0.2);

      canvas.drawPath(checkMarkPath, checkMarkPaint);
    }

    // Check if 'MISSING' is selected for 'teks_bawah' and draw the X mark
    if (conditions['teks_bawah'] == 'MISSING') {
      Paint crossPaint = Paint()
        ..color = Colors.black
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;

      // Draw the 'X' mark
      canvas.drawLine(
          const Offset(-5, -5), Offset(size.width+5, size.height+5), crossPaint);
      canvas.drawLine(
          Offset(size.width+5, -5), Offset(-5, size.height+5), crossPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
