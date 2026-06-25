import 'package:flutter/material.dart';

import '../controllers/hue_app_controller.dart';
import '../models/hue_light.dart';
import '../services/color_utils.dart';
import '../theme/app_colors.dart';
import '../widgets/color_picker_dialog.dart';
import '../widgets/connection_panel.dart';
import '../widgets/group_controls.dart';
import '../widgets/light_card.dart';
import '../widgets/surface_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.controller});

  final HueAppController controller;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final TextEditingController _ipController;

  @override
  void initState() {
    super.initState();
    _ipController = TextEditingController(text: widget.controller.ipAddress);
    widget.controller.addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    if (_ipController.text != widget.controller.ipAddress) {
      _ipController.text = widget.controller.ipAddress;
    }
    setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerUpdate);
    _ipController.dispose();
    super.dispose();
  }

  Color _statusColor() {
    switch (widget.controller.statusTone) {
      case StatusTone.error:
        return AppColors.danger;
      case StatusTone.success:
        return AppColors.success;
      case StatusTone.party:
        return AppColors.party;
      case StatusTone.partyStopped:
      case StatusTone.normal:
        return AppColors.textMuted;
    }
  }

  Future<void> _discover() async {
    final ip = await widget.controller.discover();
    if (!mounted) return;
    if (ip != null) {
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Autowykrywanie'),
          content: Text(
            'Znaleziono mostek Philips Hue!\n\nAdres IP: $ip\n\n'
            'Wciśnij przycisk parowania na mostku, a następnie kliknij „Paruj”.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
      );
    } else {
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Autowykrywanie'),
          content: const Text(
            'Nie udało się wykryć mostka automatycznie.\n'
            'Upewnij się, że komputer i mostek są w tej samej sieci.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
      );
    }
  }

  Future<void> _pair() async {
    widget.controller.ipAddress = _ipController.text;
    final result = await widget.controller.pair(_ipController.text);
    if (!mounted) return;
    if (result.success) {
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Parowanie'),
          content: const Text('Aplikacja została pomyślnie sparowana z mostkiem Philips Hue!'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
      );
    } else if (result.error != null) {
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Błąd parowania'),
          content: Text(result.error!),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
      );
    }
  }

  Future<void> _party() async {
    try {
      await widget.controller.toggleParty();
    } on StateError catch (e) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Impreza'),
          content: Text(e.message),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
      );
    }
  }

  Future<void> _groupPower(bool on) async {
    try {
      await widget.controller.groupPower(on);
    } catch (e) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Błąd sterowania grupowego'),
          content: Text(e.toString()),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
      );
    }
  }

  Future<void> _pickColor(HueLight light) async {
    final hex = ColorUtils.hsvToHex(light.state.hue ?? 0, light.state.sat ?? 0, light.state.bri);
    final initial = ColorUtils.hexToColor(hex);
    final picked = await ColorPickerDialog.show(context, initial);
    if (picked == null) return;
    try {
      await widget.controller.chooseColor(
        light.id,
        picked.r * 255,
        picked.g * 255,
        picked.b * 255,
      );
    } catch (e) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Błąd zmiany koloru'),
          content: Text('Nie udało się zmienić koloru: $e'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final lights = controller.lights.entries.toList()
      ..sort((a, b) => int.parse(a.key).compareTo(int.parse(b.key)));

    return Scaffold(
      backgroundColor: AppColors.windowBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/icons/lumigrzyb.png',
                            width: 52,
                            height: 52,
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.medium,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Sterowanie oświetleniem', style: Theme.of(context).textTheme.headlineMedium),
                              const SizedBox(height: 4),
                              Text(
                                controller.statusMessage,
                                style: TextStyle(color: _statusColor(), fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  ConnectionPanel(
                    controller: controller,
                    ipController: _ipController,
                    onDiscover: _discover,
                    onPair: _pair,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GroupControls(
                controller: controller,
                onAllOn: () => _groupPower(true),
                onAllOff: () => _groupPower(false),
                onParty: _party,
                onBrightness: controller.onGroupBrightness,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('Podłączone lampy', style: Theme.of(context).textTheme.titleMedium),
                  const Spacer(),
                  Text(
                    ColorUtils.lightsCountLabel(lights.length),
                    style: const TextStyle(color: AppColors.textDim, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Expanded(
                child: SurfaceCard(
                  padding: const EdgeInsets.all(8),
                  child: lights.isEmpty
                      ? const Center(
                          child: Text(
                            'Brak lamp — sparuj się z mostkiem Hue.',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        )
                      : ListView.builder(
                          itemCount: lights.length,
                          itemBuilder: (_, i) {
                            final entry = lights[i];
                            final light = entry.value;
                            return LightCard(
                              light: light,
                              isDebouncingBri: controller.isDebouncing(light.id, 'bri'),
                              isDebouncingCt: controller.isDebouncing(light.id, 'ct'),
                              onToggle: (on) async {
                                try {
                                  await controller.toggleLight(light.id, on);
                                } catch (e) {
                                  if (!context.mounted) return;
                                  await showDialog<void>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text('Błąd sterowania'),
                                      content: Text('Nie udało się zmienić zasilania: $e'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                              onBriChange: (v) => controller.onSliderMove(light.id, 'bri', v),
                              onCtChange: (v) => controller.onSliderMove(light.id, 'ct', v),
                              onPickColor: () => _pickColor(light),
                            );
                          },
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
