import 'package:flutter/material.dart';

/// Reusable broccoli mascot widget backed by the same CustomPainter
/// used in the splash onboarding — just pass the [size].
class BroccoliMascot extends StatefulWidget {
  final double size;
  const BroccoliMascot({super.key, required this.size});

  @override
  State<BroccoliMascot> createState() => _BroccoliMascotState();
}

class _BroccoliMascotState extends State<BroccoliMascot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _bob;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _bob = Tween<double>(begin: -6, end: 6)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bob,
      builder: (_, child) =>
          Transform.translate(offset: Offset(0, _bob.value), child: child),
      child: CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _BroccoliPainter(),
      ),
    );
  }
}

class _BroccoliPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Stem
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.42, h * 0.55, w * 0.16, h * 0.38),
        const Radius.circular(8),
      ),
      Paint()..color = const Color(0xFF4A8C5C),
    );

    // Main head
    canvas.drawCircle(Offset(w * 0.5, h * 0.38), w * 0.34,
        Paint()..color = const Color(0xFF3D7A52));

    // Sub clusters
    final sub = Paint()..color = const Color(0xFF4A8C5C);
    canvas.drawCircle(Offset(w * 0.32, h * 0.42), w * 0.22, sub);
    canvas.drawCircle(Offset(w * 0.68, h * 0.42), w * 0.22, sub);
    canvas.drawCircle(Offset(w * 0.5, h * 0.24), w * 0.24, sub);

    // Highlights
    final hl = Paint()..color = const Color(0xFF5BAA6F);
    canvas.drawCircle(Offset(w * 0.5, h * 0.20), w * 0.16, hl);
    canvas.drawCircle(Offset(w * 0.30, h * 0.36), w * 0.12, hl);
    canvas.drawCircle(Offset(w * 0.70, h * 0.36), w * 0.12, hl);

    // Shadow
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.56), width: w * 0.6, height: h * 0.08),
      Paint()..color = const Color(0xFF2A5C38).withValues(alpha: 0.4),
    );

    // Eyes
    canvas.drawCircle(Offset(w * 0.42, h * 0.40), w * 0.05,
        Paint()..color = Colors.white);
    canvas.drawCircle(Offset(w * 0.58, h * 0.40), w * 0.05,
        Paint()..color = Colors.white);
    canvas.drawCircle(Offset(w * 0.43, h * 0.41), w * 0.028,
        Paint()..color = const Color(0xFF1A2A1E));
    canvas.drawCircle(Offset(w * 0.59, h * 0.41), w * 0.028,
        Paint()..color = const Color(0xFF1A2A1E));
    canvas.drawCircle(
        Offset(w * 0.44, h * 0.395), w * 0.01, Paint()..color = Colors.white);
    canvas.drawCircle(
        Offset(w * 0.60, h * 0.395), w * 0.01, Paint()..color = Colors.white);

    // Smile
    final smilePath = Path()
      ..moveTo(w * 0.41, h * 0.47)
      ..quadraticBezierTo(w * 0.5, h * 0.53, w * 0.59, h * 0.47);
    canvas.drawPath(
      smilePath,
      Paint()
        ..color = const Color(0xFF1A2A1E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.022
        ..strokeCap = StrokeCap.round,
    );

    // Blush
    canvas.drawCircle(Offset(w * 0.35, h * 0.46), w * 0.045,
        Paint()..color = const Color(0xFFFF8FAB).withValues(alpha: 0.5));
    canvas.drawCircle(Offset(w * 0.65, h * 0.46), w * 0.045,
        Paint()..color = const Color(0xFFFF8FAB).withValues(alpha: 0.5));

    // Arms
    final arm = Paint()
      ..color = const Color(0xFFD4A574)
      ..strokeWidth = w * 0.06
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(
      Path()
        ..moveTo(w * 0.22, h * 0.50)
        ..quadraticBezierTo(w * 0.14, h * 0.42, w * 0.10, h * 0.30),
      arm,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.78, h * 0.50)
        ..quadraticBezierTo(w * 0.86, h * 0.38, w * 0.90, h * 0.28),
      arm,
    );

    // Fork
    final fork = Paint()
      ..color = const Color(0xFFC0C0C0)
      ..strokeWidth = w * 0.025
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(w * 0.10, h * 0.30), Offset(w * 0.07, h * 0.18), fork);
    canvas.drawLine(Offset(w * 0.12, h * 0.29), Offset(w * 0.10, h * 0.17), fork);
    canvas.drawLine(Offset(w * 0.14, h * 0.29), Offset(w * 0.13, h * 0.17), fork);

    // Right hand
    canvas.drawCircle(Offset(w * 0.90, h * 0.26), w * 0.06,
        Paint()..color = const Color(0xFFD4A574));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}