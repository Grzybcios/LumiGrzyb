import 'package:flutter/material.dart';

import '../controllers/hue_app_controller.dart';
import '../theme/app_colors.dart';
import 'app_button.dart';
import 'surface_card.dart';

class GroupControls extends StatelessWidget {
  const GroupControls({
    super.key,
    required this.controller,
    required this.onAllOn,
    required this.onAllOff,
    required this.onParty,
    required this.onBrightness,
  });

  final HueAppController controller;
  final VoidCallback onAllOn;
  final VoidCallback onAllOff;
  final VoidCallback onParty;
  final ValueChanged<double> onBrightness;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel(text: 'Sterowanie grupowe'),
        SurfaceCard(
          child: Row(
            children: [
              AppButton(label: 'Wszystkie ON', variant: AppButtonVariant.success, onPressed: onAllOn),
              const SizedBox(width: 8),
              AppButton(label: 'Wszystkie OFF', variant: AppButtonVariant.danger, onPressed: onAllOff),
              const SizedBox(width: 8),
              AppButton(
                label: controller.partyRunning ? 'Zatrzymaj' : 'Impreza',
                variant: controller.partyRunning ? AppButtonVariant.danger : AppButtonVariant.party,
                onPressed: onParty,
              ),
              const SizedBox(width: 24),
              const Text('Jasność', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
              const SizedBox(width: 10),
              Expanded(
                child: Slider(
                  min: 1,
                  max: 254,
                  value: controller.globalBrightness.toDouble(),
                  onChanged: onBrightness,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 36,
                child: Text(
                  '${controller.globalBrightness}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
