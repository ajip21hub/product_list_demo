/// Transition Widgets
///
/// A collection of animated transition widgets for smooth
/// UI interactions and state changes.
///
/// Features:
/// - Multiple transition types (fade, slide, scale, rotate)
/// - Staggered animations
/// - Custom easing curves
/// - Accessibility support
/// - Performance optimized
///
/// Example usage:
/// ```dart
/// FadeTransitionWidget(
///   duration: Duration(milliseconds: 300),
///   child: Text('Hello World'),
/// )
/// ```

import 'package:flutter/material.dart';
import '../../core/const/constants.dart';

/// Transition types
enum TransitionType {
  fade,
  slideUp,
  slideDown,
  slideLeft,
  slideRight,
  scale,
  rotate,
  flip,
  shrink,
  expand,
}

/// Base animated transition widget
class AnimatedTransitionWidget extends StatefulWidget {
  final Widget child;
  final TransitionType type;
  final Duration duration;
  final Duration? delay;
  final Curve curve;
  final bool enabled;
  final VoidCallback? onComplete;
  final VoidCallback? onStart;

  const AnimatedTransitionWidget({
    super.key,
    required this.child,
    this.type = TransitionType.fade,
    this.duration = AppConstants.shortAnimation,
    this.delay,
    this.curve = Curves.easeInOut,
    this.enabled = true,
    this.onComplete,
    this.onStart,
  });

  @override
  State<AnimatedTransitionWidget> createState() => _AnimatedTransitionWidgetState();
}

class _AnimatedTransitionWidgetState extends State<AnimatedTransitionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    if (widget.enabled) {
      _startAnimation();
    } else {
      _controller.value = 1.0;
    }
  }

  void _startAnimation() async {
    if (widget.delay != null) {
      await Future.delayed(widget.delay!);
    }

    if (mounted) {
      widget.onStart?.call();
      _controller.forward().then((_) {
        widget.onComplete?.call();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    switch (widget.type) {
      case TransitionType.fade:
        return FadeTransition(
          opacity: _animation,
          child: widget.child,
        );

      case TransitionType.slideUp:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(_animation),
          child: widget.child,
        );

      case TransitionType.slideDown:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, -1.0),
            end: Offset.zero,
          ).animate(_animation),
          child: widget.child,
        );

      case TransitionType.slideLeft:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(_animation),
          child: widget.child,
        );

      case TransitionType.slideRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(_animation),
          child: widget.child,
        );

      case TransitionType.scale:
        return ScaleTransition(
          scale: _animation,
          child: widget.child,
        );

      case TransitionType.rotate:
        return RotationTransition(
          turns: _animation,
          child: widget.child,
        );

      case TransitionType.flip:
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final scale = 1.0 - _animation.value;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(_animation.value * 3.14159),
              child: Transform.scale(
                scale: scale.abs(),
                child: child,
              ),
            );
          },
          child: widget.child,
        );

      case TransitionType.shrink:
        return SizeTransition(
          sizeFactor: _animation,
          child: widget.child,
        );

      case TransitionType.expand:
        return SizeTransition(
          axis: Axis.horizontal,
          sizeFactor: _animation,
          child: widget.child,
        );
    }
  }
}

/// Fade transition widget
class FadeTransitionWidget extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Duration? delay;
  final Curve curve;
  final double begin;
  final double end;
  final VoidCallback? onComplete;

  const FadeTransitionWidget({
    super.key,
    required this.child,
    this.duration = AppConstants.shortAnimation,
    this.delay,
    this.curve = Curves.easeInOut,
    this.begin = 0.0,
    this.end = 1.0,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedTransitionWidget(
      type: TransitionType.fade,
      duration: duration,
      delay: delay,
      curve: curve,
      onComplete: onComplete,
      child: AnimatedOpacity(
        opacity: 1.0,
        duration: duration,
        child: child,
      ),
    );
  }
}

/// Slide transition widget
class SlideTransitionWidget extends StatelessWidget {
  final Widget child;
  final TransitionType direction;
  final Duration duration;
  final Duration? delay;
  final Curve curve;
  final double offset;
  final VoidCallback? onComplete;

  const SlideTransitionWidget({
    super.key,
    required this.child,
    this.direction = TransitionType.slideUp,
    this.duration = AppConstants.shortAnimation,
    this.delay,
    this.curve = Curves.easeInOut,
    this.offset = 1.0,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedTransitionWidget(
      type: direction,
      duration: duration,
      delay: delay,
      curve: curve,
      onComplete: onComplete,
      child: child,
    );
  }
}

/// Scale transition widget
class ScaleTransitionWidget extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Duration? delay;
  final Curve curve;
  final double begin;
  final double end;
  final VoidCallback? onComplete;

