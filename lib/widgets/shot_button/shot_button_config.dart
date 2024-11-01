// widgets/shot_button/animated_shot_button.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

class ShotButtonConfig {
  final String label;
  final bool isMadeShot;
  final Color primaryColor;
  final Color backgroundColor;
  final double elevation;
  final double borderWidth;
  final EdgeInsets padding;
  final double borderRadius;
  final double fontSize;

  const ShotButtonConfig.made() : this(
    label: 'MADE',
    isMadeShot: true,
    primaryColor: const Color(0xFF4CAF50),//Colors.green,
    backgroundColor: const Color(0xFFA5D6A7),//Colors.green.shade200,
    elevation: 8, // Increased elevation
    borderWidth: 3,
    padding: const EdgeInsets.symmetric(horizontal: PaddingHorizontal, vertical: PaddingVertical),
    borderRadius: 20,
    fontSize: 20, // Increased font size
  );

  static const PaddingHorizontal = 24.0;
  static const PaddingVertical = 12.0;
  const ShotButtonConfig.missed() : this(
    label: 'MISSED',
    isMadeShot: false,
    primaryColor: const Color(0xFFF44336),//Colors.red,
    backgroundColor: const Color(0xFFFF5252),//Colors.redAccent.shade200,
    elevation: 8, // Increased elevation
    borderWidth: 3,
    padding: const EdgeInsets.symmetric(horizontal: PaddingHorizontal, vertical: PaddingVertical),
    borderRadius: 20,
    fontSize: 20, // Increased font size
  );

  const ShotButtonConfig({
    required this.label,
    required this.isMadeShot,
    required this.primaryColor,
    required this.backgroundColor,
    required this.elevation,
    required this.borderWidth,
    required this.padding,
    required this.borderRadius,
    required this.fontSize,
  });

  Widget buildButton({
    required double minHeight,
    required double minWidth,
    required Function(bool) onShotRecorded,
  }) {
    return AnimatedShotButton(
      config: this,
      minHeight: minHeight,
      minWidth: minWidth,
      onShotRecorded: onShotRecorded,
    );
  }
}

class AnimatedShotButton extends StatefulWidget {
  final ShotButtonConfig config;
  final double minHeight;
  final double minWidth;
  final Function(bool) onShotRecorded;

  const AnimatedShotButton({
    required this.config,
    required this.minHeight,
    required this.minWidth,
    required this.onShotRecorded,
  });

  @override
  _AnimatedShotButtonState createState() => _AnimatedShotButtonState();
}

class _AnimatedShotButtonState extends State<AnimatedShotButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _radiusAnimation;
  late Animation<double> _heightAnimation;
  late Animation<double> _widthAnimation;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() async {
    if (!_controller.isAnimating) {
      await _controller.forward(from: 0.0);
      widget.onShotRecorded(widget.config.isMadeShot);
    }
  }
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    // Calculate sphere size - use the larger of width or height
    final double sphereSize = math.max(widget.minWidth * 0.8, widget.minHeight * 0.8);

    // Scale animation
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.8),
        weight: 30.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.8, end: 0.8),
        weight: 40.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.8, end: 1.0),
        weight: 30.0,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.0, 0.8, curve: Curves.easeInOut),
    ));

    // Width animation - from original width to sphere size and back
    _widthAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: widget.minWidth * 1.5, end: sphereSize),
        weight: 30.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: sphereSize, end: sphereSize),
        weight: 40.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: sphereSize, end: widget.minWidth * 1.5),
        weight: 30.0,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.0, 0.8, curve: Curves.easeInOut),
    ));

    // Height animation - from original height to sphere size and back
    _heightAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: widget.minHeight, end: sphereSize),
        weight: 30.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: sphereSize, end: sphereSize),
        weight: 40.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: sphereSize, end: widget.minHeight),
        weight: 30.0,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.0, 0.8, curve: Curves.easeInOut),
    ));

    // Bounce animation
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 30),
        weight: 40.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 30, end: -10),
        weight: 30.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -10, end: 0),
        weight: 30.0,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.2, 1.0, curve: Curves.bounceOut),
    ));

    // Border radius animation - make it match the sphere size
    _radiusAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: widget.config.borderRadius, end: sphereSize / 2),
        weight: 30.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: sphereSize / 2, end: sphereSize / 2),
        weight: 40.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: sphereSize / 2, end: widget.config.borderRadius),
        weight: 30.0,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.0, 0.8, curve: Curves.easeInOut),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bounceAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: _widthAnimation.value,
              height: _heightAnimation.value,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.config.backgroundColor.withOpacity(0.9),
                    widget.config.backgroundColor,
                    widget.config.backgroundColor.withOpacity(0.8),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
                borderRadius: BorderRadius.circular(_radiusAnimation.value),
                boxShadow: [
                  BoxShadow(
                    color: widget.config.primaryColor.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: widget.config.elevation,
                    offset: Offset(0, widget.config.elevation / 2),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: Offset(-2, -2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _handleTap,
                  borderRadius: BorderRadius.circular(_radiusAnimation.value),
                  child: Container(
                    alignment: Alignment.center,
                    padding: widget.config.padding,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: widget.config.primaryColor,
                        width: widget.config.borderWidth,
                      ),
                      borderRadius: BorderRadius.circular(_radiusAnimation.value),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        widget.config.label,
                        style: TextStyle(
                          fontSize: widget.config.fontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

}