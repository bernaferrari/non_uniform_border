import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// A border that allows different widths for each of its sides,
/// but uses a single color for all sides.
/// This works like [Border], but is guaranteed to be runtime safe.
///
/// The [leftWidth], [topWidth], [rightWidth], and [bottomWidth] arguments
/// specify the width of the corresponding border sides.
/// The [color] argument specifies the color for all sides.
class const NonUniformBorder({
  final double leftWidth = 1.0,
  final double topWidth = 1.0,
  final double rightWidth = 1.0,
  final double bottomWidth = 1.0,
  final Color color = const Color(0xFF000000),
  final double strokeAlign = BorderSide.strokeAlignInside,
  final BorderRadius borderRadius = BorderRadius.zero,
}) extends ShapeBorder {
  final bool hasUniformWidth;

  this
    : hasUniformWidth =
          leftWidth == topWidth &&
          rightWidth == bottomWidth &&
          leftWidth == rightWidth;

  /// Creates a border whose sides are all the same.
  factory fromBorderSide(BorderSide side) => NonUniformBorder(
    leftWidth: side.width,
    topWidth: side.width,
    rightWidth: side.width,
    bottomWidth: side.width,
    color: side.color,
    strokeAlign: side.strokeAlign,
  );

  /// Creates a border with symmetrical vertical and horizontal sides.
  const new symmetric({
    double verticalWidth = 1.0,
    double horizontalWidth = 1.0,
    Color color = const Color(0xFF000000),
    double strokeAlign = BorderSide.strokeAlignInside,
    BorderRadius borderRadius = BorderRadius.zero,
  }) : this(
         leftWidth: horizontalWidth,
         topWidth: verticalWidth,
         rightWidth: horizontalWidth,
         bottomWidth: verticalWidth,
         color: color,
         strokeAlign: strokeAlign,
         borderRadius: borderRadius,
       );

  /// Creates a border whose four sides all have the same [width].
  const new all({
    double width = 1.0,
    Color color = const Color(0xFF000000),
    double strokeAlign = BorderSide.strokeAlignInside,
    BorderRadius borderRadius = BorderRadius.zero,
  }) : this(
         leftWidth: width,
         topWidth: width,
         rightWidth: width,
         bottomWidth: width,
         color: color,
         strokeAlign: strokeAlign,
         borderRadius: borderRadius,
       );

  @override
  EdgeInsetsGeometry get dimensions {
    if (!hasUniformWidth) {
      return EdgeInsets.fromLTRB(
        leftWidth * (1 - (1 + strokeAlign) / 2),
        topWidth * (1 - (1 + strokeAlign) / 2),
        rightWidth * (1 - (1 + strokeAlign) / 2),
        bottomWidth * (1 - (1 + strokeAlign) / 2),
      );
    }
    return EdgeInsets.all(leftWidth * (1 - (1 + strokeAlign) / 2));
  }

  @override
  NonUniformBorder? add(ShapeBorder other, {bool reversed = false}) {
    return null;
  }

  @override
  NonUniformBorder scale(double t) {
    return NonUniformBorder(
      topWidth: topWidth * t,
      rightWidth: rightWidth * t,
      bottomWidth: bottomWidth * t,
      leftWidth: leftWidth * t,
      color: color,
      strokeAlign: strokeAlign,
      borderRadius: borderRadius * t,
    );
  }

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is NonUniformBorder) {
      return NonUniformBorder.lerp(a, this, t);
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is NonUniformBorder) {
      return NonUniformBorder.lerp(this, b, t);
    }
    return super.lerpTo(b, t);
  }

  NonUniformBorder copyWith({
    double? leftWidth,
    double? topWidth,
    double? rightWidth,
    double? bottomWidth,
    Color? color,
    double? strokeAlign,
    BorderRadius? borderRadius,
  }) => NonUniformBorder(
    leftWidth: leftWidth ?? this.leftWidth,
    topWidth: topWidth ?? this.topWidth,
    rightWidth: rightWidth ?? this.rightWidth,
    bottomWidth: bottomWidth ?? this.bottomWidth,
    color: color ?? this.color,
    strokeAlign: strokeAlign ?? this.strokeAlign,
    borderRadius: borderRadius ?? this.borderRadius,
  );

  /// Linearly interpolate between two borders.
  ///
  /// If a border is null, it is treated as having four [BorderSide.none]
  /// borders.
  ///
  /// {@macro dart.ui.shadow.lerp}
  static NonUniformBorder? lerp(
    NonUniformBorder? a,
    NonUniformBorder? b,
    double t,
  ) {
    if (a == null && b == null) {
      return null;
    }
    if (a == null) {
      return b!.scale(t);
    }
    if (b == null) {
      return a.scale(1.0 - t);
    }
    return NonUniformBorder(
      leftWidth: lerpDouble(a.leftWidth, b.leftWidth, t)!,
      topWidth: lerpDouble(a.topWidth, b.topWidth, t)!,
      rightWidth: lerpDouble(a.rightWidth, b.rightWidth, t)!,
      bottomWidth: lerpDouble(a.bottomWidth, b.bottomWidth, t)!,
      color: Color.lerp(a.color, b.color, t)!,
      strokeAlign: lerpDouble(a.strokeAlign, b.strokeAlign, t)!,
      borderRadius: BorderRadius.lerp(a.borderRadius, b.borderRadius, t)!,
    );
  }

  @override
  bool get preferPaintInterior => true;

  @override
  void paintInterior(
    Canvas canvas,
    Rect rect,
    Paint paint, {
    TextDirection? textDirection,
  }) {
    if (borderRadius == BorderRadius.zero) {
      canvas.drawRect(rect, paint);
    } else {
      canvas.drawRRect(
        borderRadius.resolve(textDirection).toRRect(rect),
        paint,
      );
    }
  }

  /// Paints the border within the given [Rect] on the given [Canvas].
  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    TextDirection? textDirection,
    BoxShape shape = BoxShape.rectangle,
    BorderRadius? borderRadius,
  }) {
    final RRect borderRect = (borderRadius ?? this.borderRadius)
        .resolve(textDirection)
        .toRRect(rect);
    if (!hasUniformWidth) {
      drawMultipleWidth(canvas, borderRect);
    } else {
      final Paint paint = Paint()..color = color;
      final RRect inner = borderRect.deflate(
        leftWidth * (1 - (1 + strokeAlign) / 2),
      );
      final RRect outer = borderRect.inflate(leftWidth * (1 + strokeAlign) / 2);
      canvas.drawDRRect(outer, inner, paint);
    }
  }

  /// Draws a RRect in the canvas by modifying its size and
  /// calling [Canvas.drawDRRect] which gets the difference
  /// between two rectangles.
  ///
  /// The process is similar to [BorderSide.strokeInset] and
  /// [BorderSide.strokeOutset].
  void drawMultipleWidth(Canvas canvas, RRect borderRect) {
    final Paint paint = Paint()..color = color;

    // Similar process to strokeInset calculation.
    final RRect inner = EdgeInsets.fromLTRB(
      leftWidth * (1 - (1 + strokeAlign) / 2),
      topWidth * (1 - (1 + strokeAlign) / 2),
      rightWidth * (1 - (1 + strokeAlign) / 2),
      bottomWidth * (1 - (1 + strokeAlign) / 2),
    ).deflateRRect(borderRect);

    // Similar process to strokeOutset calculation.
    final RRect outer = EdgeInsets.fromLTRB(
      leftWidth * (1 + strokeAlign) / 2,
      topWidth * (1 + strokeAlign) / 2,
      rightWidth * (1 + strokeAlign) / 2,
      bottomWidth * (1 + strokeAlign) / 2,
    ).inflateRRect(borderRect);
    canvas.drawDRRect(outer, inner, paint);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is NonUniformBorder &&
        other.color == color &&
        other.strokeAlign == strokeAlign &&
        other.borderRadius == borderRadius &&
        other.topWidth == topWidth &&
        other.rightWidth == rightWidth &&
        other.bottomWidth == bottomWidth &&
        other.leftWidth == leftWidth;
  }

  @override
  int get hashCode => Object.hash(
    color,
    strokeAlign,
    borderRadius,
    topWidth,
    rightWidth,
    bottomWidth,
    leftWidth,
  );

  @override
  String toString() {
    if (hasUniformWidth) {
      return '${objectRuntimeType(this, 'Border')}.all($topWidth)';
    }
    return '${objectRuntimeType(this, 'Border')}.only(left: $leftWidth, top: $topWidth, right: $rightWidth, bottom: $bottomWidth)';
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    final RRect borderRect = borderRadius.resolve(textDirection).toRRect(rect);
    final RRect adjustedRect = dimensions
        .resolve(textDirection)
        .deflateRRect(borderRect);
    return Path()..addRRect(adjustedRect);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRRect(borderRadius.resolve(textDirection).toRRect(rect));
  }
}
