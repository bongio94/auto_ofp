import 'package:auto_ofp/src/services/flight_fetching_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'live_stats_badge.dart';

class HomeFooter extends ConsumerStatefulWidget {
  const HomeFooter({super.key});

  @override
  ConsumerState<HomeFooter> createState() => _HomeFooterState();
}

class _HomeFooterState extends ConsumerState<HomeFooter> {
  @override
  void initState() {
    super.initState();
    // Fetch stats on mount
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    // Always refresh to be "live"
    final count = await FlightImporter().fetchGlobalStats();
    if (count != null && mounted) {
      ref.read(flightPlanCountProvider.notifier).state = count;
      debugPrint("UPDATED COUNT: $count");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final count = ref.watch(flightPlanCountProvider);

    return Column(
      children: [
        AnimatedOpacity(
          opacity: count > 0 ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 500),
          child: count > 0
              ? LiveStatsBadge(count: count)
              : const SizedBox(
                  height: 48,
                ),
        ),

        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              "Flight data provided by ",
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            InkWell(
              onTap: () => launchUrl(
                Uri.parse('https://opensky-network.org'),
                mode: LaunchMode.externalApplication,
              ),
              child: Text(
                "The OpenSky Network",
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary, // Or Colors.blueAccent
                  decoration: TextDecoration.underline,
                  decorationColor: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => launchUrl(
            Uri.parse('https://github.com/bongio94/auto_ofp'),
            mode: LaunchMode.externalApplication,
          ),
          child: Text(
            "View on GitHub",
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              decoration: TextDecoration.underline,
              decorationColor: theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
