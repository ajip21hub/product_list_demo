/// Badge Count Widget
///
/// A reusable widget that displays a count badge over an icon or other widget.
/// Commonly used for cart items, wishlist items, notifications, etc.
///
/// Example usage:
/// ```dart
/// BadgeCountWidget(
///   count: 5,
///   child: Icon(Icons.shopping_cart),
/// )
/// ```

import 'package:flutter/material.dart';

class BadgeCountWidget extends StatelessWidget {
  final int count;
  final Widget child;
  final Color? badgeColor;
  final Color? textColor;
  final double? badgeSize;
  final bool showBadge;
  final String? badgeLabel;
  final EdgeInsets? badgePadding;

  const BadgeCountWidget({
    Key? key,
    required this.count,
    required this.child,
    this.badgeColor,
    this.textColor,
    this.badgeSize,
    this.showBadge = true,
    this.badgeLabel,
    this.badgePadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (showBadge && count > 0) _buildBadge(),
      ],
    );
  }

  Widget _buildBadge() {
    return Positioned(
      top: -8,
      right: -8,
      child: Container(
        padding: badgePadding ?? const EdgeInsets.symmetric(
          horizontal: 6,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: badgeColor ?? Colors.red,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        constraints: BoxConstraints(
          minWidth: badgeSize ?? 20,
          minHeight: badgeSize ?? 20,
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              badgeLabel ?? _formatCount(count),
              style: TextStyle(
                color: textColor ?? Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count <= 99) return count.toString();
    if (count <= 999) return '99+';
    return '1k+';
  }
}