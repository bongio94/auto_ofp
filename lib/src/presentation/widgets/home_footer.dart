import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeFooter extends StatelessWidget {
  const HomeFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
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
      ],
    );
  }
}
