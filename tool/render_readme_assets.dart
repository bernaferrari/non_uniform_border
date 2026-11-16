// Generates the README visual assets for `non_uniform_border`:
//   - assets/NonUniformBorder.png
//   - build/readme_frames/showcase/*.png -> assets/showcase.webp
//
// Run via `./tool/generate_assets.sh` (requires `flutter`, `ffmpeg`, and `img2webp`).

import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:non_uniform_border/non_uniform_border.dart';

const ui.Color _paper = ui.Color(0xFFF6F4EE);
const ui.Color _cardBg = ui.Color(0xFFFCFAF5);
const ui.Color _borderCol = ui.Color(0xFFE0DDD4);
const ui.Color _ink = ui.Color(0xFF191918);
const ui.Color _inkMuted = ui.Color(0xFF6B6A66);

const ui.Color _obsidian = ui.Color(0xFF12141A);
const ui.Color _obsidianBorder = ui.Color(0xFF2A2E39);
const ui.Color _cream = ui.Color(0xFFF6F4EE);
const ui.Color _mutedCream = ui.Color(0xFF9EA0A8);

void _drawText(
  ui.Canvas canvas,
  String text,
  ui.Offset offset, {
  required ui.TextStyle style,
  ui.TextAlign align = ui.TextAlign.left,
  double maxWidth = 520,
}) {
  final builder =
      ui.ParagraphBuilder(
          ui.ParagraphStyle(textAlign: align, maxLines: 2, ellipsis: '…'),
        )
        ..pushStyle(style)
        ..addText(text);
  final paragraph = builder.build()
    ..layout(ui.ParagraphConstraints(width: maxWidth));
  final dx = switch (align) {
    ui.TextAlign.center => offset.dx - maxWidth / 2,
    ui.TextAlign.right => offset.dx - maxWidth,
    _ => offset.dx,
  };
  canvas.drawParagraph(paragraph, ui.Offset(dx, offset.dy));
}

void _drawPill(
  ui.Canvas canvas, {
  required double cx,
  required double top,
  required String text,
  ui.Color bg = _cardBg,
  ui.Color border = _borderCol,
  ui.Color textColor = _ink,
}) {
  final builder =
      ui.ParagraphBuilder(ui.ParagraphStyle(textAlign: ui.TextAlign.center))
        ..pushStyle(
          ui.TextStyle(
            fontFamily: 'StudioMono',
            fontSize: 10.5,
            fontWeight: ui.FontWeight.w600,
            color: textColor,
          ),
        )
        ..addText(text);
  final paragraph = builder.build()
    ..layout(const ui.ParagraphConstraints(width: 320));
  final textW = paragraph.maxIntrinsicWidth;
  final pillW = textW + 20;
  const pillH = 22.0;
  final rr = ui.RRect.fromRectAndRadius(
    ui.Rect.fromLTWH(cx - pillW / 2, top, pillW, pillH),
    const ui.Radius.circular(11),
  );
  canvas.drawRRect(rr, ui.Paint()..color = bg);
  canvas.drawRRect(
    rr,
    ui.Paint()
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = border,
  );
  canvas.drawParagraph(paragraph, ui.Offset(cx - 160, top + 4.5));
}

void _paintBorderBox(
  ui.Canvas canvas,
  ui.Rect rect,
  NonUniformBorder border,
  ui.Color fillColor,
) {
  final fillPaint = ui.Paint()..color = fillColor;
  border.paintInterior(canvas, rect, fillPaint);
  border.paint(canvas, rect);
}

void _drawCheckBadge(
  ui.Canvas canvas,
  ui.Offset center,
  double radius,
  ui.Color bg,
  ui.Color fg,
) {
  canvas.drawCircle(center, radius, ui.Paint()..color = bg);
  final check = ui.Path()
    ..moveTo(center.dx - radius * 0.42, center.dy + 0.3)
    ..lineTo(center.dx - radius * 0.1, center.dy + radius * 0.34)
    ..lineTo(center.dx + radius * 0.44, center.dy - radius * 0.32);
  canvas.drawPath(
    check,
    ui.Paint()
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = ui.StrokeCap.round
      ..strokeJoin = ui.StrokeJoin.round
      ..color = fg,
  );
}

