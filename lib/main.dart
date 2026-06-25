import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';

import 'controllers/hue_app_controller.dart';
import 'screens/home_screen.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _applyWindowBackdrop();
  runApp(const HueControllerApp());
}

/// Włącza rozmazane, półprzezroczyste tło w stylu WinUI 3 (Acrylic).
Future<void> _applyWindowBackdrop() async {
  try {
    await Window.initialize();
    await Window.setEffect(
      effect: WindowEffect.acrylic,
      color: AppColors.acrylicTint,
      dark: true,
    );
  } catch (_) {
    // Efekt niedostępny (np. starszy system) — aplikacja działa dalej z tłem bazowym.
  }
}

class HueControllerApp extends StatefulWidget {
  const HueControllerApp({super.key});

  @override
  State<HueControllerApp> createState() => _HueControllerAppState();
}

class _HueControllerAppState extends State<HueControllerApp> {
  late final HueAppController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HueAppController();
  }

  @override
  void dispose() {
    _controller.disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LumiGrzyb',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: HomeScreen(controller: _controller),
    );
  }
}
