import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_ofp/src/services/metar_service.dart';

class MetarBadge extends ConsumerWidget {
  final String station;

  const MetarBadge({super.key, required this.station});

  Color _getRuleColor(String rule) {
    switch (rule.toUpperCase()) {
      case 'VFR':
        return Colors.greenAccent;
      case 'MVFR':
        return Colors.blueAccent;
      case 'IFR':
        return Colors.redAccent;
      case 'LIFR':
        return Colors.purpleAccent;
      default:
        return Colors.grey;
    }
  }

  IconData _getWeatherIcon(String rule) {
    switch (rule.toUpperCase()) {
      case 'VFR':
        return Icons.wb_sunny_rounded;
      case 'MVFR':
        return Icons.cloud_queue_rounded;
      case 'IFR':
        return Icons.grain_rounded;
      case 'LIFR':
        return Icons.thunderstorm_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metarAsync = ref.watch(metarProvider(station));

    return metarAsync.when(
      data: (data) {
        if (data == null) return const SizedBox.shrink();

        final color = _getRuleColor(data.flightRules);
        final icon = _getWeatherIcon(data.flightRules);

        return Tooltip(
          message: data.raw,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white24),
          ),
          textStyle: const TextStyle(
            color: Colors.white,
            fontFamily: 'Monospace',
            fontSize: 12,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14, color: color),
                if (data.temperature != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    "${data.temperature}°C",
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(width: 6),
                Text(
                  data.flightRules,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
