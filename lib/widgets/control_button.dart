import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class ControlButton extends StatefulWidget {
  final String label;
  final String? sublabel;
  final Color color;
  final VoidCallback? onPressed;
  final bool enabled;
  final IconData? icon;
  final bool outlined;

  const ControlButton({
    super.key,
    required this.label,
    this.sublabel,
    required this.color,
    this.onPressed,
    this.enabled = true,
    this.icon,
    this.outlined = false,
  });

  @override
  State<ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<ControlButton> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 80),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.enabled && widget.onPressed != null) {
      _scaleController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _scaleController.reverse();
  }

  void _handleTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.enabled && widget.onPressed != null;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: isEnabled ? widget.onPressed : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          height: widget.sublabel != null ? 72 : (widget.outlined ? 48 : 56),
          decoration: BoxDecoration(
            color: widget.outlined
                ? Colors.transparent
                : (isEnabled ? widget.color : widget.color.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
            border: widget.outlined
                ? Border.all(
                    color: isEnabled ? AppColors.bgCardBorder : AppColors.bgCardBorder.withOpacity(0.5),
                    width: 1.5,
                  )
                : null,
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    color: widget.outlined
                        ? (isEnabled ? AppColors.textPrimary : AppColors.textMuted)
                        : AppColors.bg,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                ],
                if (widget.sublabel != null)
                  Text(
                    widget.sublabel!,
                    style: GoogleFonts.bebasNeue(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: widget.outlined
                          ? (isEnabled ? AppColors.textPrimary : AppColors.textMuted)
                          : AppColors.bg,
                    ),
                  ),
                if (widget.sublabel != null) const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: widget.outlined
                        ? (isEnabled ? AppColors.textPrimary : AppColors.textMuted)
                        : AppColors.bg,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}