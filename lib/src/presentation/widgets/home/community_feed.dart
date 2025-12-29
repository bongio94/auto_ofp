import 'package:auto_ofp/src/services/flight_fetching_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommunityFeed extends ConsumerStatefulWidget {
  const CommunityFeed({super.key});

  @override
  ConsumerState<CommunityFeed> createState() => _CommunityFeedState();
}

class _CommunityFeedState extends ConsumerState<CommunityFeed>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _ticker = createTicker((elapsed) {
      if (_scrollController.hasClients) {
        if (_scrollController.position.maxScrollExtent > 0) {
          // Calculate delta time in seconds
          final dt = (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
          _lastElapsed = elapsed;

          // Target speed: 20 pixels per second
          const double speed = 35.0;
          double current = _scrollController.offset;
          double next = current + (speed * dt);

          _scrollController.jumpTo(next);
        }
      }
    });

    // Start scrolling after layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ticker.start();
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flights = ref.watch(recentFlightsProvider);

    if (flights.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "COMMUNITY ACTIVITY",
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.grey.shade500,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Tooltip(
                preferBelow: false,
                message:
                    "We do not collect any personal data, only origin, destination and flight number",
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24),
                ),
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 40,
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                colors: [
                  Colors.white,
                  Colors.white.withValues(alpha: 0),
                  Colors.white.withValues(alpha: 0),
                  Colors.white,
                ],
                stops: const [0.0, 0.05, 0.95, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstOut,
            child: RepaintBoundary(
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                // Infinite scroll by returning modulo index
                itemBuilder: (context, index) {
                  final flight = flights[index % flights.length];
                  return Padding(
                    padding: const EdgeInsets.only(
                      right: 16.0,
                    ), // Consistent Gap
                    child: _RecentFlightItem(flight: flight),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RecentFlightItem extends ConsumerWidget {
  final RecentFlight flight;

  const _RecentFlightItem({required this.flight});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Format YYYYMMDD for the URL
    final now = DateTime.now();
    final dateStr =
        "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // Construct a valid-looking FlightAware URL to trigger the search parser
            final url =
                "https://flightaware.com/live/flight/${flight.callsign}/history/$dateStr/0000Z/${flight.origin}/${flight.destination}";

            ref.read(flightSearchQueryProvider.notifier).state = url;
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.flight_takeoff_rounded,
                  size: 14,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  flight.callsign,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  "flying",
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.grey.shade400,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  "${flight.origin} → ${flight.destination}",
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.white,
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
