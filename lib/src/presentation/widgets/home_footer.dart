import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeFooter extends StatelessWidget {
  const HomeFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          "Powered by FlightAware & SimBrief",
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () async {
            final uri = Uri.parse("https://buymeacoffee.com/bongio94");
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
            }
          },
          icon: const Icon(
            Icons.coffee_rounded,
            size: 16,
            color: Colors.amber,
          ),
          label: Text(
            "Buy me a coffee",
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            backgroundColor: Colors.amber.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }
}
