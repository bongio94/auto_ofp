import 'package:flutter/material.dart';

class InfoTooltip extends StatelessWidget {
  final String message;
  final Widget? child;

  const InfoTooltip({
    super.key,
    required this.message,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      preferBelow: false,
      message: message,
      verticalOffset: 12,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 12,
      ),
      child:
          child ??
          Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: Colors.grey.shade500,
          ),
    );
  }
}