Future<void> _savePng(
  ui.PictureRecorder recorder,
  double width,
  double height,
  double dpr,
  String path,
) async {
  final picture = recorder.endRecording();
  final image = await picture.toImage(
    (width * dpr).round(),
    (height * dpr).round(),
  );
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path)
    ..parent.createSync(recursive: true)
    ..writeAsBytesSync(byteData!.buffer.asUint8List());
  image.dispose();
  picture.dispose();
}

Future<void> _loadFonts() async {
  Future<void> tryLoad(String family, String filePath) async {
    final file = File(filePath);
    if (!file.existsSync()) return;
    final bytes = file.readAsBytesSync();
    final loader = FontLoader(family)
      ..addFont(Future.value(ByteData.sublistView(bytes)));
    await loader.load();
  }

  await tryLoad('StudioSans', '/System/Library/Fonts/SFNS.ttf');
  await tryLoad('StudioMono', '/System/Library/Fonts/SFNSMono.ttf');
}

void _renderHeroSpecimen(ui.Canvas canvas) {
  // 1. Top specimen: Tactile 3D CTA button (`bottomWidth`)
  const btnRect = ui.Rect.fromLTWH(472, 34, 248, 56);
  const btnBorder = NonUniformBorder(
    leftWidth: 2.0,
    topWidth: 1.5,
    rightWidth: 2.0,
    bottomWidth: 8.5,
    color: ui.Color(0xFF0F766E),
    strokeAlign: BorderSide.strokeAlignInside,
    borderRadius: BorderRadius.all(Radius.circular(16)),
  );
  _paintBorderBox(canvas, btnRect, btnBorder, const ui.Color(0xFF14B8A6));
  _drawCheckBadge(
    canvas,
    ui.Offset(btnRect.left + 60, btnRect.center.dy - 3),
    10.0,
    const ui.Color(0x33FFFFFF),
    const ui.Color(0xFFFFFFFF),
  );
  _drawText(
    canvas,
    'Publish v1.0',
    ui.Offset(btnRect.left + 80, btnRect.center.dy - 12),
    maxWidth: 150,
    style: ui.TextStyle(
      fontFamily: 'StudioSans',
      fontSize: 15,
      fontWeight: ui.FontWeight.w700,
      color: const ui.Color(0xFFFFFFFF),
    ),
  );

  // 2. Bottom specimen: Active accent card (`leftWidth` + asymmetric radii)
  const calloutRect = ui.Rect.fromLTWH(472, 106, 248, 72);
  const calloutBorder = NonUniformBorder(
    leftWidth: 8.5,
    topWidth: 1.5,
    rightWidth: 1.5,
    bottomWidth: 1.5,
    color: ui.Color(0xFF38BDF8),
    strokeAlign: BorderSide.strokeAlignInside,
    borderRadius: BorderRadius.horizontal(
      left: Radius.circular(16),
      right: Radius.circular(14),
    ),
  );
  _paintBorderBox(
    canvas,
    calloutRect,
    calloutBorder,
    const ui.Color(0xFF16202F),
  );
  _drawText(
    canvas,
    'Active Navigation Item',
    ui.Offset(calloutRect.left + 22, calloutRect.top + 16),
    maxWidth: 210,
    style: ui.TextStyle(
      fontFamily: 'StudioSans',
      fontSize: 13.5,
      fontWeight: ui.FontWeight.w700,
      color: const ui.Color(0xFFF0F9FF),
    ),
  );
  _drawText(
    canvas,
    'left: 8.5  ·  else: 1.5',
    ui.Offset(calloutRect.left + 22, calloutRect.top + 40),
    maxWidth: 210,
    style: ui.TextStyle(
      fontFamily: 'StudioMono',
      fontSize: 10.5,
      fontWeight: ui.FontWeight.w500,
      color: const ui.Color(0xFF7DD3FC),
    ),
  );
}

double _easeInOutCubic(double x) {
  final t = x.clamp(0.0, 1.0);
  return t < 0.5 ? 4 * t * t * t : 1 - math.pow(-2 * t + 2, 3) / 2;
}

