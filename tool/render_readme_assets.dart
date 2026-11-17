// Generates the README visual assets for `non_uniform_border`:
//   - assets/NonUniformBorder.png
//   - build/readme_frames/showcase/*.png -> assets/showcase.webp
//   - build/readme_frames/example/*.png  -> assets/example.webp
//
// Run via `./tool/generate_assets.sh` (requires macOS system fonts, `flutter`,
// `ffmpeg`, and `img2webp`).

import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:non_uniform_border/non_uniform_border.dart';

const ui.Color _paper = ui.Color(0xFFF4F1EA);
const ui.Color _surface = ui.Color(0xFFFBFAF6);
const ui.Color _hairline = ui.Color(0xFFDDD8CC);
const ui.Color _gridDot = ui.Color(0xFFDCD6C9);
const ui.Color _ink = ui.Color(0xFF1B1A17);
const ui.Color _muted = ui.Color(0xFF8A857A);
const ui.Color _white = ui.Color(0xFFFFFFFF);

const ui.Color _accent = ui.Color(0xFFE0522C);
const ui.Color _accentDeep = ui.Color(0xFF9E3418);
const ui.Color _accentTint = ui.Color(0xFFFBE7DF);

const double _width = 760.0;
const double _dpr = 2.0;
const double _sheetRadius = 22.0;
const double _gridStep = 14.0;
const double _pad = 24.0;
const double _footerHeight = 44.0;
const int _frames = 120;

typedef _Span = (String, ui.TextStyle);

ui.TextStyle _style(
  String family,
  double size,
  double weight,
  ui.Color color, {
  double letterSpacing = 0,
}) {
  return ui.TextStyle(
    fontFamily: family,
    fontSize: size,
    color: color,
    letterSpacing: letterSpacing,
    fontWeight: ui.FontWeight.values[(weight / 100).round() - 1],
    fontVariations: [
      ui.FontVariation('wght', weight),
      ui.FontVariation('opsz', size),
    ],
  );
}

ui.TextStyle _serif(double size, {ui.Color color = _ink}) =>
    _style('Serif', size, 500, color, letterSpacing: -size * 0.012);

ui.TextStyle _sans(double size, {double weight = 450, ui.Color color = _ink}) =>
    _style('Sans', size, weight, color, letterSpacing: -size * 0.008);

ui.TextStyle _mono(double size, {double weight = 450, ui.Color color = _ink}) =>
    _style('Mono', size, weight, color);

enum _Anchor { start, center, end }

/// Draws [spans] on a single line with its alphabetic baseline at [baseline].
double _text(
  ui.Canvas canvas,
  List<_Span> spans, {
  required double x,
  required double baseline,
  _Anchor anchor = _Anchor.start,
}) {
  final builder = ui.ParagraphBuilder(ui.ParagraphStyle());
  for (final (text, style) in spans) {
    builder
      ..pushStyle(style)
      ..addText(text)
      ..pop();
  }
  final paragraph = builder.build()
    ..layout(const ui.ParagraphConstraints(width: 2000));
  final width = paragraph.maxIntrinsicWidth;
  final dx = switch (anchor) {
    _Anchor.start => x,
    _Anchor.center => x - width / 2,
    _Anchor.end => x - width,
  };
  canvas.drawParagraph(
    paragraph,
    ui.Offset(dx, baseline - paragraph.alphabeticBaseline),
  );
  paragraph.dispose();
  return width;
}

String _fixed(double value, int digits) {
  final text = value.toStringAsFixed(digits);
  final isNegativeZero = double.parse(text) == 0 && text.startsWith('-');
  return isNegativeZero ? text.substring(1) : text;
}

ui.Paint _stroke(ui.Color color, [double width = 1.0]) => ui.Paint()
  ..style = ui.PaintingStyle.stroke
  ..strokeWidth = width
  ..color = color;

void _paintSheet(ui.Canvas canvas, ui.Size size) {
  final sheet = ui.RRect.fromRectAndRadius(
    ui.Offset.zero & size,
    const ui.Radius.circular(_sheetRadius),
  ).deflate(0.5);
  canvas.drawRRect(sheet, ui.Paint()..color = _paper);
  canvas.drawRRect(sheet, _stroke(_hairline));
}

