/// Rating Display Widget
///
/// A reusable widget that displays star ratings with numeric values.
/// Supports different sizes, colors, and display modes.
///
/// Example usage:
/// ```dart
/// RatingDisplayWidget(
///   rating: 4.5,
///   count: 128,
///   showCount: true,
///   size: RatingDisplaySize.small,
/// )
/// ```

import 'package:flutter/material.dart';
import '../../core/const/constants.dart';

enum RatingDisplaySize {
  small,
  medium,
  large,
}

class RatingDisplayWidget extends StatelessWidget {
  final double rating;
  final int? count;
  final RatingDisplaySize size;
  final Color? starColor;
  final Color? textColor;
  final bool showCount;
  final MainAxisAlignment alignment;

  const RatingDisplayWidget({
    Key? key,
    required this.rating,
    this.count,
    this.size = RatingDisplaySize.small,
    this.starColor,
    this.textColor,
    this.showCount = true,
    this.alignment = MainAxisAlignment.start,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: alignment,
      children: [
        _buildStars(),
        if (showCount) ...[
          UIConstants.horizontalSpaceMini,
          _buildRatingText(),
        ],
      ],
    );
  }

  Widget _buildStars() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) => _buildStar(index)),
    );
  }

  Widget _buildStar(int index) {
    final starValue = index + 1;
    final isFilled = starValue <= rating.floor();
    final isHalfFilled = !isFilled && (rating - index) >= 0.5;

    IconData iconData;
    if (isFilled) {
      iconData = Icons.star;
    } else if (isHalfFilled) {
      iconData = Icons.star_half;
    } else {
      iconData = Icons.star_border;
    }

    return Icon(
      iconData,
      size: _getStarSize(),
      color: starColor ?? Colors.amber[600],
    );
  }

  double _getStarSize() {
    switch (size) {
      case RatingDisplaySize.small:
        return UIConstants.iconSizeSmall;
      case RatingDisplaySize.medium:
        return UIConstants.iconSizeMedium;
      case RatingDisplaySize.large:
        return UIConstants.iconSizeLarge;
    }
  }

  Widget _buildRatingText() {
    final ratingText = count != null
        ? '$rating ($count)'
        : rating.toStringAsFixed(1);

    return Text(
      ratingText,
      style: TextStyle(
        fontSize: _getTextSize(),
        fontWeight: FontWeight.w500,
        color: textColor ?? Colors.grey[700],
      ),
    );
  }

  double _getTextSize() {
    switch (size) {
      case RatingDisplaySize.small:
        return 10;
      case RatingDisplaySize.medium:
        return UIConstants.fontSizeMicro;
      case RatingDisplaySize.large:
        return UIConstants.fontSizeSmall;
    }
  }
}