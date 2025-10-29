/// State Widgets
///
/// A collection of reusable widgets for displaying different states:
/// Loading, Error, and Empty states with consistent design across the app.
///
/// Example usage:
/// ```dart
/// LoadingStateWidget(message: 'Loading products...')
/// ErrorStateWidget(
///   message: 'Failed to load products',
///   onRetry: () => loadProducts(),
/// )
/// EmptyStateWidget(
///   message: 'No products found',
///   icon: Icons.shopping_bag_outlined,
/// )
/// ```

import 'package:flutter/material.dart';
import '../../core/const/constants.dart';

class LoadingStateWidget extends StatelessWidget {
  final String? message;
  final double? size;
  final Color? color;

  const LoadingStateWidget({
    super.key,
    this.message,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLoadingIndicator(),
          if (message != null) ...[
            UIConstants.verticalSpaceLarge,
            _buildMessage(),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: size ?? 40,
      height: size ?? 40,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? Colors.blue,
        ),
      ),
    );
  }

  Widget _buildMessage() {
    return Text(
      message!,
      style: TextStyle(
        fontSize: UIConstants.fontSizeMedium,
        color: Colors.grey[600],
      ),
      textAlign: TextAlign.center,
    );
  }
}

class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;
  final String? retryText;

  const ErrorStateWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon,
    this.retryText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: UIConstants.paddingXLarge,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(),
            UIConstants.verticalSpaceLarge,
            _buildErrorMessage(),
            if (onRetry != null) ...[
              UIConstants.verticalSpaceXLarge,
              _buildRetryButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Icon(
      icon ?? Icons.error_outline,
      size: 64,
      color: Colors.red[400],
    );
  }

  Widget _buildErrorMessage() {
    return Text(
      message,
      style: TextStyle(
        fontSize: UIConstants.fontSizeMedium,
        color: Colors.grey[700],
        height: UIConstants.lineHeightNormal,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildRetryButton() {
    return ElevatedButton.icon(
      onPressed: onRetry,
      icon: const Icon(Icons.refresh),
      label: Text(retryText ?? 'Try Again'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: UIConstants.spacingLarge,
          vertical: UIConstants.spacingMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.radiusLarge),
        ),
      ),
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final IconData? icon;
  final Widget? action;
  final String? subtitle;

  const EmptyStateWidget({
    super.key,
    required this.message,
    this.icon,
    this.action,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: UIConstants.paddingXLarge,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(),
            UIConstants.verticalSpaceLarge,
            _buildTitle(),
            if (subtitle != null) ...[
              UIConstants.verticalSpaceSmall,
              _buildSubtitle(),
            ],
            if (action != null) ...[
              UIConstants.verticalSpaceXLarge,
              action!,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Icon(
      icon ?? Icons.inbox_outlined,
      size: 80,
      color: Colors.grey[400],
    );
  }

  Widget _buildTitle() {
    return Text(
      message,
      style: TextStyle(
        fontSize: UIConstants.fontSizeLarge,
        fontWeight: FontWeight.w600,
        color: Colors.grey[700],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle() {
    return Text(
      subtitle!,
      style: TextStyle(
        fontSize: UIConstants.fontSizeSmall,
        color: Colors.grey[600],
        height: UIConstants.lineHeightNormal,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class ShimmerLoadingWidget extends StatelessWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerLoadingWidget({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppConstants.mediumAnimation,
      child: child,
    );
  }
}

// Extension to get context in stateless widgets
extension Get on StatelessWidget {
  static BuildContext? _context;

  static BuildContext get context {
    if (_context == null) {
      throw Exception('Context not available. Call Get.setContext(context) first.');
    }
    return _context!;
  }

  static void setContext(BuildContext context) {
    _context = context;
  }
}