/// Dotted drafting grid, clipped to [area], that marks where specimens live.
void _paintStage(ui.Canvas canvas, ui.Rect area) {
  final dot = ui.Paint()..color = _gridDot;
  canvas.save();
  canvas.clipRect(area);
  final startX = (area.left / _gridStep).ceil() * _gridStep;
  final startY = (area.top / _gridStep).ceil() * _gridStep;
  for (var x = startX; x <= area.right; x += _gridStep) {
    for (var y = startY; y <= area.bottom; y += _gridStep) {
      canvas.drawCircle(ui.Offset(x, y), 0.75, dot);
    }
  }
  canvas.restore();
}

/// Splits a sheet into columns with header, dotted stage, and code footer.
List<ui.Rect> _paintCells(
  ui.Canvas canvas,
  ui.Size size,
  List<(String index, String api, String title)> headers,
) {
  _paintSheet(canvas, size);
  final cellWidth = size.width / headers.length;
  final footerTop = size.height - _footerHeight;

  final footer = ui.Path()
    ..addRRect(
      ui.RRect.fromLTRBAndCorners(
        0.5,
        footerTop,
        size.width - 0.5,
        size.height - 0.5,
        bottomLeft: const ui.Radius.circular(_sheetRadius),
        bottomRight: const ui.Radius.circular(_sheetRadius),
      ),
    );
  canvas.drawPath(footer, ui.Paint()..color = _surface);
  canvas.drawLine(
    ui.Offset(0.5, footerTop),
    ui.Offset(size.width - 0.5, footerTop),
    _stroke(_hairline),
  );

  final cells = <ui.Rect>[];
  for (var i = 0; i < headers.length; i++) {
    final cell = ui.Rect.fromLTWH(i * cellWidth, 0, cellWidth, size.height);
    cells.add(cell);
    if (i > 0) {
      canvas.drawLine(
        ui.Offset(cell.left, 0.5),
        ui.Offset(cell.left, size.height - 0.5),
        _stroke(_hairline),
      );
    }
    _paintStage(
      canvas,
      ui.Rect.fromLTRB(cell.left + 1, 82, cell.right - 1, footerTop - 1),
    );

    final (index, api, title) = headers[i];
    _text(
      canvas,
      [
        (index, _mono(10.5, weight: 600, color: _accent)),
        ('   $api', _mono(10.5, color: _muted)),
      ],
      x: cell.left + _pad,
      baseline: 36,
    );
    _text(canvas, [(title, _serif(21))], x: cell.left + _pad, baseline: 63);
  }
  return cells;
}

void _paintFooterCode(ui.Canvas canvas, ui.Rect cell, List<_Span> spans) {
  _text(canvas, spans, x: cell.left + _pad, baseline: cell.bottom - 17);
}

_Span _codeKey(String text) => (text, _mono(11.5, color: _muted));
_Span _codeValue(String text, {bool highlight = true}) => (
  text,
  _mono(11.5, weight: highlight ? 600 : 450, color: highlight ? _accent : _ink),
);

/// A dimension callout: a pin on the measured band and a leader to a label.
void _paintLeader(
  ui.Canvas canvas, {
  required ui.Offset pin,
  required ui.Offset end,
  required String name,
  required String value,
  required _Anchor anchor,
  required double labelX,
  required double baseline,
}) {
  canvas.drawLine(pin, end, _stroke(_ink));
  canvas.drawCircle(pin, 3.0, ui.Paint()..color = _paper);
  canvas.drawCircle(pin, 2.0, ui.Paint()..color = _ink);
  _text(
    canvas,
    [('$name ', _mono(11, color: _muted)), (value, _mono(11, weight: 600))],
    x: labelX,
    baseline: baseline,
    anchor: anchor,
  );
}

void _paintDashedRRect(ui.Canvas canvas, ui.RRect rrect, ui.Paint paint) {
  const dash = 3.0;
  const gap = 3.0;
  final path = ui.Path()..addRRect(rrect);
  for (final metric in path.computeMetrics()) {
    for (var d = 0.0; d < metric.length; d += dash + gap) {
      canvas.drawPath(metric.extractPath(d, d + dash), paint);
    }
  }
}

void _paintShape(
  ui.Canvas canvas,
  ui.Rect rect,
  NonUniformBorder border,
  ui.Color fill,
) {
  border.paintInterior(canvas, rect, ui.Paint()..color = fill);
  border.paint(canvas, rect);
}

double _ease(double x) {
  final t = x.clamp(0.0, 1.0);
  return t < 0.5 ? 4 * t * t * t : 1 - math.pow(-2 * t + 2, 3) / 2;
}

