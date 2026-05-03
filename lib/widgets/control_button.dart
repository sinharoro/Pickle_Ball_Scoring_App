import 'package:flutter/material.dart';

class ControlButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onPressed;
  final bool enabled;

  const ControlButton({
    super.key,
    required this.label,
    required this.color,
    required this.onPressed,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = enabled && onPressed != null;
    
    return Material(
      color: isEnabled ? color : Colors.grey[300],
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: isEnabled ? onPressed : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isEnabled ? Colors.white : Colors.grey[500],
            ),
          ),
        ),
      ),
    );
  }
}