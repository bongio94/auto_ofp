import 'package:auto_ofp/src/services/flight_fetching_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

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
    // Only fetch if we don't have a count yes (or maybe always to refresh?)
    // Always refresh to be "live"
    final count = await FlightImporter().fetchGlobalStats();
    if (count != null && mounted) {
      ref.read(flightPlanCountProvider.notifier).state = count;
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
              ? Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.bar_chart_rounded,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        // Simple formatter for comma separation
                        "${count.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} PLANS GENERATED",
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox(
                  height: 48,
                ), // Placeholder height to avoid jump? No, opacity 0 handles visual hidding but takes space?
          // Actually, AnimatedOpacity keeps space.
          // If count is 0, we might want it NOT to take space initially if we don't want a gap.
          // But user said "always visible".
          // If it loads 0 initially, and then updates, using AnimatedOpacity is nice.
          // Let's us SizedBox if 0, but wrap in AnimatedSize?
        ),

        // Let's stick to the previous conditional rendering but maybe with a small animation if it pops in.
        // But since we fetch on init, it should pop in quickly.
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
