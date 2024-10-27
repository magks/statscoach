import 'package:flutter/material.dart';

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

  ShotButtonConfig.made() : this(
    label: 'Made',
    isMadeShot: true,
    primaryColor: Colors.green,
    backgroundColor: Colors.green.shade200,
    elevation: 3,
    borderWidth: 3,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    borderRadius: 20,
    fontSize: 18,
  );

  ShotButtonConfig.missed() : this(
    label: 'Missed',
    isMadeShot: false,
    primaryColor: Colors.red,
    backgroundColor: Colors.redAccent.shade200,
    elevation: 3,
    borderWidth: 3,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    borderRadius: 20,
    fontSize: 18,
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
    return ElevatedButton(
      onPressed: () => onShotRecorded(isMadeShot),
      style: ElevatedButton.styleFrom(
        elevation: elevation,
        minimumSize: Size(minWidth, minHeight),
        maximumSize: Size(minWidth, minHeight),
        side: BorderSide(
          color: primaryColor,
          width: borderWidth,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
        foregroundColor: Colors.black,
        backgroundColor: backgroundColor,
        shadowColor: Colors.lightGreen,
        surfaceTintColor: Colors.green,
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
        ),
      ),
    );
  }
}