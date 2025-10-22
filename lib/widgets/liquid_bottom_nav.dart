import 'package:flutter/material.dart';

class LiquidBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<LiquidBottomNavigationBarItem> items;
  final Color liquidColor;
  final Color backgroundColor;
  final double borderRadius;

  const LiquidBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.liquidColor = Colors.blue,
    this.backgroundColor = Colors.white,
    this.borderRadius = 20.0,
  });

  @override
  State<LiquidBottomNavigationBar> createState() => _LiquidBottomNavigationBarState();
}

class _LiquidBottomNavigationBarState extends State<LiquidBottomNavigationBar>
    with TickerProviderStateMixin {
  late AnimationController _liquidController;
  late Animation<double> _liquidAnimation;

  @override
  void initState() {
    super.initState();
    _liquidController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _liquidAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _liquidController,
        curve: Curves.elasticOut,
      ),
    );
    _liquidController.forward();
  }

  @override
  void didUpdateWidget(LiquidBottomNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _liquidController.reset();
      _liquidController.forward();
    }
  }

  @override
  void dispose() {
    _liquidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(widget.borderRadius),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: CustomPaint(
        painter: LiquidPainter(
          currentIndex: widget.currentIndex,
          itemCount: widget.items.length,
          liquidAnimation: _liquidAnimation.value,
          liquidColor: widget.liquidColor,
        ),
        child: Row(
          children: widget.items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isSelected = index == widget.currentIndex;

            return Expanded(
              child: GestureDetector(
                onTap: () => widget.onTap(index),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        transform: Matrix4.diagonal3Values(
                          isSelected ? 1.2 : 1.0,
                          isSelected ? 1.2 : 1.0,
                          1.0,
                        ),
                        child: Icon(
                          item.icon,
                          color: isSelected ? Colors.white : Colors.grey[600],
                          size: isSelected ? 28 : 24,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          item.label,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[600],
                            fontSize: isSelected ? 13 : 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class LiquidPainter extends CustomPainter {
  final int currentIndex;
  final int itemCount;
  final double liquidAnimation;
  final Color liquidColor;

  LiquidPainter({
    required this.currentIndex,
    required this.itemCount,
    required this.liquidAnimation,
    required this.liquidColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final itemWidth = size.width / itemCount;
    final centerX = (currentIndex + 0.5) * itemWidth;
    final centerY = size.height * 0.3;

    // Create liquid paint with gradient
    final liquidPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          liquidColor.withValues(alpha: 0.8),
          liquidColor.withValues(alpha: 0.6),
          liquidColor.withValues(alpha: 0.4),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // Draw liquid shape with organic form
    final path = Path();
    final liquidHeight = 60.0 * liquidAnimation;
    final liquidWidth = itemWidth * 0.8 * liquidAnimation;

    // Create organic liquid shape
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: liquidWidth,
        height: liquidHeight,
      ),
      const Radius.circular(30),
    ));

    // Add liquid bubbles for more organic effect
    if (liquidAnimation > 0.5) {
      final bubblePaint = Paint()
        ..color = liquidColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;

      // Draw bubbles around the main liquid shape
      final bubbleOffset = liquidAnimation - 0.5;
      _drawBubble(canvas, bubblePaint, centerX - liquidWidth * 0.3, centerY - 10, 8 + bubbleOffset * 4);
      _drawBubble(canvas, bubblePaint, centerX + liquidWidth * 0.3, centerY + 5, 6 + bubbleOffset * 3);
      _drawBubble(canvas, bubblePaint, centerX, centerY - 20, 5 + bubbleOffset * 2);
    }

    canvas.drawPath(path, liquidPaint);
  }

  void _drawBubble(Canvas canvas, Paint paint, double x, double y, double radius) {
    canvas.drawCircle(Offset(x, y), radius, paint);
  }

  @override
  bool shouldRepaint(covariant LiquidPainter oldDelegate) {
    return oldDelegate.currentIndex != currentIndex ||
           oldDelegate.liquidAnimation != liquidAnimation;
  }
}

class LiquidBottomNavigationBarItem {
  final IconData icon;
  final String label;

  const LiquidBottomNavigationBarItem({
    required this.icon,
    required this.label,
  });
}