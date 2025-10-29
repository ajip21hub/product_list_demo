/// Enhanced Error Widget
///
/// A modern, user-friendly error display widget with multiple
/// error styles, actions, and recovery options.
///
/// Features:
/// - Multiple error display styles
/// - Retry mechanisms
/// - Error actions (contact support, report issue)
/// - Animated transitions
/// - Accessibility support
/// - Contextual error messaging
///
/// Example usage:
/// ```dart
/// EnhancedErrorWidget(
///   errorInfo: errorInfo,
///   onRetry: () => _loadData(),
///   showSupportAction: true,
/// )
/// ```

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/const/constants.dart';
import '../../core/services/error_handler.dart';

/// Error display styles
enum ErrorDisplayStyle {
  minimal,      // Simple error message
  detailed,     // Full error details
  actionable,   // Error with actions
  card,         // Card-style error display
  banner,       // Banner-style error display
}

/// Enhanced error widget with multiple display styles and actions
class EnhancedErrorWidget extends StatelessWidget {
  final ErrorInfo errorInfo;
  final ErrorDisplayStyle style;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final bool showSupportAction;
  final bool showReportAction;
  final String? customRetryText;
  final EdgeInsets? padding;
  final IconData? icon;

  const EnhancedErrorWidget({
    Key? key,
    required this.errorInfo,
    this.style = ErrorDisplayStyle.actionable,
    this.onRetry,
    this.onDismiss,
    this.showSupportAction = true,
    this.showReportAction = false,
    this.customRetryText,
    this.padding,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? _getDefaultPadding();

    switch (style) {
      case ErrorDisplayStyle.minimal:
        return _buildMinimalError(context, effectivePadding);
      case ErrorDisplayStyle.detailed:
        return _buildDetailedError(context, effectivePadding);
      case ErrorDisplayStyle.actionable:
        return _buildActionableError(context, effectivePadding);
      case ErrorDisplayStyle.card:
        return _buildCardError(context, effectivePadding);
      case ErrorDisplayStyle.banner:
        return _buildBannerError(context, effectivePadding);
    }
  }

  EdgeInsets _getDefaultPadding() {
    switch (style) {
      case ErrorDisplayStyle.minimal:
        return const EdgeInsets.symmetric(
          horizontal: UIConstants.paddingMedium,
          vertical: UIConstants.paddingSmall,
        );
      case ErrorDisplayStyle.detailed:
      case ErrorDisplayStyle.actionable:
        return const EdgeInsets.all(UIConstants.paddingLarge);
      case ErrorDisplayStyle.card:
        return const EdgeInsets.all(UIConstants.paddingMedium);
      case ErrorDisplayStyle.banner:
        return const EdgeInsets.symmetric(
          horizontal: UIConstants.paddingMedium,
          vertical: UIConstants.paddingSmall,
        );
    }
  }

  Widget _buildMinimalError(BuildContext context, EdgeInsets padding) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Icon(
            icon ?? _getErrorIcon(),
            color: _getErrorColor(),
            size: 20.0,
          ),
          const SizedBox(width: UIConstants.paddingSmall),
          Expanded(
            child: Text(
              errorInfo.userMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: _getErrorColor(),
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: Text(customRetryText ?? 'Retry'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailedError(BuildContext context, EdgeInsets padding) {
    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon ?? _getErrorIcon(),
                color: _getErrorColor(),
                size: 24.0,
              ),
              const SizedBox(width: UIConstants.paddingSmall),
              Expanded(
                child: Text(
                  errorInfo.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: _getErrorColor(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: UIConstants.paddingMedium),
          Text(
            errorInfo.userMessage,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (errorInfo.suggestions.isNotEmpty) ...[
            const SizedBox(height: UIConstants.paddingMedium),
            Text(
              'Suggestions:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: UIConstants.paddingSmall),
            ...errorInfo.suggestions.map(
              (suggestion) => Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(
                        suggestion,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (onRetry != null || showSupportAction || showReportAction) ...[
            const SizedBox(height: UIConstants.paddingLarge),
            _buildActionButtons(context),
          ],
        ],
      ),
    );
  }

  Widget _buildActionableError(BuildContext context, EdgeInsets padding) {
    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon ?? _getErrorIcon(),
            color: _getErrorColor(),
            size: 48.0,
          ),
          const SizedBox(height: UIConstants.paddingMedium),
          Text(
            errorInfo.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: _getErrorColor(),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: UIConstants.paddingSmall),
          Text(
            errorInfo.userMessage,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          if (errorInfo.suggestions.isNotEmpty) ...[
            const SizedBox(height: UIConstants.paddingMedium),
            ...errorInfo.suggestions.take(2).map(
              (suggestion) => Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  '💡 $suggestion',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
          const SizedBox(height: UIConstants.paddingLarge),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildCardError(BuildContext context, EdgeInsets padding) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIConstants.radiusLarge),
        side: BorderSide(color: _getErrorColor().withOpacity(0.3)),
      ),
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: _getErrorColor().withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon ?? _getErrorIcon(),
                    color: _getErrorColor(),
                    size: 24.0,
                  ),
                ),
                const SizedBox(width: UIConstants.paddingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        errorInfo.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        errorInfo.userMessage,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (onRetry != null) ...[
              const SizedBox(height: UIConstants.paddingMedium),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: Text(customRetryText ?? 'Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getErrorColor(),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBannerError(BuildContext context, EdgeInsets padding) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: _getErrorColor().withOpacity(0.1),
        border: Border.all(color: _getErrorColor().withOpacity(0.3)),
        borderRadius: BorderRadius.circular(UIConstants.radiusMedium),
      ),
      child: Row(
        children: [
          Icon(
            icon ?? _getErrorIcon(),
            color: _getErrorColor(),
            size: 20.0,
          ),
          const SizedBox(width: UIConstants.paddingSmall),
          Expanded(
            child: Text(
              errorInfo.userMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: _getErrorColor(),
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: Text(customRetryText ?? 'Retry'),
              style: TextButton.styleFrom(
                foregroundColor: _getErrorColor(),
              ),
            ),
          if (onDismiss != null)
            IconButton(
              onPressed: onDismiss,
              icon: const Icon(Icons.close, size: 18.0),
              color: _getErrorColor(),
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final buttons = <Widget>[];

    if (onRetry != null) {
      buttons.add(
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: Text(customRetryText ?? 'Try Again'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _getErrorColor(),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: UIConstants.paddingLarge,
              vertical: UIConstants.paddingMedium,
            ),
          ),
        ),
      );
    }

    if (showSupportAction) {
      buttons.add(
        OutlinedButton.icon(
          onPressed: () => _contactSupport(context),
          icon: const Icon(Icons.support_agent),
          label: const Text('Contact Support'),
        ),
      );
    }

    if (showReportAction) {
      buttons.add(
        TextButton.icon(
          onPressed: () => _reportIssue(context),
          icon: const Icon(Icons.bug_report),
          label: const Text('Report Issue'),
        ),
      );
    }

    if (buttons.length == 1) {
      return buttons.first;
    } else if (buttons.length == 2) {
      return Row(
        children: buttons.map((button) {
          return Expanded(child: button);
        }).toList(),
      );
    } else {
      return Column(
        children: buttons.map((button) {
          return Padding(
            padding: const EdgeInsets.only(bottom: UIConstants.paddingSmall),
            child: SizedBox(width: double.infinity, child: button),
          );
        }).toList(),
      );
    }
  }

  IconData _getErrorIcon() {
    switch (errorInfo.type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.authentication:
        return Icons.lock;
      case ErrorType.validation:
        return Icons.error_outline;
      case ErrorType.data:
        return Icons.data_array;
      case ErrorType.cache:
        return Icons.cached;
      case ErrorType.businessLogic:
        return Icons.block;
      case ErrorType.configuration:
        return Icons.settings;
      case ErrorType.unknown:
      default:
        return Icons.error;
    }
  }

  Color _getErrorColor() {
    switch (errorInfo.type) {
      case ErrorType.network:
        return Colors.orange;
      case ErrorType.authentication:
        return Colors.red;
      case ErrorType.validation:
        return Colors.amber;
      case ErrorType.data:
        return Colors.blue;
      case ErrorType.cache:
        return Colors.grey;
      case ErrorType.businessLogic:
        return Colors.purple;
      case ErrorType.configuration:
        return Colors.teal;
      case ErrorType.unknown:
      default:
        return Colors.red;
    }
  }

  void _contactSupport(BuildContext context) {
    // In a real app, this would open support chat, email, or help center
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Support feature coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _reportIssue(BuildContext context) async {
    final emailUri = Uri(
      scheme: 'mailto',
      path: 'support@example.com',
      query: 'subject=Bug Report - ${errorInfo.title}&body=${Uri.encodeComponent(
        'Error Details:\n\n'
        'Title: ${errorInfo.title}\n'
        'Message: ${errorInfo.userMessage}\n'
        'Type: ${errorInfo.type}\n'
        'Code: ${errorInfo.code ?? "N/A"}\n'
        'Timestamp: ${DateTime.now()}\n\n'
        'Additional Information:\n'
        '[Please describe what you were doing when this error occurred]',
      )}',
    );

    try {
      await launchUrl(emailUri);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open email app'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

/// Error widget that shows different content based on error type
class ContextualErrorWidget extends StatelessWidget {
  final ErrorInfo errorInfo;
  final VoidCallback? onRetry;
  final bool showDismissButton;

  const ContextualErrorWidget({
    Key? key,
    required this.errorInfo,
    this.onRetry,
    this.showDismissButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (errorInfo.type) {
      case ErrorType.network:
        return EnhancedErrorWidget(
          errorInfo: errorInfo,
          style: ErrorDisplayStyle.actionable,
          onRetry: onRetry,
          customRetryText: 'Retry Connection',
          icon: Icons.wifi_off,
        );

      case ErrorType.authentication:
        return EnhancedErrorWidget(
          errorInfo: errorInfo,
          style: ErrorDisplayStyle.card,
          onRetry: onRetry,
          customRetryText: 'Log In Again',
          icon: Icons.lock,
        );

      case ErrorType.validation:
        return EnhancedErrorWidget(
          errorInfo: errorInfo,
          style: ErrorDisplayStyle.banner,
          showSupportAction: false,
          onDismiss: () => Navigator.of(context).pop(),
          icon: Icons.error_outline,
        );

      default:
        return EnhancedErrorWidget(
          errorInfo: errorInfo,
          style: ErrorDisplayStyle.actionable,
          onRetry: onRetry,
          showSupportAction: true,
          showReportAction: true,
        );
    }
  }
}