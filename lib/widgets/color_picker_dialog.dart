import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

const presetColors = [
  Color(0xFFFF6B6B), Color(0xFFFF8E53), Color(0xFFFFD93D), Color(0xFF6BCB77),
  Color(0xFF4D96FF), Color(0xFF8B7CF6), Color(0xFFE056FD), Color(0xFFFF85A2),
  Color(0xFF00D2FF), Color(0xFFF8F9FA), Color(0xFFFFB347), Color(0xFFFF4757),
  Color(0xFF2ED573), Color(0xFF1E90FF), Color(0xFFA29BFE), Color(0xFFFD79A8),
  Color(0xFFFDCB6E), Color(0xFF00B894), Color(0xFFE17055), Color(0xFF74B9FF),
];

/// Odpowiednik color_picker.py — dialog wyboru koloru.
class ColorPickerDialog extends StatefulWidget {
  const ColorPickerDialog({super.key, required this.initialColor});

  final Color initialColor;

  static Future<Color?> show(BuildContext context, Color initial) {
    return showDialog<Color>(
      context: context,
      builder: (_) => ColorPickerDialog(initialColor: initial),
    );
  }

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late HSVColor _hsv;
  late TextEditingController _hexController;

  @override
  void initState() {
    super.initState();
    _hsv = HSVColor.fromColor(widget.initialColor);
    _hexController = TextEditingController(text: _colorToHex(_hsv.toColor()));
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  String _colorToHex(Color c) =>
      '#${c.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

  void _updateFromHsv() {
    _hexController.text = _colorToHex(_hsv.toColor());
    setState(() {});
  }

  void _applyHex(String raw) {
    final cleaned = raw.trim().replaceAll('#', '');
    if (cleaned.length != 6) return;
    try {
      final color = Color(int.parse('FF$cleaned', radix: 16));
      _hsv = HSVColor.fromColor(color);
      _updateFromHsv();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final preview = _hsv.toColor();
    final rgb = preview;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Wybierz kolor lampy',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SvPicker(
                    hue: _hsv.hue,
                    saturation: _hsv.saturation,
                    value: _hsv.value,
                    onChanged: (s, v) {
                      _hsv = _hsv.withSaturation(s).withValue(v);
                      _updateFromHsv();
                    },
                  ),
                  const SizedBox(width: 12),
                  _HueBar(
                    hue: _hsv.hue,
                    onChanged: (h) {
                      _hsv = _hsv.withHue(h);
                      _updateFromHsv();
                    },
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 72,
                        height: 56,
                        decoration: BoxDecoration(
                          color: preview,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text('HEX', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 100,
                        child: TextField(
                          controller: _hexController,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            isDense: true,
                            filled: true,
                            fillColor: AppColors.cardElevated,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onSubmitted: _applyHex,
                          onEditingComplete: () => _applyHex(_hexController.text),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'RGB ${(rgb.r * 255).round()}, ${(rgb.g * 255).round()}, ${(rgb.b * 255).round()}',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Jasność', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: _hsv.value,
                            onChanged: (v) {
                              _hsv = _hsv.withValue(v);
                              _updateFromHsv();
                            },
                          ),
                        ),
                        Text('${(_hsv.value * 100).round()}%'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text('SZYBKI WYBÓR', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: presetColors.map((c) {
                  return GestureDetector(
                    onTap: () {
                      _hsv = HSVColor.fromColor(c);
                      _updateFromHsv();
                    },
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: c,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.border),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Anuluj')),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.text,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onPressed: () => Navigator.pop(context, preview),
                    child: const Text('Zastosuj'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SvPicker extends StatelessWidget {
  const _SvPicker({
    required this.hue,
    required this.saturation,
    required this.value,
    required this.onChanged,
  });

  final double hue;
  final double saturation;
  final double value;
  final void Function(double s, double v) onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (d) => _handle(d.localPosition),
      onPanUpdate: (d) => _handle(d.localPosition),
      child: CustomPaint(
        size: const Size(220, 160),
        painter: _SvPainter(hue: hue, markerS: saturation, markerV: value),
      ),
    );
  }

  void _handle(Offset pos) {
    const w = 220.0;
    const h = 160.0;
    onChanged((pos.dx / w).clamp(0.0, 1.0), (1 - pos.dy / h).clamp(0.0, 1.0));
  }
}

class _SvPainter extends CustomPainter {
  _SvPainter({required this.hue, required this.markerS, required this.markerV});

  final double hue;
  final double markerS;
  final double markerV;

  @override
  void paint(Canvas canvas, Size size) {
    for (var y = 0; y < size.height; y++) {
      final v = 1 - y / size.height;
      for (var x = 0; x < size.width; x++) {
        final s = x / size.width;
        final paint = Paint()
          ..color = HSVColor.fromAHSV(1, hue, s, v).toColor();
        canvas.drawRect(Rect.fromLTWH(x.toDouble(), y.toDouble(), 1, 1), paint);
      }
    }
    final mx = markerS * size.width;
    final my = (1 - markerV) * size.height;
    canvas.drawCircle(Offset(mx, my), 7, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(mx, my), 5, Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(covariant _SvPainter old) =>
      old.hue != hue || old.markerS != markerS || old.markerV != markerV;
}

class _HueBar extends StatelessWidget {
  const _HueBar({required this.hue, required this.onChanged});

  final double hue;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (d) => onChanged((d.localPosition.dy / 160 * 360).clamp(0, 360)),
      onPanUpdate: (d) => onChanged((d.localPosition.dy / 160 * 360).clamp(0, 360)),
      child: CustomPaint(
        size: const Size(24, 160),
        painter: _HuePainter(markerHue: hue),
      ),
    );
  }
}

class _HuePainter extends CustomPainter {
  _HuePainter({required this.markerHue});
  final double markerHue;

  @override
  void paint(Canvas canvas, Size size) {
    for (var y = 0; y < size.height; y++) {
      final h = y / size.height * 360;
      canvas.drawRect(
        Rect.fromLTWH(0, y.toDouble(), size.width, 1),
        Paint()..color = HSVColor.fromAHSV(1, h, 1, 1).toColor(),
      );
    }
    final my = markerHue / 360 * size.height;
    canvas.drawLine(Offset(0, my), Offset(size.width, my), Paint()..color = Colors.white..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(covariant _HuePainter old) => old.markerHue != markerHue;
}
