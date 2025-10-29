/// Enhanced State Widgets
///
/// A collection of modern state management widgets that provide
/// better user feedback for loading, error, and empty states
/// with smooth transitions and animations.
///
/// Features:
/// - Multiple loading animations
/// - Contextual error messages
/// - Empty state illustrations
/// - Smooth transitions
/// - Accessibility support
/// - Customizable styling
///
/// Example usage:
/// ```dart
/// EnhancedStateWidget(
///   state: StateView.loading,
///   child: _buildContent(),
///   onRetry: () => _loadData(),
/// )
/// ```

import 'package:flutter/material.dart';
import 'enhanced_loading_widget.dart';
import 'enhanced_error_widget.dart';
import 'transition_widgets.dart';
import '../../core/const/constants.dart';

/// State view types for different content states
enum StateView {
  loading,
  error,
  empty,
  content,
}

/// Enhanced state widget that handles all content states
class EnhancedStateWidget extends StatelessWidget {
  final StateView state;
  final Widget? child;
  final String? loadingMessage;
  final String? errorMessage;
  final ErrorInfo? errorInfo;
  final String? emptyMessage;
  final String? emptySubtext;
  final VoidCallback? onRetry;
  final bool showRetryButton;
  final Widget? emptyIcon;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final bool enableTransitions;
  final Duration transitionDuration;

  const EnhancedStateWidget({
    super.key,
    required this.state,
    this.child,
    this.loadingMessage,
    this.errorMessage,
    this.errorInfo,
    this.emptyMessage,
    this.emptySubtext,
    this.onRetry,
    this.showRetryButton = true,
    this.emptyIcon,
    this.loadingWidget,
    this.errorWidget,
    this.enableTransitions = true,
    this.transitionDuration = AppConstants.shortAnimation,
  });

  @override
  Widget build(BuildContext context) {
    if (enableTransitions) {
      return SmoothAnimatedSwitcher(
        duration: transitionDuration,
        child: _buildStateContent(),
      );
    } else {
      return _buildStateContent();
    }
  }

  Widget _buildStateContent() {
    switch (state) {
      case StateView.loading:
        return loadingWidget ?? _buildLoadingState();
      case StateView.error:
        return errorWidget ?? _buildErrorState();
      case StateView.empty:
        return _buildEmptyState();
      case StateView.content:
        return child ?? const SizedBox.shrink();
    }
  }

  Widget _buildLoadingState() {
    return loadingWidget ??
      EnhancedLoadingWidget(
        type: LoadingType.bouncingDots,
        message: loadingMessage ?? 'Loading...',
        size: 32.0,
      );
  }

