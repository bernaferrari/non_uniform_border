import 'package:flutter/material.dart';
import 'package:non_uniform_border/non_uniform_border.dart';

// Inspired by Flutter's BorderSide.0.test
void main() => runApp(const StrokeAlignApp());

class StrokeAlignApp extends StatelessWidget {
  const StrokeAlignApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: StrokeAlignExample());
  }
}

class StrokeAlignExample extends StatefulWidget {
  const StrokeAlignExample({super.key});

  @override
  State<StrokeAlignExample> createState() => _StrokeAlignExampleState();
}

class _StrokeAlignExampleState extends State<StrokeAlignExample>
    with TickerProviderStateMixin {
  late final AnimationController animation;

  @override
  void initState() {
    super.initState();
    animation =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    animation.repeat(reverse: true);
    animation.addListener(_markDirty);
  }

  @override
  void dispose() {
    animation.dispose();
    super.dispose();
  }

  void _markDirty() {
    setState(() {});
  }

  static const double borderWidth = 10;
  static const double cornerRadius = 10;
  static const Color borderColor = Color(0x8000b4fc);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            BorderedBox(
              shape: NonUniformBorder(
                color: borderColor,
                leftWidth: borderWidth,
                rightWidth: borderWidth,
                topWidth: borderWidth * animation.value * 2,
                bottomWidth: borderWidth * animation.value * 2,
                strokeAlign: (animation.value * 2) - 1,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(cornerRadius * animation.value * 2),
                  topRight: Radius.circular(cornerRadius * animation.value * 2),
                  bottomLeft:
                      Radius.circular(cornerRadius * animation.value / 2),
                  bottomRight:
                      Radius.circular(cornerRadius * animation.value / 2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                BorderedBox(
                  shape: NonUniformBorder(
                    color: borderColor,
                    leftWidth: borderWidth * animation.value * 2,
                    rightWidth: borderWidth * animation.value * 2,
                    topWidth: borderWidth,
                    bottomWidth: borderWidth,
                    strokeAlign: (animation.value * 2) - 1,
                  ),
                ),
                BorderedBox(
                  shape: NonUniformBorder(
                    color: borderColor,
                    leftWidth: borderWidth,
                    rightWidth: borderWidth * animation.value * 2,
                    topWidth: borderWidth * animation.value * 2,
                    bottomWidth: borderWidth,
                  ),
                ),
              ],
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  BorderedBox(
                    shape: NonUniformBorder(
                        color: borderColor,
                        leftWidth: borderWidth,
                        rightWidth: borderWidth * animation.value * 2,
                        topWidth: borderWidth * animation.value,
                        bottomWidth: borderWidth * animation.value * 2,
                        borderRadius: BorderRadius.circular(cornerRadius),
                        strokeAlign: 0),
                  ),
                  BorderedBox(
                    shape: NonUniformBorder(
                      color: borderColor,
                      leftWidth: borderWidth,
                      rightWidth: borderWidth,
                      topWidth: borderWidth * animation.value * 2,
                      bottomWidth: borderWidth * animation.value * 2,
                      strokeAlign: 1,
                      borderRadius: BorderRadius.only(
                        topLeft:
                            Radius.circular(cornerRadius * animation.value * 2),
                        topRight:
                            Radius.circular(cornerRadius * animation.value * 2),
                      ),
                    ),
                  ),
                ]),
          ],
        ),
      ),
    );
  }
}

class BorderedBox extends StatelessWidget {
  const BorderedBox({
    super.key,
    required this.shape,
  });

  final ShapeBorder shape;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 50,
      decoration: ShapeDecoration(
        color: const Color(0xff012677),
        shape: shape,
      ),
    );
  }
}
