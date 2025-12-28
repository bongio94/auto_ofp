import 'package:flutter/material.dart';

class ManualSelectionButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ManualSelectionButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.3),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.edit_note, color: Colors.white70),
        label: const Text(
          "I'LL CHOOSE AIRCRAFT MANUALLY",
          style: TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}
