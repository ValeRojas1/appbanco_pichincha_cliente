import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PichinchaSymbol extends StatelessWidget {
  final double size;
  const PichinchaSymbol({super.key, this.size = 60});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.amarillo,
        borderRadius: BorderRadius.circular(size * 0.22),
        boxShadow: [
          BoxShadow(
            color: AppTheme.amarillo.withValues(alpha: 0.25),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: EdgeInsets.all(size * 0.15),
      child: CustomPaint(
        painter: _PichinchaSymbolPainter(),
      ),
    );
  }
}

class _PichinchaSymbolPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintBg = Paint()..color = AppTheme.navy;
    final rrect = RRect.fromRectAndCorners(
      Rect.fromLTWH(0, 0, size.width, size.height),
      bottomLeft: Radius.circular(size.width * 0.35),
    );
    canvas.drawRRect(rrect, paintBg);

    final paintArrow = Paint()..color = AppTheme.amarillo;
    final path = Path();
    path.moveTo(size.width * 0.45, size.height * 0.25);
    path.lineTo(size.width * 0.75, size.height * 0.25);
    path.lineTo(size.width * 0.75, size.height * 0.55);
    path.lineTo(size.width * 0.60, size.height * 0.55);
    path.lineTo(size.width * 0.60, size.height * 0.40);
    path.lineTo(size.width * 0.45, size.height * 0.40);
    path.close();
    canvas.drawPath(path, paintArrow);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PichinchaLogoHeader extends StatelessWidget {
  final double symbolSize;
  final Color textColor;
  final bool showSubtitle;

  const PichinchaLogoHeader({
    super.key,
    this.symbolSize = 65,
    this.textColor = Colors.white,
    this.showSubtitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        PichinchaSymbol(size: symbolSize),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'BANCO',
              style: TextStyle(
                color: textColor,
                fontSize: symbolSize * 0.38,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                height: 1.0,
              ),
            ),
            Text(
              'PICHINCHA',
              style: TextStyle(
                color: textColor,
                fontSize: symbolSize * 0.38,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                height: 1.1,
              ),
            ),
            if (showSubtitle) ...[
              const SizedBox(height: 4),
              Text(
                'Tu otro banco, tu banco para ahorrar',
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.85),
                  fontSize: symbolSize * 0.16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Banca Personal',
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.55),
                  fontSize: symbolSize * 0.16,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
