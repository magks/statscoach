import 'package:flutter/material.dart';

class ContainedImage {
  final double containerWidth;
  final double containerHeight;
  final double imageWidth;
  final double imageHeight;
  final double imageLeftOffset;
  final double imageTopOffset;
  final double displayedWidth;
  final double displayedHeight;
  final double imageAspectRatio;

  factory ContainedImage(
    double containerWidth,
    double containerHeight,
    double imageWidth,
    double imageHeight)
  {
    final double imageAspectRatio = imageWidth / imageHeight;
    // Determine whether to fit the image based on height or width
    final double containerAspectRatio = containerWidth / containerHeight ;
    final bool fitHeight = containerAspectRatio > imageAspectRatio;
    final double displayedWidth = fitHeight ? containerHeight * imageAspectRatio : containerWidth;
    final double displayedHeight = fitHeight ? containerHeight : containerWidth / imageAspectRatio;
    // Calculate the top-left offset of the image within the container
    final double imageLeftOffset = (containerWidth - displayedWidth) / 2;
    final double imageTopOffset = (containerHeight - displayedHeight) / 2;
    debugPrint('ContainedImage._internal called with:\n'
        'containerWidth: $containerWidth\n'
        'containerHeight: $containerHeight\n'
        'imageWidth: $imageWidth\n'
        'imageHeight: $imageHeight\n'
        'containerAspectRatio: $containerAspectRatio\n'
        'imageAspectRatio: $imageAspectRatio\n'
        'imageLeftOffset: $imageLeftOffset\n'
        'imageTopOffset: $imageTopOffset\n'
        'displayedWidth: $displayedWidth\n'
        'displayedHeight: $displayedHeight');
    return ContainedImage._internal(
      containerWidth: containerWidth,
      containerHeight: containerHeight,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
      imageAspectRatio: imageAspectRatio,
      imageLeftOffset: imageLeftOffset,
      imageTopOffset: imageTopOffset,
      displayedWidth: displayedWidth,
      displayedHeight: displayedHeight
    );
  }

  ContainedImage._internal({
      required this.containerWidth,
      required this.containerHeight,
      required this.imageWidth,
      required this.imageHeight,
      required this.imageAspectRatio,
      required this.imageLeftOffset,
      required this.imageTopOffset,
      required this.displayedWidth,
      required this.displayedHeight});

  double projectXCoordOnImage(double xLocation)
    => ContainedImage.getRelativeX(this, xLocation);

  double projectYCoordOnImage(double yLocation)
    => ContainedImage.getRelativeY(this, yLocation);

  //final double xPos = cImage.imageLeftOffset + (shot.xLocation / _imageWidth) * cImage.displayedWidth;
  //final double yPos = cImage.imageTopOffset + (shot.yLocation / _imageHeight) * cImage.displayedHeight;
  static double getRelativeX(ContainedImage? cImage, double xLocation) =>
      ContainedImage.getRelative(
        axisLocation: xLocation,
        offset: cImage?.imageLeftOffset,
        imageAxisLength: cImage?.imageWidth,
        displayedAxisLength: cImage?.displayedWidth
    );

  static double getRelativeY(ContainedImage? cImage, double yLocation) {
    debugPrint('GetRelativeY called with:\n'
        'yLocation: $yLocation\n'
        'topOffset: ${cImage?.imageTopOffset}\n'
        'imageLengthHeight: ${cImage?.imageHeight}\n'
        'displayedLengthHeight: ${cImage?.displayedHeight}\n'
    );
    return ContainedImage.getRelative(
        axisLocation: yLocation,
        offset: cImage?.imageTopOffset,
        imageAxisLength: cImage?.imageHeight,
        displayedAxisLength: cImage?.displayedHeight
    );
  }

  static double getRelative({
    required double axisLocation,
    double? offset = 0,
    double? imageAxisLength = 1,
    double? displayedAxisLength = 1})
  {
    offset ??= 0;
    imageAxisLength ??= 1;
    displayedAxisLength ??= 1;
    return offset + axisLocation ;
}


}