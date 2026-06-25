import 'package:flutter/material.dart';

import '../controllers/hue_app_controller.dart';
import '../theme/app_colors.dart';
import 'app_button.dart';
import 'surface_card.dart';

class ConnectionPanel extends StatelessWidget {
  const ConnectionPanel({
    super.key,
    required this.controller,
    required this.ipController,
    required this.onDiscover,
    required this.onPair,
  });

  final HueAppController controller;
  final TextEditingController ipController;
  final VoidCallback onDiscover;
  final VoidCallback onPair;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Połączenie z mostkiem',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          AppButton(
            label: controller.connDetailsVisible ? 'Ukryj adres IP' : 'Pokaż adres IP',
            variant: AppButtonVariant.secondary,
            onPressed: controller.toggleConnDetails,
          ),
          if (controller.connDetailsVisible) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Adres IP', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                const SizedBox(width: 10),
                SizedBox(
                  width: 150,
                  child: TextField(
                    controller: ipController,
                    style: const TextStyle(color: AppColors.text, fontSize: 13),
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: AppColors.cardElevatedOpaque,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AppButton(
                  label: 'Wykryj',
                  variant: AppButtonVariant.secondary,
                  enabled: !controller.isDiscovering,
                  onPressed: onDiscover,
                ),
                const SizedBox(width: 8),
                AppButton(
                  label: 'Paruj',
                  variant: AppButtonVariant.primary,
                  enabled: !controller.isPairing,
                  onPressed: onPair,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
