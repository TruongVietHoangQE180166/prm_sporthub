
import 'package:flutter/material.dart';
import 'dart:math' as math;

class OnboardingAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final Offset beginOffset;
  final Offset endOffset;
  final double beginScale;
  final double endScale;
  final double beginOpacity;
  final double endOpacity;

  const OnboardingAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.delay = Duration.zero,
    this.curve = Curves.easeOutCubic,
    this.beginOffset = const Offset(0, 0.3),
    this.endOffset = Offset.zero,
    this.beginScale = 0.8,
    this.endScale = 1.0,
    this.beginOpacity = 0.0,
    this.endOpacity = 1.0,
  });

  @override
  State<OnboardingAnimation> createState() => _OnboardingAnimationState();
}

class _OnboardingAnimationState extends State<OnboardingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: widget.beginOffset,
      end: widget.endOffset,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _scaleAnimation = Tween<double>(
      begin: widget.beginScale,
      end: widget.endScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _opacityAnimation = Tween<double>(
      begin: widget.beginOpacity,
      end: widget.endOpacity,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    // Start animation after delay
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        var opacityValue = _opacityAnimation.value;
        var scaleValue = _scaleAnimation.value;

        // Clamp animation values first to prevent invalid operations
        opacityValue = opacityValue.clamp(0.0, 1.0);
        scaleValue = scaleValue.clamp(0.0, double.infinity);

        // DEBUG: Log animation values
        print('DEBUG: OnboardingAnimation - opacity: $opacityValue, scale: $scaleValue');

        // Đảm bảo giá trị opacity luôn hợp lệ
        if (opacityValue.isNaN || opacityValue.isInfinite) {
          opacityValue = 0.0;
          print('ERROR: Invalid opacity value (NaN/Infinite), reset to 0.0');
        }

        // Đảm bảo giá trị scale luôn hợp lệ
        if (scaleValue.isNaN || scaleValue.isInfinite || scaleValue < 0.0) {
          scaleValue = 1.0;
          print('ERROR: Invalid scale value, reset to 1.0');
        }

        return Transform.translate(
          offset: _offsetAnimation.value,
          child: Transform.scale(
            scale: scaleValue,
            child: Opacity(
              opacity: opacityValue,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

class FloatingAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double amplitude;
  final Axis direction;

  const FloatingAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 3),
    this.amplitude = 10.0,
    this.direction = Axis.vertical,
  });

  @override
  State<FloatingAnimation> createState() => _FloatingAnimationState();
}

class _FloatingAnimationState extends State<FloatingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final offset = widget.direction == Axis.vertical
            ? Offset(0, math.sin(_animation.value * 2 * math.pi) * widget.amplitude)
            : Offset(math.sin(_animation.value * 2 * math.pi) * widget.amplitude, 0);

        return Transform.translate(
          offset: offset,
          child: widget.child,
        );
      },
    );
  }
}

class PulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;

  const PulseAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 2),
    this.minScale = 0.95,
    this.maxScale = 1.05,
  });

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: widget.child,
        );
      },
    );
  }
}

class StaggeredAnimation extends StatelessWidget {
  final List<Widget> children;
  final Duration staggerDelay;
  final Duration animationDuration;
  final Offset beginOffset;
  final Curve curve;

  const StaggeredAnimation({
    super.key,
    required this.children,
    this.staggerDelay = const Duration(milliseconds: 100),
    this.animationDuration = const Duration(milliseconds: 600),
    this.beginOffset = const Offset(0, 0.3),
    this.curve = Curves.easeOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        
        return OnboardingAnimation(
          delay: Duration(milliseconds: index * staggerDelay.inMilliseconds),
          duration: animationDuration,
          beginOffset: beginOffset,
          curve: curve,
          child: child,
        );
      }).toList(),
    );
  }
}

class SlideInAnimation extends StatelessWidget {
  final Widget child;
  final SlideDirection direction;
  final Duration duration;
  final Duration delay;
  final double distance;

  const SlideInAnimation({
    super.key,
    required this.child,
    this.direction = SlideDirection.left,
    this.duration = const Duration(milliseconds: 600),
    this.delay = Duration.zero,
    this.distance = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    Offset beginOffset;
    switch (direction) {
      case SlideDirection.left:
        beginOffset = Offset(-distance, 0);
        break;
      case SlideDirection.right:
        beginOffset = Offset(distance, 0);
        break;
      case SlideDirection.up:
        beginOffset = Offset(0, distance);
        break;
      case SlideDirection.down:
        beginOffset = Offset(0, -distance);
        break;
    }

    return OnboardingAnimation(
      delay: delay,
      duration: duration,
      beginOffset: beginOffset,
      child: child,
    );
  }
}

enum SlideDirection {
  left,
  right,
  up,
  down,
}

class RotateAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double turns;
  final bool clockwise;

  const RotateAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 2),
    this.turns = 1.0,
    this.clockwise = true,
  });

  @override
  State<RotateAnimation> createState() => _RotateAnimationState();
}

class _RotateAnimationState extends State<RotateAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: 0.0,
      end: widget.clockwise ? widget.turns : -widget.turns,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value * 2 * math.pi,
          child: widget.child,
        );
      },
    );
  }
}