import 'package:flutter/material.dart';
import 'package:auto_ofp/src/services/flight_fetching_service.dart';
import 'package:auto_ofp/src/services/airline_fleet_service.dart';

class AircraftSelectionGrid extends StatelessWidget {
  final List<FlightCandidate> candidates;
  final Color accentColor;
  final Color textColor;
  final ValueChanged<FlightCandidate> onSelected;

  const AircraftSelectionGrid({
    super.key,
    required this.candidates,
    required this.accentColor,
    this.textColor = Colors.white,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (candidates.isEmpty) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final group in AirlineFleetService.groupCandidates(
          candidates,
        ).entries) ...[
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Text(
              group.key,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.start,
            children: group.value.map<Widget>((c) {
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onSelected(c),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 100, // Fixed width for uniformity
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.flight,
                          color: textColor,
                          size: 24,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          c.type,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
