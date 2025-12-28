import 'package:flutter/material.dart';

/// Custom painter for sparkline visualization.
class SparklinePainter extends CustomPainter {
  final List<double> prices;
  final Color color;

  SparklinePainter({
    required this.prices,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (prices.isEmpty) {
      return;
    }

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Normalize prices to fit within size.height
    final minPrice = prices.reduce((a, b) => a < b ? a : b);
    final maxPrice = prices.reduce((a, b) => a > b ? a : b);
    final priceRange = maxPrice - minPrice;

    if (priceRange == 0) {
      // All prices are the same - draw horizontal line
      final y = size.height / 2;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
      return;
    }

    // Create path
    final path = Path();
    final stepX = size.width / (prices.length - 1);

    for (var i = 0; i < prices.length; i++) {
      final normalizedPrice = (prices[i] - minPrice) / priceRange;
      final y = size.height - (normalizedPrice * size.height);
      final x = i * stepX;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        // Use quadratic bezier for smooth curves
        final prevX = (i - 1) * stepX;
        final prevY = size.height -
            ((prices[i - 1] - minPrice) / priceRange * size.height);
        final controlX = (prevX + x) / 2;
        path.quadraticBezierTo(controlX, prevY, x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(SparklinePainter oldDelegate) {
    return prices != oldDelegate.prices || color != oldDelegate.color;
  }
}