double _beatProgress(double local) {
  if (local < 0.34) return 0.0;
  if (local < 0.56) return _easeInOutCubic((local - 0.34) / 0.22);
  return 1.0;
}

double _segmentedSwitch(double t) {
  if (t < 0.5) {
    return _beatProgress(t * 2.0);
  }
  return 1.0 - _beatProgress((t - 0.5) * 2.0);
}

double _buttonClickCurve(double t) {
  final local = (t * 2.0) % 1.0;
  if (local < 0.24) return 0.0;
  if (local < 0.36) return _easeInOutCubic((local - 0.24) / 0.12);
  if (local < 0.50) return 1.0;
  if (local < 0.66) return 1.0 - _easeInOutCubic((local - 0.50) / 0.16);
  return 0.0;
}

void _drawCardChrome(
  ui.Canvas canvas,
  ui.Rect cardRect,
  String title,
  String subtitle,
) {
  final rr = ui.RRect.fromRectAndRadius(cardRect, const ui.Radius.circular(18));
  canvas.drawRRect(rr, ui.Paint()..color = _cardBg);
  canvas.drawRRect(
    rr,
    ui.Paint()
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = _borderCol,
  );
  _drawText(
    canvas,
    title,
    ui.Offset(cardRect.center.dx, cardRect.top + 16),
    align: ui.TextAlign.center,
    maxWidth: cardRect.width - 24,
    style: ui.TextStyle(
      fontFamily: 'StudioSans',
      fontSize: 17,
      fontWeight: ui.FontWeight.w700,
      color: _ink,
      letterSpacing: -0.2,
    ),
  );
  _drawText(
    canvas,
    subtitle,
    ui.Offset(cardRect.center.dx, cardRect.top + 39),
    align: ui.TextAlign.center,
    maxWidth: cardRect.width - 24,
    style: ui.TextStyle(
      fontFamily: 'StudioSans',
      fontSize: 12,
      fontWeight: ui.FontWeight.w500,
      color: _inkMuted,
    ),
  );
}

void _drawMenuRow(
  ui.Canvas canvas, {
  required ui.Rect rect,
  required double activeWeight,
  required String title,
  required String subtitle,
}) {
  const idle = NonUniformBorder.all(
    width: 1.25,
    color: ui.Color(0xFFE2E0D8),
    strokeAlign: BorderSide.strokeAlignInside,
    borderRadius: BorderRadius.all(Radius.circular(14)),
  );
  const active = NonUniformBorder(
    leftWidth: 7.5,
    topWidth: 1.5,
    rightWidth: 1.5,
    bottomWidth: 1.5,
    color: ui.Color(0xFF4F46E5),
    strokeAlign: BorderSide.strokeAlignInside,
    borderRadius: BorderRadius.horizontal(
      left: Radius.circular(15),
      right: Radius.circular(14),
    ),
  );
  final border = NonUniformBorder.lerp(idle, active, activeWeight)!;
  final fill = ui.Color.lerp(
    const ui.Color(0xFFFFFFFF),
    const ui.Color(0xFFEEF2FF),
    activeWeight,
  )!;
  _paintBorderBox(canvas, rect, border, fill);

  final dotColor = ui.Color.lerp(
    const ui.Color(0xFFCBD5E1),
    const ui.Color(0xFF4F46E5),
    activeWeight,
  )!;
  canvas.drawCircle(
    ui.Offset(rect.left + 22, rect.center.dy),
    4.5,
    ui.Paint()..color = dotColor,
  );
  _drawText(
    canvas,
    title,
    ui.Offset(rect.left + 36, rect.top + 10.5),
    maxWidth: rect.width - 104,
    style: ui.TextStyle(
      fontFamily: 'StudioSans',
      fontSize: 13.5,
      fontWeight: activeWeight > 0.5 ? ui.FontWeight.w700 : ui.FontWeight.w600,
      color: _ink,
    ),
  );
  _drawText(
    canvas,
    subtitle,
    ui.Offset(rect.left + 36, rect.top + 29),
    maxWidth: rect.width - 52,
    style: ui.TextStyle(
      fontFamily: 'StudioSans',
      fontSize: 11,
      fontWeight: ui.FontWeight.w500,
      color: _inkMuted,
    ),
  );
}

