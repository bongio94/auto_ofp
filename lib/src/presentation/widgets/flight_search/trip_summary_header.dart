import 'package:flutter/material.dart';
import 'package:auto_ofp/src/presentation/widgets/flight_search/metar_badge.dart';
import 'package:auto_ofp/src/services/flight_fetching_service.dart';

class TripSummaryHeader extends StatelessWidget {
  final FlightCandidate candidate;

  const TripSummaryHeader({super.key, required this.candidate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(2), // White border effect
            child: ClipOval(
              child: Image.network(
                "https://media.githubusercontent.com/media/airframesio/airline-images/main/fr24_logos/${candidate.airlineCode.toUpperCase()}.png",
                width: 60,
                height: 60,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60,
                    height: 60,
                    color: Colors.white12,
                    alignment: Alignment.center,
                    child: Text(
                      candidate.airlineCode.substring(0, 1),
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      candidate.origin,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    MetarBadge(station: candidate.origin),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      candidate.destination,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    MetarBadge(station: candidate.destination),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "CALLSIGN: ${candidate.callsign}",
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
              letterSpacing: 2.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