  Widget _buildErrorState() {
    if (errorInfo != null) {
      return ContextualErrorWidget(
        errorInfo: errorInfo!,
        onRetry: onRetry,
      );
    }

    return EnhancedErrorWidget(
      errorInfo: errorInfo ?? ErrorInfo(
        title: 'Oops! Something went wrong',
        message: errorMessage ?? 'An unexpected error occurred. Please try again.',
        userMessage: errorMessage ?? 'An unexpected error occurred. Please try again.',
        type: ErrorType.unknown,
        suggestions: [
          'Check your internet connection',
          'Try refreshing the page',
          'Contact support if the problem persists',
        ],
      ),
      onRetry: onRetry,
      style: ErrorDisplayStyle.actionable,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Empty state icon or illustration
            if (emptyIcon != null)
              emptyIcon!
            else
              Container(
                width: 120.0,
                height: 120.0,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.inbox_outlined,
                  size: 60.0,
                  color: Colors.grey.shade400,
                ),
              ),
            const SizedBox(height: UIConstants.paddingLarge),

            // Empty state message
            Text(
              emptyMessage ?? 'No items found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

            // Empty state subtext
            if (emptySubtext != null) ...[
              const SizedBox(height: UIConstants.paddingSmall),
              Text(
                emptySubtext!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // Retry button if available
            if (showRetryButton && onRetry != null) ...[
              const SizedBox(height: UIConstants.paddingLarge),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: UIConstants.paddingLarge,
                    vertical: UIConstants.paddingMedium,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Product-specific enhanced state widget
class ProductStateWidget extends StatelessWidget {
  final StateView state;
  final Widget? child;
  final VoidCallback? onRetry;
  final String? customEmptyMessage;
  final bool enableTransitions;

  const ProductStateWidget({
    super.key,
    required this.state,
    this.child,
    this.onRetry,
    this.customEmptyMessage,
    this.enableTransitions = true,
  });

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case StateView.loading:
        return EnhancedStateWidget(
          state: StateView.loading,
          loadingMessage: 'Finding products...',
          loadingWidget: ProductSkeletonLoader(itemCount: 3),
          enableTransitions: enableTransitions,
        );

      case StateView.error:
        return EnhancedStateWidget(
          state: StateView.error,
          errorInfo: ErrorInfo(
            title: 'Product Error',
            message: 'We couldn\'t load the products. Please check your connection and try again.',
            userMessage: 'Couldn\'t load products. Please try again.',
            type: ErrorType.network,
            suggestions: [
              'Check your internet connection',
              'Pull down to refresh',
              'Try again later',
            ],
          ),
          onRetry: onRetry,
          enableTransitions: enableTransitions,
        );

      case StateView.empty:
        return EnhancedStateWidget(
          state: StateView.empty,
          emptyMessage: customEmptyMessage ?? 'No products found',
          emptySubtext: 'We couldn\'t find any products matching your criteria. Try adjusting your filters or search terms.',
          emptyIcon: Container(
            width: 120.0,
            height: 120.0,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 60.0,
              color: Colors.grey.shade400,
            ),
          ),
          onRetry: onRetry,
          enableTransitions: enableTransitions,
        );

      case StateView.content:
        return child ?? const SizedBox.shrink();
    }
  }
}

/// List-specific enhanced state widget
class ListStateWidget extends StatelessWidget {
  final StateView state;
  final Widget? child;
  final VoidCallback? onRetry;
  final String? emptyMessage;
  final String? emptySubtext;
  final IconData? emptyIcon;
  final bool enableTransitions;

  const ListStateWidget({
    super.key,
    required this.state,
    this.child,
    this.onRetry,
    this.emptyMessage,
    this.emptySubtext,
    this.emptyIcon,
    this.enableTransitions = true,
  });

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case StateView.loading:
        return EnhancedStateWidget(
          state: StateView.loading,
          loadingMessage: 'Loading items...',
          loadingWidget: ListSkeletonLoader(itemCount: 5),
          enableTransitions: enableTransitions,
        );

      case StateView.error:
        return EnhancedStateWidget(
          state: StateView.error,
          errorInfo: ErrorInfo(
            title: 'List Error',
            message: 'We couldn\'t load the list items. Please try again.',
            userMessage: 'Couldn\'t load items. Please try again.',
            type: ErrorType.data,
            suggestions: [
              'Pull down to refresh',
              'Check your connection',
              'Try again later',
            ],
          ),
          onRetry: onRetry,
          enableTransitions: enableTransitions,
        );

      case StateView.empty:
        return EnhancedStateWidget(
          state: StateView.empty,
          emptyMessage: emptyMessage ?? 'No items found',
          emptySubtext: emptySubtext ?? 'This list is currently empty.',
          emptyIcon: emptyIcon != null
            ? Icon(emptyIcon, size: 60.0, color: Colors.grey.shade400)
            : null,
          onRetry: onRetry,
          enableTransitions: enableTransitions,
        );

      case StateView.content:
        return child ?? const SizedBox.shrink();
    }
  }
}

/// Search-specific enhanced state widget
class SearchStateWidget extends StatelessWidget {
  final StateView state;
  final Widget? child;
  final String? searchQuery;
  final VoidCallback? onRetry;
  final bool enableTransitions;