/// Splits the loop into [steps] equal beats that hold, then ease to the next.
/// Returns the beat index and its eased transition progress.
(int, double) _beat(double t, int steps, {double hold = 0.5}) {
  final scaled = t * steps;
  final step = scaled.floor() % steps;
  final local = scaled - scaled.floor();
  return (step, _ease((local - hold) / (1 - hold)));
}

/// Weight of [index] while a beat moves emphasis from `step` to `step + 1`.
double _beatWeight(int index, int count, int step, double progress) {
  if (index == step) return 1 - progress;
  if (index == (step + 1) % count) return progress;
  return 0;
}

Future<void> _savePng(
  ui.PictureRecorder recorder,
  ui.Size size,
  String path,
) async {
  final picture = recorder.endRecording();
  final image = await picture.toImage(
    (size.width * _dpr).round(),
    (size.height * _dpr).round(),
  );
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path)
    ..parent.createSync(recursive: true)
    ..writeAsBytesSync(byteData!.buffer.asUint8List());
  image.dispose();
  picture.dispose();
}

Future<void> _render(
  ui.Size size,
  String path,
  void Function(ui.Canvas canvas) paint,
) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder)..scale(_dpr, _dpr);
  paint(canvas);
  await _savePng(recorder, size, path);
}

Future<void> _renderFrames(
  ui.Size size,
  String directory,
  void Function(ui.Canvas canvas, double t) paint,
) async {
  for (var frame = 0; frame < _frames; frame++) {
    final name = frame.toString().padLeft(4, '0');
    await _render(
      size,
      '$directory/frame_$name.png',
      (canvas) => paint(canvas, frame / _frames),
    );
  }
}

Future<void> _loadFonts() async {
  Future<void> load(String family, String path) async {
    final file = File(path);
    if (!file.existsSync()) {
      throw StateError('Missing font for "$family": $path');
    }
    final loader = FontLoader(family)
      ..addFont(Future.value(ByteData.sublistView(file.readAsBytesSync())));
    await loader.load();
  }

  await load('Serif', '/System/Library/Fonts/NewYork.ttf');
  await load('Sans', '/System/Library/Fonts/SFNS.ttf');
  await load('Mono', '/System/Library/Fonts/SFNSMono.ttf');
}

const ui.Size _heroSize = ui.Size(_width, 264);

void _paintHero(ui.Canvas canvas) {
  _paintSheet(canvas, _heroSize);
  _paintStage(canvas, const ui.Rect.fromLTRB(400, 1, _width - 1, 263));
  canvas.drawLine(
    const ui.Offset(400, 0.5),
    const ui.Offset(400, 263.5),
    _stroke(_hairline),
  );

  _text(
    canvas,
    [
      ('●  ', _mono(9, color: _accent)),
      ('non_uniform_border', _mono(11, color: _muted)),
    ],
    x: 40,
    baseline: 56,
  );
  _text(canvas, [('NonUniformBorder', _serif(36))], x: 38, baseline: 104);
  _text(
    canvas,
    [('Give every side its own width,', _sans(15.5, color: _muted))],
    x: 40,
    baseline: 140,
  );
  _text(
    canvas,
    [('and keep your borderRadius.', _sans(15.5, color: _muted))],
    x: 40,
    baseline: 162,
  );

  canvas.drawLine(
    const ui.Offset(40, 194),
    const ui.Offset(360, 194),
    _stroke(_hairline),
  );
  _text(
    canvas,
    [
      ('NonUniformBorder', _mono(11.5)),
      ('(', _mono(11.5, color: _muted)),
      ('bottomWidth: ', _mono(11.5, color: _muted)),
      ('16', _mono(11.5, weight: 600, color: _accent)),
      (', …)', _mono(11.5, color: _muted)),
    ],
    x: 40,
    baseline: 222,
  );

  const specimen = ui.Rect.fromLTWH(504, 82, 160, 100);
  const border = NonUniformBorder(
    leftWidth: 8,
    topWidth: 2,
    rightWidth: 4,
    bottomWidth: 16,
    color: _accent,
    borderRadius: BorderRadius.all(Radius.circular(24)),
  );
  _paintShape(canvas, specimen, border, _white);

  final cx = specimen.center.dx;
  final cy = specimen.center.dy;
  _paintLeader(
    canvas,
    pin: ui.Offset(cx, specimen.top + 1),
    end: ui.Offset(cx, specimen.top - 30),
    name: 'top',
    value: '2',
    anchor: _Anchor.start,
    labelX: cx + 8,
    baseline: specimen.top - 26,
  );
  _paintLeader(
    canvas,
    pin: ui.Offset(cx, specimen.bottom - 8),
    end: ui.Offset(cx, specimen.bottom + 30),
    name: 'bottom',
    value: '16',
    anchor: _Anchor.start,
    labelX: cx + 8,
    baseline: specimen.bottom + 30,
  );
  _paintLeader(
    canvas,
    pin: ui.Offset(specimen.left + 4, cy),
    end: ui.Offset(specimen.left - 28, cy),
    name: 'left',
    value: '8',
    anchor: _Anchor.end,
    labelX: specimen.left - 34,
    baseline: cy + 4,
  );
  _paintLeader(
    canvas,
    pin: ui.Offset(specimen.right - 2, cy),
    end: ui.Offset(specimen.right + 28, cy),
    name: 'right',
    value: '4',
    anchor: _Anchor.start,
    labelX: specimen.right + 34,
    baseline: cy + 4,
  );
}

