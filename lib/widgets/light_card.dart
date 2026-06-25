import 'package:flutter/material.dart';

import '../models/hue_light.dart';
import '../services/color_utils.dart';
import '../theme/app_colors.dart';
import 'app_button.dart';

class LightCard extends StatelessWidget {
  const LightCard({
    super.key,
    required this.light,
    required this.isDebouncingBri,
    required this.isDebouncingCt,
    required this.onToggle,
    required this.onBriChange,
    required this.onCtChange,
    required this.onPickColor,
  });

  final HueLight light;
  final bool isDebouncingBri;
  final bool isDebouncingCt;
  final ValueChanged<bool> onToggle;
  final ValueChanged<double> onBriChange;
  final ValueChanged<double> onCtChange;
  final VoidCallback onPickColor;

  @override
  Widget build(BuildContext context) {
    final state = light.state;
    final reachable = state.reachable;
    final accentColor = state.on && reachable ? AppColors.success : AppColors.separator;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.cardElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 3,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                light.name,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    '●',
                                    style: TextStyle(
                                      color: reachable ? AppColors.success : AppColors.offline,
                                      fontSize: 10,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    reachable ? 'Dostępna' : 'Niedostępna',
                                    style: TextStyle(
                                      color: reachable ? AppColors.success : AppColors.offline,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        AppButton(
                          label: state.on ? 'Wł.' : 'Wył.',
                          variant: state.on ? AppButtonVariant.success : AppButtonVariant.secondary,
                          enabled: reachable,
                          onPressed: () => onToggle(!state.on),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _SliderRow(
                      label: 'Jasność',
                      value: state.bri.toDouble(),
                      min: 1,
                      max: 254,
                      accent: AppColors.accent,
                      enabled: reachable,
                      onChanged: onBriChange,
                    ),
                    if (state.supportsCt)
                      _SliderRow(
                        label: 'Temperatura',
                        value: (state.ct ?? 300).toDouble(),
                        min: 153,
                        max: 500,
                        accent: AppColors.primary,
                        enabled: reachable,
                        onChanged: onCtChange,
                      ),
                    if (state.supportsColor) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const SizedBox(
                            width: 72,
                            child: Text('Kolor', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                          ),
                          GestureDetector(
                            onTap: reachable ? onPickColor : null,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: ColorUtils.hexToColor(
                                  ColorUtils.hsvToHex(state.hue ?? 0, state.sat ?? 0, state.bri),
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.separator),
                              ),
                              child: Text(
                                'Wybierz kolor',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: (state.bri < 130) ? Colors.white : AppColors.text,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.accent,
    required this.enabled,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final Color accent;
  final bool enabled;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
          ),
          Expanded(
            child: Slider(
              min: min,
              max: max,
              value: value.clamp(min, max),
              onChanged: enabled ? onChanged : null,
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              value.round().toString(),
              textAlign: TextAlign.right,
              style: TextStyle(color: accent, fontWeight: FontWeight.w700, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
