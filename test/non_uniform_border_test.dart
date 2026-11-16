// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:non_uniform_border/non_uniform_border.dart';

void main() {
  test('NonUniformBorder defaults and constructors', () {
    const NonUniformBorder border = NonUniformBorder();
    expect(border.hasUniformWidth, isTrue);
    expect(border.leftWidth, 1.0);
    expect(border.topWidth, 1.0);
    expect(border.rightWidth, 1.0);
    expect(border.bottomWidth, 1.0);
    expect(border.color, const Color(0xff000000));
    expect(border.strokeAlign, BorderSide.strokeAlignInside);
    expect(border.borderRadius, BorderRadius.zero);

    final NonUniformBorder fromSide = NonUniformBorder.fromBorderSide(
      const BorderSide(
        width: 3,
        color: Color(0xff123456),
        strokeAlign: BorderSide.strokeAlignCenter,
      ),
    );
    expect(
      fromSide,
      const NonUniformBorder.all(
        width: 3,
        color: Color(0xff123456),
        strokeAlign: BorderSide.strokeAlignCenter,
      ),
    );

    const NonUniformBorder symmetric = NonUniformBorder.symmetric(
      verticalWidth: 4,
      horizontalWidth: 8,
    );
    expect(symmetric.hasUniformWidth, isFalse);
    expect(symmetric.topWidth, 4);
    expect(symmetric.bottomWidth, 4);
    expect(symmetric.leftWidth, 8);
    expect(symmetric.rightWidth, 8);
  });

  test('NonUniformBorder copyWith, ==, hashCode', () {
    expect(const NonUniformBorder(), const NonUniformBorder().copyWith());
    expect(
      const NonUniformBorder().hashCode,
      const NonUniformBorder().copyWith().hashCode,
    );
    expect(
      const NonUniformBorder().copyWith(leftWidth: 20),
      const NonUniformBorder(leftWidth: 20),
    );
  });

  test('NonUniformBorder dimensions match strokeAlign for uniform and non-uniform widths', () {
    const double width = 8;
    const NonUniformBorder uniformInside = NonUniformBorder.all(
      width: width,
      strokeAlign: BorderSide.strokeAlignInside,
    );
    expect(uniformInside.dimensions, const EdgeInsets.all(8));

    const NonUniformBorder uniformCenter = NonUniformBorder.all(
      width: width,
      strokeAlign: BorderSide.strokeAlignCenter,
    );
    expect(uniformCenter.dimensions, const EdgeInsets.all(4));

    const NonUniformBorder uniformOutside = NonUniformBorder.all(
      width: width,
      strokeAlign: BorderSide.strokeAlignOutside,
    );
    expect(uniformOutside.dimensions, EdgeInsets.zero);

    const NonUniformBorder nonUniform = NonUniformBorder(
      leftWidth: 4,
      topWidth: 8,
      rightWidth: 12,
      bottomWidth: 16,
      strokeAlign: BorderSide.strokeAlignCenter,
    );
    expect(nonUniform.dimensions, const EdgeInsets.fromLTRB(2, 4, 6, 8));
  });

  test('NonUniformBorder scale and lerp preserve color, strokeAlign, and borderRadius', () {
    final NonUniformBorder border = NonUniformBorder(
      leftWidth: 4,
      topWidth: 8,
      rightWidth: 12,
      bottomWidth: 16,
      color: const Color(0xff00b4fc),
      strokeAlign: BorderSide.strokeAlignCenter,
      borderRadius: BorderRadius.circular(10),
    );

    final NonUniformBorder scaled = border.scale(0.5);
    expect(scaled.leftWidth, 2);
    expect(scaled.topWidth, 4);
    expect(scaled.rightWidth, 6);
    expect(scaled.bottomWidth, 8);
    expect(scaled.color, const Color(0xff00b4fc));
    expect(scaled.strokeAlign, BorderSide.strokeAlignCenter);
    expect(scaled.borderRadius, BorderRadius.circular(5));

    expect(NonUniformBorder.lerp(null, null, 0.5), isNull);
    expect(NonUniformBorder.lerp(null, border, 0.5), scaled);
    expect(NonUniformBorder.lerp(border, null, 0.5), scaled);
  });

  test('NonUniformBorder getInnerPath, getOuterPath, and paint', () {
    const Rect rect = Rect.fromLTWH(0, 0, 100, 60);
    const NonUniformBorder border = NonUniformBorder(
      leftWidth: 2,
      topWidth: 4,
      rightWidth: 6,
      bottomWidth: 8,
      color: Color(0xff012677),
      borderRadius: BorderRadius.all(Radius.circular(12)),
    );

    expect(border.getOuterPath(rect).getBounds(), rect);
    expect(
      border.getInnerPath(rect).getBounds(),
      const Rect.fromLTRB(2, 4, 94, 52),
    );
    expect(border.preferPaintInterior, isTrue);
    expect(border.add(border), isNull);
  });

  testWidgets('NonUniformBorder paints in ShapeDecoration', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SizedBox(
            width: 100,
            height: 60,
            child: DecoratedBox(
              decoration: ShapeDecoration(
                color: Color(0xff012677),
                shape: NonUniformBorder(
                  leftWidth: 2,
                  topWidth: 6,
                  rightWidth: 10,
                  bottomWidth: 14,
                  color: Color(0xff00b4fc),
                  strokeAlign: BorderSide.strokeAlignCenter,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(DecoratedBox), findsOneWidget);
  });
}
