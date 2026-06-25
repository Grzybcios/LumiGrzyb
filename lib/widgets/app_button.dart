import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum AppButtonVariant { secondary, primary, success, danger, party }

class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.secondary,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool enabled;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _hovered = false;

  ({Color bg, Color fg, Color hover}) _colors() {
    switch (widget.variant) {
      case AppButtonVariant.primary:
        return (bg: AppColors.primary, fg: AppColors.text, hover: AppColors.primaryHover);
      case AppButtonVariant.success:
        return (bg: AppColors.success, fg: AppColors.text, hover: const Color(0xFF28B84C));
      case AppButtonVariant.danger:
        return (bg: AppColors.danger, fg: AppColors.text, hover: const Color(0xFFE0352B));
      case AppButtonVariant.party:
        return (bg: AppColors.party, fg: AppColors.text, hover: AppColors.partyHover);
      case AppButtonVariant.secondary:
        return (
          bg: AppColors.btnSecondary,
          fg: AppColors.text,
          hover: AppColors.btnSecondaryHover,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _colors();
    final bg = !widget.enabled
        ? AppColors.btnSecondary.withValues(alpha: 0.5)
        : (_hovered ? c.hover : c.bg);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.enabled ? widget.onPressed : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
            boxShadow: _hovered && widget.enabled
                ? [
                    BoxShadow(
                      color: bg.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: widget.enabled ? c.fg : AppColors.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