  const ScaleTransitionWidget({
    super.key,
    required this.child,
    this.duration = AppConstants.shortAnimation,
    this.delay,
    this.curve = Curves.elasticOut,
    this.begin = 0.0,
    this.end = 1.0,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedTransitionWidget(
      type: TransitionType.scale,
      duration: duration,
      delay: delay,
      curve: curve,
      onComplete: onComplete,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: begin, end: end),
        duration: duration,
        curve: curve,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: child,
          );
        },
        child: child,
      ),
    );
  }
}

/// Staggered animation for list items
class StaggeredListView extends StatelessWidget {
  final List<Widget> children;
  final Duration staggerDelay;
  final Duration itemDuration;
  final TransitionType transitionType;
  final Curve curve;

  const StaggeredListView({
    super.key,
    required this.children,
    this.staggerDelay = const Duration(milliseconds: 100),
    this.itemDuration = AppConstants.shortAnimation,
    this.transitionType = TransitionType.fade,
    this.curve = Curves.easeOut,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;

        return AnimatedTransitionWidget(
          type: transitionType,
          duration: itemDuration,
          delay: Duration(milliseconds: staggerDelay.inMilliseconds * index),
          curve: curve,
          child: child,
        );
      }).toList(),
    );
  }
}

/// Page transition builder for route transitions
class PageTransitionBuilder {
  static Widget buildTransition({
    required BuildContext context,
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required Widget child,
    TransitionType type = TransitionType.slideRight,
  }) {
    switch (type) {
      case TransitionType.fade:
        return FadeTransition(
          opacity: animation,
          child: child,
        );

      case TransitionType.slideRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );

      case TransitionType.slideUp:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );

      case TransitionType.scale:
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
          child: child,
        );

      default:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );
    }
  }

  static PageRoute<T> buildRoute<T>({
    required Widget page,
    TransitionType type = TransitionType.slideRight,
    Duration duration = AppConstants.shortAnimation,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return buildTransition(
          context: context,
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
          type: type,
        );
      },
    );
  }
}

/// Animated container that changes between states
class MorphingContainer extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Decoration? decoration;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;

  const MorphingContainer({
    super.key,
    required this.child,
    this.duration = AppConstants.shortAnimation,
    this.curve = Curves.easeInOut,
    this.decoration,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.constraints,
  });

  @override
  State<MorphingContainer> createState() => _MorphingContainerState();
}

class _MorphingContainerState extends State<MorphingContainer> {
  Decoration? _currentDecoration;
  EdgeInsetsGeometry? _currentPadding;
  EdgeInsetsGeometry? _currentMargin;
  double? _currentWidth;
  double? _currentHeight;
  BoxConstraints? _currentConstraints;

  @override
  void initState() {
    super.initState();
    _currentDecoration = widget.decoration;
    _currentPadding = widget.padding;
    _currentMargin = widget.margin;
    _currentWidth = widget.width;
    _currentHeight = widget.height;
    _currentConstraints = widget.constraints;
  }

  @override
  void didUpdateWidget(MorphingContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _currentDecoration = widget.decoration;
    _currentPadding = widget.padding;
    _currentMargin = widget.margin;
    _currentWidth = widget.width;
    _currentHeight = widget.height;
    _currentConstraints = widget.constraints;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: widget.duration,
      curve: widget.curve,
      decoration: _currentDecoration,
      padding: _currentPadding,
      margin: _currentMargin,
      width: _currentWidth,
      height: _currentHeight,
      constraints: _currentConstraints,
      child: widget.child,
    );
  }
}

/// Animated switcher that provides smooth transitions between widgets
class SmoothAnimatedSwitcher extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final TransitionType transitionType;

  const SmoothAnimatedSwitcher({
    super.key,
    required this.child,
    this.duration = AppConstants.shortAnimation,
    this.curve = Curves.easeInOut,
    this.transitionType = TransitionType.fade,
  });

  @override
  Widget build(BuildContext context) {
    Widget buildTransition(Widget child) {
      switch (transitionType) {
        case TransitionType.fade:
          return FadeTransition(
            opacity: const AlwaysStoppedAnimation(1.0),
            child: child,
          );

        case TransitionType.scale:
          return ScaleTransition(
            scale: const AlwaysStoppedAnimation(1.0),
            child: child,
          );

        default:
          return child;
      }
    }

    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: (child, animation) {
        switch (transitionType) {
          case TransitionType.fade:
            return FadeTransition(
              opacity: animation,
              child: child,
            );

          case TransitionType.scale:
            return ScaleTransition(
              scale: animation,
              child: child,
            );

          case TransitionType.slideUp:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.25),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: curve,
              )),
              child: child,
            );

          default:
            return FadeTransition(
              opacity: animation,
              child: child,
            );
        }
      },
      child: child,
    );
  }
}