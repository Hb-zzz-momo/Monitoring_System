import 'package:flutter/material.dart';

/// 自绘 SiC/Si 混合功率模块 3D 渲染图
class SiCModuleWidget extends StatelessWidget {
  const SiCModuleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 340,
      height: 220,
      child: CustomPaint(painter: _SiCModulePainter()),
    );
  }
}

class _SiCModulePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.08, h * 0.2, w * 0.88, h * 0.7), const Radius.circular(6)),
      shadowPaint,
    );

    final bodyRect = Rect.fromLTWH(w * 0.08, h * 0.15, w * 0.84, h * 0.65);
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFF5F5F0), Color(0xFFE8E6E0), Color(0xFFD8D6D0)],
      ).createShader(bodyRect);
    canvas.drawRRect(
        RRect.fromRectAndRadius(bodyRect, const Radius.circular(6)), bodyPaint);

    final borderPaint = Paint()
      ..color = const Color(0xFFB0AEA8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(
        RRect.fromRectAndRadius(bodyRect, const Radius.circular(6)), borderPaint);

    final coverRect = Rect.fromLTWH(w * 0.14, h * 0.22, w * 0.72, h * 0.35);
    final coverPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0x40FFFFFF), Color(0x20B0D0F0), Color(0x30FFFFFF)],
      ).createShader(coverRect);
    canvas.drawRRect(
        RRect.fromRectAndRadius(coverRect, const Radius.circular(3)), coverPaint);
    final coverBorder = Paint()
      ..color = const Color(0x60909090)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(
        RRect.fromRectAndRadius(coverRect, const Radius.circular(3)), coverBorder);

    final chipPaint = Paint()..color = const Color(0xFF2D2D3D);
    final goldPaint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..strokeWidth = 0.8;

    for (int i = 0; i < 3; i++) {
      final cx = w * 0.22 + i * w * 0.08;
      final cy = h * 0.32;
      canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy), width: 18, height: 14), chipPaint);
      canvas.drawLine(Offset(cx, cy - 7), Offset(cx, cy - 14), goldPaint);
      canvas.drawLine(Offset(cx, cy + 7), Offset(cx, cy + 14), goldPaint);
    }

    for (int i = 0; i < 3; i++) {
      final cx = w * 0.58 + i * w * 0.08;
      final cy = h * 0.32;
      canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy), width: 18, height: 14), chipPaint);
      canvas.drawLine(Offset(cx, cy - 7), Offset(cx, cy - 14), goldPaint);
      canvas.drawLine(Offset(cx, cy + 7), Offset(cx, cy + 14), goldPaint);
    }

    final dbcPaint = Paint()..color = const Color(0xFFC0B8A0);
    canvas.drawRect(
        Rect.fromLTWH(w * 0.16, h * 0.44, w * 0.68, h * 0.1), dbcPaint);

    final holePaint = Paint()..color = const Color(0xFF606060);
    final holeStroke = Paint()
      ..color = const Color(0xFF808080)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final holes = [
      Offset(w * 0.13, h * 0.22),
      Offset(w * 0.87, h * 0.22),
      Offset(w * 0.13, h * 0.72),
      Offset(w * 0.87, h * 0.72),
    ];
    for (final pos in holes) {
      canvas.drawCircle(pos, 8, holePaint);
      canvas.drawCircle(pos, 8, holeStroke);
      canvas.drawCircle(pos, 3, Paint()..color = const Color(0xFF404040));
    }

    final pinPaint = Paint()..color = const Color(0xFFB0B0B0);
    final pinHighlight = Paint()..color = const Color(0xFFD0D0D0);
    for (int i = 0; i < 4; i++) {
      final px = w * 0.25 + i * w * 0.17;
      final pinRect = Rect.fromLTWH(px - 8, h * 0.02, 16, h * 0.15);
      canvas.drawRRect(
          RRect.fromRectAndRadius(pinRect, const Radius.circular(2)), pinPaint);
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(px - 6, h * 0.03, 4, h * 0.13), const Radius.circular(1)),
          pinHighlight);
    }

    for (int i = 0; i < 4; i++) {
      final px = w * 0.25 + i * w * 0.17;
      final pinRect = Rect.fromLTWH(px - 8, h * 0.82, 16, h * 0.15);
      canvas.drawRRect(
          RRect.fromRectAndRadius(pinRect, const Radius.circular(2)), pinPaint);
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(px - 6, h * 0.83, 4, h * 0.13), const Radius.circular(1)),
          pinHighlight);
    }

    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'SiC/Si Power Module',
        style: TextStyle(color: Color(0xFF606060), fontSize: 9),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(w * 0.3, h * 0.62));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
