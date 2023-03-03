![Image of Non-Uniform Border](https://raw.githubusercontent.com/bernaferrari/non_uniform_border/main/assets/NonUniformBorder.png)

# Non-Uniform Border for Flutter

The Non-Uniform Border package provides a custom border class for Flutter that allows different widths for each side of
a border with a single color. This can be useful for creating custom UI elements that require non-uniform border
styling. It also prevents Border runtime crashes and allows lerping.

## Getting Started

In the `pubspec.yaml` of your flutter project, add the following dependency:

[![pub package](https://img.shields.io/pub/v/non_uniform_border.svg)](https://pub.dev/packages/non_uniform_border)

```yaml
dependencies:
  non_uniform_border: ^1.0.0
```

## Usage

To use the NonUniformBorder class, simply import it in your Dart file and create a new instance with the desired side
widths and color:

```dart
import 'package:non_uniform_border/non_uniform_border.dart';

// Create a non-uniform border with different widths and radius.
final shapeBorder = NonUniformBorder(
  leftWidth: 4,
  rightWidth: 8,
  topWidth: 12,
  bottomWidth: 16,
  color: Color(0xfffbbf24),
  side: BorderSide.strokeAlignCenter,
  borderRadius: BorderRadius.horizontal(
    left: Radius.circular(50),
    right: Radius.circular(100),
  ),
);

// Inside a Container.
Container(
  width: 400,
  height: 400,
  decoration: const ShapeDecoration(
    color: Color(0xffa3e635),
    shape: shapeBorder,
  ),
);

// Create a symmetrical border with different widths for each side.
NonUniformBorder.symmetrical(
  verticalWidth: 8,
  horizontalWidth: 4,
  color: Color(0xffec4899),
);

// Create an uniform border.
NonUniformBorder.all(
  width: 2,
  color: Color(0xff00ff00),
);
```

![Image of Example](https://raw.githubusercontent.com/bernaferrari/non_uniform_border/main/assets/Example.gif)

## Contributions

Contributions to the Non-Uniform Border package are welcome! If you find a bug or have a feature request, please open an
issue on the GitHub repository. If you would like to contribute code, please fork the repository and submit a pull
request with your changes.

## License

The Non-Uniform Border package is released under the MIT License. Feel free to use it in your own projects, commercial
or non-commercial.