const ui.Size _showcaseSize = ui.Size(_width, 300);

void _paintShowcase(ui.Canvas canvas, double t) {
  final cells = _paintCells(canvas, _showcaseSize, const [
    ('01', 'bottomWidth', 'Press depth'),
    ('02', 'leftWidth + lerp', 'Active rail'),
  ]);
  _paintKeycap(canvas, cells[0], t);
  _paintRail(canvas, cells[1], t);
}

void _paintKeycap(ui.Canvas canvas, ui.Rect cell, double t) {
  final (step, progress) = _beat(t, 4, hold: 0.55);
  final press = step.isEven ? progress : 1 - progress;

  const restDepth = 12.0;
  const pressedDepth = 3.0;
  final depth = ui.lerpDouble(restDepth, pressedDepth, press)!;
  const base = 202.0;
  final rect = ui.Rect.fromLTRB(
    cell.left + 64,
    base - 66 + (restDepth - depth),
    cell.left + 252,
    base,
  );
  _paintShape(
    canvas,
    rect,
    NonUniformBorder(
      leftWidth: 1.5,
      topWidth: 1.5,
      rightWidth: 1.5,
      bottomWidth: depth,
      color: _accentDeep,
      borderRadius: const BorderRadius.all(Radius.circular(16)),
    ),
    ui.Color.lerp(_accent, const ui.Color(0xFFD24A26), press)!,
  );
  final faceCenter = (rect.top + rect.bottom - depth) / 2;
  _text(
    canvas,
    [('Continue  →', _sans(15, weight: 600, color: _white))],
    x: rect.center.dx,
    baseline: faceCenter + 5,
    anchor: _Anchor.center,
  );
  final pinY = rect.bottom - depth / 2;
  _paintLeader(
    canvas,
    pin: ui.Offset(rect.right - 32, pinY),
    end: ui.Offset(rect.right + 20, pinY),
    name: 'bottom',
    value: _fixed(depth, 0),
    anchor: _Anchor.start,
    labelX: rect.right + 26,
    baseline: pinY + 4,
  );

  _paintFooterCode(canvas, cell, [
    _codeKey('bottomWidth: '),
    _codeValue(_fixed(depth, 1)),
  ]);
}

void _paintRail(ui.Canvas canvas, ui.Rect cell, double t) {
  const items = [('Inbox', '24'), ('Drafts', '3'), ('Archive', '—')];
  final (step, progress) = _beat(t, items.length, hold: 0.55);

  const idle = NonUniformBorder.all(
    width: 1,
    color: _hairline,
    borderRadius: BorderRadius.all(Radius.circular(12)),
  );
  const active = NonUniformBorder(
    leftWidth: 6,
    topWidth: 1.5,
    rightWidth: 1.5,
    bottomWidth: 1.5,
    color: _accent,
    borderRadius: BorderRadius.all(Radius.circular(12)),
  );

  for (var i = 0; i < items.length; i++) {
    final weight = _beatWeight(i, items.length, step, progress);
    final row = ui.Rect.fromLTWH(
      cell.left + _pad,
      96 + i * 50.0,
      cell.width - _pad * 2,
      42,
    );
    final border = NonUniformBorder.lerp(idle, active, weight)!;
    _paintShape(
      canvas,
      row,
      border,
      ui.Color.lerp(_white, _accentTint, weight)!,
    );

    final (label, count) = items[i];
    _text(
      canvas,
      [(label, _sans(13.5, weight: 500))],
      x: row.left + 14 + border.leftWidth,
      baseline: row.center.dy + 4.5,
    );
    _text(
      canvas,
      [(count, _mono(11, color: ui.Color.lerp(_muted, _accentDeep, weight)!))],
      x: row.right - 16,
      baseline: row.center.dy + 4,
      anchor: _Anchor.end,
    );
  }

  _paintFooterCode(canvas, cell, [
    ('NonUniformBorder', _mono(11.5)),
    _codeKey('.lerp(idle, active, '),
    _codeValue(_fixed(progress, 2)),
    _codeKey(')'),
  ]);
}