  const SearchStateWidget({
    super.key,
    required this.state,
    this.child,
    this.searchQuery,
    this.onRetry,
    this.enableTransitions = true,
  });

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case StateView.loading:
        return EnhancedStateWidget(
          state: StateView.loading,
          loadingMessage: 'Searching...',
          loadingWidget: const Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: UIConstants.paddingMedium),
              Text('Searching for items...'),
            ],
          ),
          enableTransitions: enableTransitions,
        );

      case StateView.error:
        return EnhancedStateWidget(
          state: StateView.error,
          errorInfo: ErrorInfo(
            title: 'Search Error',
            message: 'We couldn\'t complete your search. Please try again.',
            userMessage: 'Search failed. Please try again.',
            type: ErrorType.data,
            suggestions: [
              'Check your search terms',
              'Check your connection',
              'Try again later',
            ],
          ),
          onRetry: onRetry,
          enableTransitions: enableTransitions,
        );

      case StateView.empty:
        return EnhancedStateWidget(
          state: StateView.empty,
          emptyMessage: 'No results found',
          emptySubtext: searchQuery != null
            ? 'We couldn\'t find any results for "$searchQuery".'
            : 'Try different search terms or filters.',
          emptyIcon: Icon(
            Icons.search_off_outlined,
            size: 60.0,
            color: Colors.grey.shade400,
          ),
          onRetry: onRetry,
          enableTransitions: enableTransitions,
        );

      case StateView.content:
        return child ?? const SizedBox.shrink();
    }
  }
}

/// Pagination state widget for handling paginated content
class PaginationStateWidget extends StatelessWidget {
  final StateView state;
  final Widget? child;
  final VoidCallback? onLoadMore;
  final bool hasMoreData;
  final bool isLoadingMore;
  final String? emptyMessage;
  final bool enableTransitions;

  const PaginationStateWidget({
    super.key,
    required this.state,
    this.child,
    this.onLoadMore,
    this.hasMoreData = false,
    this.isLoadingMore = false,
    this.emptyMessage,
    this.enableTransitions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main content
        Expanded(
          child: EnhancedStateWidget(
            state: state,
            child: child,
            emptyMessage: emptyMessage,
            enableTransitions: enableTransitions,
          ),
        ),

        // Load more indicator
        if (hasMoreData || isLoadingMore)
          Container(
            padding: const EdgeInsets.all(UIConstants.paddingMedium),
            child: isLoadingMore
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: UIConstants.paddingSmall),
                    Text('Loading more...'),
                  ],
                )
              : hasMoreData
                ? ElevatedButton.icon(
                    onPressed: onLoadMore,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    label: const Text('Load More'),
                  )
                : const SizedBox.shrink(),
          ),
      ],
    );
  }
}

/// Animated state transition widget with custom transitions
class AnimatedStateTransition extends StatefulWidget {
  final StateView state;
  final Widget child;
  final Duration duration;

  const AnimatedStateTransition({
    super.key,
    required this.state,
    required this.child,
    this.duration = AppConstants.shortAnimation,
  });

  @override
  State<AnimatedStateTransition> createState() => _AnimatedStateTransitionState();
}

class _AnimatedStateTransitionState extends State<AnimatedStateTransition> {
  @override
  Widget build(BuildContext context) {
    switch (widget.state) {
      case StateView.loading:
        return FadeTransitionWidget(
          duration: widget.duration,
          child: child,
        );

      case StateView.error:
        return SlideTransitionWidget(
          direction: TransitionType.slideDown,
          duration: widget.duration,
          child: child,
        );

      case StateView.empty:
        return ScaleTransitionWidget(
          duration: widget.duration,
          begin: 0.8,
          end: 1.0,
          child: child,
        );

      case StateView.content:
        return FadeTransitionWidget(
          duration: widget.duration,
          child: child,
        );
    }
  }
}