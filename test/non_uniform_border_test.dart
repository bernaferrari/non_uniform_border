// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:non_uniform_border/non_uniform_border.dart';

void main() {
  test('NonUniformBorder defaults', () {
    const NonUniformBorder border = NonUniformBorder();
    expect(border.color, const Color(0xff000000));
    expect(border.borderRadius, BorderRadius.zero);
  });

  test('NonUniformBorder copyWith, ==, hashCode', () {
    expect(const NonUniformBorder(), const NonUniformBorder().copyWith());
    expect(const NonUniformBorder().hashCode,
        const NonUniformBorder().copyWith().hashCode);
    expect(
      const NonUniformBorder().copyWith(leftWidth: 20),
      const NonUniformBorder(leftWidth: 20),
    );
  });
}