const ui.Size _propertiesSize = ui.Size(_width, 300);

void _paintProperties(ui.Canvas canvas, double t) {
  final cells = _paintCells(canvas, _propertiesSize, const [
    ('03', 'left/top/right/bottomWidth', 'Every side'),
    ('04', 'borderRadius', 'Any corner'),
    ('05', 'strokeAlign', 'Inside or out'),
  ]);
  final (step, progress) = _beat(t, 4, hold: 0.45);
  final weights = [
    for (var i = 0; i < 4; i++) _beatWeight(i, 4, step, progress),
  ];

  ui.Rect specimenIn(ui.Rect cell) => ui.Rect.fromCenter(
    center: ui.Offset(cell.center.dx, 166),
    width: 136,
    height: 80,
  );

  List<_Span> quad(List<String> names, List<double> values) {
    final emphasized = weights.indexOf(weights.reduce(math.max));
    return [
      for (var i = 0; i < 4; i++) ...[
        _codeKey('${i == 0 ? '' : '  '}${names[i]} '),
        _codeValue(_fixed(values[i], 0), highlight: i == emphasized),
      ],
    ];
  }

  // Emphasis travels clockwise from the top side.
  final widths = [for (final w in weights) 2 + 12 * w];
  final (top, right, bottom, left) = (
    widths[0],
    widths[1],
    widths[2],
    widths[3],
  );
  _paintShape(
    canvas,
    specimenIn(cells[0]),
    NonUniformBorder(
      leftWidth: left,
      topWidth: top,
      rightWidth: right,
      bottomWidth: bottom,
      color: _accent,
      borderRadius: const BorderRadius.all(Radius.circular(18)),
    ),
    _white,
  );
  _paintFooterCode(
    canvas,
    cells[0],
    quad(['T', 'R', 'B', 'L'], [top, right, bottom, left]),
  );

  // Emphasis travels clockwise from the top-left corner.
  final radii = [for (final w in weights) 6 + 32 * w];
  _paintShape(
    canvas,
    specimenIn(cells[1]),
    NonUniformBorder.symmetric(
      verticalWidth: 7,
      horizontalWidth: 2.5,
      color: _accent,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(radii[0]),
        topRight: Radius.circular(radii[1]),
        bottomRight: Radius.circular(radii[2]),
        bottomLeft: Radius.circular(radii[3]),
      ),
    ),
    _white,
  );
  _paintFooterCode(canvas, cells[1], quad(['TL', 'TR', 'BR', 'BL'], radii));

  const alignStops = [-1.0, 0.0, 1.0, 0.0];
  final align = ui.lerpDouble(
    alignStops[step],
    alignStops[(step + 1) % 4],
    progress,
  )!;
  final alignRect = specimenIn(cells[2]);
  _paintShape(
    canvas,
    alignRect,
    NonUniformBorder.symmetric(
      verticalWidth: 12,
      horizontalWidth: 5,
      color: _accent,
      strokeAlign: align,
      borderRadius: const BorderRadius.all(Radius.circular(18)),
    ),
    _white,
  );
  _paintDashedRRect(
    canvas,
    ui.RRect.fromRectAndRadius(alignRect, const ui.Radius.circular(18)),
    _stroke(_ink),
  );
  final alignName = align < -0.5
      ? 'inside'
      : align > 0.5
      ? 'outside'
      : 'center';
  _paintFooterCode(canvas, cells[2], [
    _codeKey('strokeAlign '),
    _codeValue(_fixed(align, 2)),
    _codeKey('  $alignName'),
  ]);
}

void main() {
  test('render non_uniform_border README assets', () async {
    await _loadFonts();

    await _render(_heroSize, 'assets/NonUniformBorder.png', _paintHero);
    await _renderFrames(
      _showcaseSize,
      'build/readme_frames/showcase',
      _paintShowcase,
    );
    await _renderFrames(
      _propertiesSize,
      'build/readme_frames/example',
      _paintProperties,
    );
  });
}