void main() {
  test('render non_uniform_border README assets', () async {
    await _loadFonts();

    // 1. Hero banner (`assets/NonUniformBorder.png`).
    {
      const width = 760.0;
      const height = 212.0;
      const dpr = 2.0;

      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder)..scale(dpr, dpr);

      final bgRect = ui.RRect.fromRectAndRadius(
        const ui.Rect.fromLTWH(2, 2, width - 4, height - 4),
        const ui.Radius.circular(24),
      );
      canvas.drawRRect(bgRect, ui.Paint()..color = _obsidian);
      canvas.drawRRect(
        bgRect,
        ui.Paint()
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = _obsidianBorder,
      );

      _drawText(
        canvas,
        'NonUniformBorder',
        const ui.Offset(36, 36),
        maxWidth: 400,
        style: ui.TextStyle(
          fontFamily: 'StudioSans',
          fontSize: 34,
          fontWeight: ui.FontWeight.w800,
          color: _cream,
          letterSpacing: -0.8,
        ),
      );
      _drawText(
        canvas,
        'Independent side widths, mixed BorderRadius corners,\n'
        'strokeAlign, and smooth lerping — zero Border crashes.',
        const ui.Offset(36, 84),
        maxWidth: 406,
        style: ui.TextStyle(
          fontFamily: 'StudioSans',
          fontSize: 13.5,
          fontWeight: ui.FontWeight.w400,
          color: _mutedCream,
          height: 1.4,
        ),
      );

      const tags = [
        ('ShapeBorder', ui.Color(0xFF38BDF8)),
        ('BorderRadius', ui.Color(0xFFFBBF24)),
        ('strokeAlign', ui.Color(0xFF34D399)),
        ('lerp()', ui.Color(0xFFA78BFA)),
      ];
      var tagX = 36.0;
      for (final (label, dotColor) in tags) {
        final b =
            ui.ParagraphBuilder(ui.ParagraphStyle(textAlign: ui.TextAlign.left))
              ..pushStyle(
                ui.TextStyle(
                  fontFamily: 'StudioMono',
                  fontSize: 10.2,
                  fontWeight: ui.FontWeight.w600,
                  color: _cream,
                ),
              )
              ..addText(label);
        final p = b.build()..layout(const ui.ParagraphConstraints(width: 140));
        final w = p.maxIntrinsicWidth + 24;
        final pill = ui.RRect.fromRectAndRadius(
          ui.Rect.fromLTWH(tagX, 150, w, 25),
          const ui.Radius.circular(12.5),
        );
        canvas.drawRRect(pill, ui.Paint()..color = const ui.Color(0xFF1B1E27));
        canvas.drawRRect(
          pill,
          ui.Paint()
            ..style = ui.PaintingStyle.stroke
            ..strokeWidth = 1.0
            ..color = const ui.Color(0xFF2D3240),
        );
        canvas.drawCircle(
          ui.Offset(tagX + 11, 162.5),
          3.2,
          ui.Paint()..color = dotColor,
        );
        canvas.drawParagraph(p, ui.Offset(tagX + 18, 156.0));
        tagX += w + 6;
      }

      _renderHeroSpecimen(canvas);

      await _savePng(
        recorder,
        width,
        height,
        dpr,
        'assets/NonUniformBorder.png',
      );
    }

    // 2. Animated 2-card showcase (`build/readme_frames/showcase`).
    {
      final outDir = Directory('build/readme_frames/showcase')
        ..createSync(recursive: true);

      const width = 760.0;
      const height = 286.0;
      const dpr = 2.0;
      const frames = 90;

      const outerPad = 16.0;
      const gap = 16.0;
      const cardW = (width - outerPad * 2 - gap) / 2;
      const cardH = height - outerPad * 2;

      const leftCard = ui.Rect.fromLTWH(outerPad, outerPad, cardW, cardH);
      const rightCard = ui.Rect.fromLTWH(
        outerPad + cardW + gap,
        outerPad,
        cardW,
        cardH,
      );

      for (var frame = 0; frame < frames; frame++) {
        final t = frame / frames;
        final selectProgress = _segmentedSwitch(t);
        final press = _buttonClickCurve(t);

        final recorder = ui.PictureRecorder();
        final canvas = ui.Canvas(recorder)..scale(dpr, dpr);
        canvas.drawRect(
          const ui.Rect.fromLTWH(0, 0, width, height),
          ui.Paint()..color = _paper,
        );

        // Panel 1: Tactile 3D CTA Button (`bottomWidth`)
        _drawCardChrome(
          canvas,
          leftCard,
          'Tactile 3D Button',
          'Keycap depth using bottomWidth + borderRadius',
        );
        final bottomW = ui.lerpDouble(11.5, 2.5, press)!;
        final dy = press * 7.5;
        final btnRect = ui.Rect.fromCenter(
          center: ui.Offset(leftCard.center.dx, leftCard.top + 132 + dy),
          width: 224,
          height: 64 - (press * 5.0),
        );
        final btnBorder = NonUniformBorder(
          leftWidth: 2.5,
          topWidth: 2.0,
          rightWidth: 2.5,
          bottomWidth: bottomW,
          color: const ui.Color(0xFF0F766E),
          strokeAlign: BorderSide.strokeAlignInside,
          borderRadius: const BorderRadius.all(Radius.circular(18)),
        );
        _paintBorderBox(
          canvas,
          btnRect,
          btnBorder,
          ui.Color.lerp(
            const ui.Color(0xFF14B8A6),
            const ui.Color(0xFF0D9488),
            press,
          )!,
        );
        _drawCheckBadge(
          canvas,
          ui.Offset(btnRect.left + 48, btnRect.center.dy - (bottomW - 2) * 0.3),
          9.5,
          const ui.Color(0x33FFFFFF),
          const ui.Color(0xFFFFFFFF),
        );
        _drawText(
          canvas,
          'Switch Row',
          ui.Offset(
            btnRect.left + 72,
            btnRect.center.dy - 9.5 - (bottomW - 2) * 0.3,
          ),
          maxWidth: 140,
          style: ui.TextStyle(
            fontFamily: 'StudioSans',
            fontSize: 15,
            fontWeight: ui.FontWeight.w700,
            color: const ui.Color(0xFFFFFFFF),
          ),
        );
        _drawPill(
          canvas,
          cx: leftCard.center.dx,
          top: leftCard.bottom - 38,
          text: 'top: 2.0  ·  bottom: ${bottomW.toStringAsFixed(1)}',
        );

        // Panel 2: Active Selection Bar (`leftWidth` sliding via lerp)
        _drawCardChrome(
          canvas,
          rightCard,
          'Active Selection Bar',
          'Left accent bar + rounded corners via lerp',
        );
        final row1Rect = ui.Rect.fromLTWH(
          rightCard.left + 26,
          rightCard.top + 74,
          rightCard.width - 52,
          54,
        );
        final row2Rect = ui.Rect.fromLTWH(
          rightCard.left + 26,
          rightCard.top + 138,
          rightCard.width - 52,
          54,
        );
        _drawMenuRow(
          canvas,
          rect: row1Rect,
          activeWeight: 1.0 - selectProgress,
          title: 'General',
          subtitle: 'Project & build settings',
        );
        _drawMenuRow(
          canvas,
          rect: row2Rect,
          activeWeight: selectProgress,
          title: 'Notifications',
          subtitle: 'Alerts & webhook events',
        );
        final row1Left = ui.lerpDouble(7.5, 1.3, selectProgress)!;
        final row2Left = ui.lerpDouble(1.3, 7.5, selectProgress)!;
        _drawPill(
          canvas,
          cx: rightCard.center.dx,
          top: rightCard.bottom - 38,
          text:
              'Row 1 L:${row1Left.toStringAsFixed(1)}  ·  Row 2 L:${row2Left.toStringAsFixed(1)}',
        );

        final name = frame.toString().padLeft(4, '0');
        await _savePng(
          recorder,
          width,
          height,
          dpr,
          '${outDir.path}/frame_$name.png',
        );
      }
    }
  });
}
