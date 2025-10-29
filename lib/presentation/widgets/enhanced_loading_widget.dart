/// Enhanced Loading Widget
///
/// A modern, animated loading widget with multiple loading styles
/// and smooth transitions. This provides better user feedback
/// during async operations.
///
/// Features:
/// - Multiple loading animations (skeleton, pulse, shimmer)
/// - Progress indicators
/// - Loading messages
/// - Smooth transitions
/// - Accessibility support
///
/// Example usage:
/// ```dart
/// EnhancedLoadingWidget(
///   type: LoadingType.skeleton,
///   message: 'Loading products...',
///   showProgress: true,
/// )
/// ```

import 'package:flutter/material.dart';
import '../../core/const/constants.dart';

/// Loading animation types
enum LoadingType {
  skeleton,
  pulse,
  shimmer,
  circular,
  linear,
  bouncingDots,
  wave,
}

/// Enhanced loading widget with multiple animation styles
class EnhancedLoadingWidget extends StatefulWidget {
  final LoadingType type;
  final String? message;
  final bool showProgress;
  final double? progress;
  final Color? color;
  final double size;
  final EdgeInsets padding;
  final Duration animationDuration;

  const EnhancedLoadingWidget({
    Key? key,
    this.type = LoadingType.circular,
    this.message,
    this.showProgress = false,
    this.progress,
    this.color,
    this.size = 24.0,
    this.padding = const EdgeInsets.all(16.0),
    this.animationDuration = AppConstants.shortAnimation,
  }) : super(key: key);

  @override
  State<EnhancedLoadingWidget> createState() => _EnhancedLoadingWidgetState();
}

class _EnhancedLoadingWidgetState extends State<EnhancedLoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLoadingAnimation(),
          if (widget.message != null) ...[
            const SizedBox(height: 12.0),
            _buildMessage(),
          ],
          if (widget.showProgress) ...[
            const SizedBox(height: 12.0),
            _buildProgressBar(),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingAnimation() {
    switch (widget.type) {
      case LoadingType.skeleton:
        return _buildSkeletonLoader();
      case LoadingType.pulse:
        return _buildPulseLoader();
      case LoadingType.shimmer:
        return _buildShimmerLoader();
      case LoadingType.circular:
        return _buildCircularLoader();
      case LoadingType.linear:
        return _buildLinearLoader();
      case LoadingType.bouncingDots:
        return _buildBouncingDotsLoader();
      case LoadingType.wave:
        return _buildWaveLoader();
    }
  }

  Widget _buildCircularLoader() {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CircularProgressIndicator(
        strokeWidth: 3.0,
        valueColor: AlwaysStoppedAnimation<Color>(
          widget.color ?? Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildLinearLoader() {
    return SizedBox(
      width: widget.size * 2,
      height: widget.size / 4,
      child: LinearProgressIndicator(
        backgroundColor: Colors.grey.shade300,
        valueColor: AlwaysStoppedAnimation<Color>(
          widget.color ?? Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildPulseLoader() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_animation.value * 0.2),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.color ?? Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkeletonLoader() {
    return Container(
      width: widget.size * 4,
      height: widget.size,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return LinearGradient(
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              stops: [0.0, _animation.value, 1.0],
              begin: Alignment(-1.0, 0.0),
              end: Alignment(1.0, 0.0),
            );
          },
        ),
      ),
    );
  }

  Widget _buildShimmerLoader() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size * 3,
          height: widget.size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            gradient: LinearGradient(
              colors: [
                Colors.grey.shade200,
                Colors.grey.shade400,
                Colors.grey.shade200,
              ],
              stops: [0.0, _animation.value, 1.0],
              begin: Alignment(-1.0 + _animation.value * 2, 0.0),
              end: Alignment(1.0 + _animation.value * 2, 0.0),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBouncingDotsLoader() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final delay = index * 0.2;
            final animValue = (_animation.value + delay) % 1.0;
            final scale = 1.0 + (animValue * 0.5);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: widget.size / 3,
                  height: widget.size / 3,
                  decoration: BoxDecoration(
                    color: widget.color ?? Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildWaveLoader() {
    return SizedBox(
      width: widget.size * 2,
      height: widget.size,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (index) {
          return AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final delay = index * 0.1;
              final animValue = (_animation.value + delay) % 1.0;
              final height = widget.size * (0.3 + animValue * 0.7);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: Container(
                  width: widget.size / 6,
                  height: height,
                  decoration: BoxDecoration(
                    color: widget.color ?? Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildMessage() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: 0.6 + (_animation.value * 0.4),
          child: Text(
            widget.message!,
            style: TextStyle(
              fontSize: UIConstants.fontSizeSmall,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  Widget _buildProgressBar() {
    return LinearProgressIndicator(
      value: widget.progress,
      backgroundColor: Colors.grey.shade300,
      valueColor: AlwaysStoppedAnimation<Color>(
        widget.color ?? Theme.of(context).primaryColor,
      ),
      minHeight: 4.0,
    );
  }
}

/// Specialized loading widgets for specific use cases

/// Product skeleton loader
class ProductSkeletonLoader extends StatelessWidget {
  final int itemCount;

  const ProductSkeletonLoader({
    Key? key,
    this.itemCount = 3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(itemCount, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.paddingMedium,
            vertical: UIConstants.paddingSmall,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image skeleton
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(UIConstants.radiusSmall),
                ),
              ),
              const SizedBox(width: UIConstants.paddingMedium),
              // Product details skeleton
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 16.0,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Container(
                      width: 100.0,
                      height: 14.0,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Container(
                      width: 60.0,
                      height: 12.0,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

/// List skeleton loader
class ListSkeletonLoader extends StatelessWidget {
  final int itemCount;
  final double itemHeight;

  const ListSkeletonLoader({
    Key? key,
    this.itemCount = 5,
    this.itemHeight = 60.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(UIConstants.paddingMedium),
          child: Container(
            height: itemHeight,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(UIConstants.radiusSmall),
            ),
          ),
        );
      },
    );
  }
}

/// Full screen loading overlay
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  final LoadingType loadingType;

  const LoadingOverlay({
    Key? key,
    required this.isLoading,
    required this.child,
    this.message,
    this.loadingType = LoadingType.circular,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Card(
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(UIConstants.radiusLarge),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(UIConstants.paddingLarge),
                    child: EnhancedLoadingWidget(
                      type: loadingType,
                      message: message,
                      size: 32.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}