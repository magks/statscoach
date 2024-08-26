import 'package:flutter/material.dart';
import 'package:stats_coach/models/contained_image.dart';

import '../models/shot.dart';

class DummyHeatmapOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: DummyHeatmapPainter(),
    );
  }
}

class DummyHeatmapPainter extends CustomPainter {
  DummyHeatmapPainter();
  @override
  void paint(Canvas canvas, Size size) {
    // Implement a dummy heatmap that does nothing but repaint
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class HeatmapOverlay extends StatelessWidget {
  final List<Shot> shots;
  final ContainedImage cImage;

  const HeatmapOverlay(this.shots, this.cImage);
  //HeatmapOverlay(this.shots, this.cImage, [ContainedImage? cImage]);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: HeatmapPainter(shots, cImage),
    );
  }
}

class HeatmapPainter extends CustomPainter {
  final List<Shot> shots;
  final ContainedImage cImage;

  HeatmapPainter(this.shots, this.cImage);

  @override
  void paint(Canvas canvas, Size size) {
    // Implement a simple heatmap by drawing circles with varying opacity
      Paint bluePaint = Paint()..color = Colors.blue.withOpacity(0.3);
      Rect rect = Rect.fromLTWH(
          cImage.imageLeftOffset,
          cImage.imageTopOffset,
          cImage.displayedWidth,
          cImage.displayedHeight);
      canvas.drawRect(rect, bluePaint);

    Paint redPaint = Paint()..color = Colors.red.withOpacity(0.3);
    for (Shot shot in shots) {
      //double x = ContainedImage.getRelativeX(cImage, shot.xLocation);
      //double y = ContainedImage.getRelativeY(cImage, shot.yLocation);
      double x = cImage.projectXCoordOnImage(shot.xLocation);
      double y = cImage.projectYCoordOnImage(shot.yLocation);
      // Increase opacity or radius based on shot density (this is a simplified example)
      canvas.drawCircle(Offset(x, y), 12.0, redPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
