import 'package:auto_ofp/src/presentation/widgets/common/info_tooltip.dart';
import 'package:flutter/material.dart';

class TimeSelectionToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const TimeSelectionToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        spacing: 8,
        children: [
          InkWell(
            onTap: () => onChanged(!value),
            borderRadius: BorderRadius.circular(4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Checkbox.adaptive(
                  value: value,
                  onChanged: (val) => onChanged(val ?? false),
                  activeColor: theme.colorScheme.primary,
                  side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
                Text(
                  "USE CURRENT TIME OF DAY",
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
          const InfoTooltip(
            message:
                "When unchecked, the departure time will be sourced from the FlightAware link.",
          ),
        ],
      ),
    );
  }
}
