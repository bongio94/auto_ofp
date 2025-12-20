import 'dart:async';
import 'package:auto_ofp/src/services/flight_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class FlightSearchCard extends ConsumerStatefulWidget {
  const FlightSearchCard({super.key});

  @override
  ConsumerState<FlightSearchCard> createState() => _FlightSearchCardState();
}

class _FlightSearchCardState extends ConsumerState<FlightSearchCard> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();
  bool _hasLaunched = false;
  bool _isCooldown = false;
  Timer? _cooldownTimer;

  @override
  void dispose() {
    _controller.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    setState(() => _isCooldown = true);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() => _isCooldown = false);
      }
    });
  }

  Future<void> _launchSimBrief(Map<String, dynamic> data) async {
    final ident = data['ident'] as String? ?? '';
    final origin = data['origin'] as String? ?? '';
    final dest = data['destination'] as String? ?? '';
    final type = data['aircraft_type'] as String? ?? '';

    final airlineMatch = RegExp(r'^([A-Z]+)').firstMatch(ident.toUpperCase());
    final fltNumMatch = RegExp(r'(\d+)$').firstMatch(ident);

    final airline = airlineMatch?.group(1) ?? '';
    final fltnum = fltNumMatch?.group(1) ?? ident;

    final uri = Uri.https('www.simbrief.com', '/system/dispatch.php', {
      'airline': airline,
      'fltnum': fltnum,
      'orig': origin,
      'dest': dest,
      'type': type,
    });

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint("Could not launch $uri");
    }
  }

  @override
  Widget build(BuildContext context) {
    final flightState = ref.watch(flightControllerProvider);
    final theme = Theme.of(context);
    final isButtonDisabled = flightState.isLoading || _isCooldown;

    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "ENTER FLIGHT INFO",
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controller,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a flight number';
                }
                final upValue = value.trim().toUpperCase();
                // Check format: 2-3 Letters + 1-4 Digits + Optional 1 Letter Suffix
                // Examples: CSZ123, AAL1, BAW40
                if (!RegExp(r'^[A-Z]{2,3}\d{1,4}[A-Z]?$').hasMatch(upValue)) {
                  return 'Invalid format. Use Airline Code + Number (e.g. AAL123)';
                }
                return null;
              },
              onChanged: (_) {
                if (_hasLaunched) {
                  setState(() => _hasLaunched = false);
                }
              },
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                errorMaxLines: 2,
                hintText: "CSZ123 or AAL1",
                hintStyle: TextStyle(color: Colors.grey.shade600),
                filled: true,
                fillColor: Colors.black.withValues(alpha: 0.2),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                  ),
                ),
                prefixIcon: const Icon(Icons.search, size: 20),
              ),
            ),
            const SizedBox(height: 24),
            // Action Button
            SizedBox(
              height: 54,
              child: FilledButton(
                onPressed: isButtonDisabled
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }

                        // Reset state for new search
                        if (_hasLaunched) {
                          setState(() => _hasLaunched = false);
                        }

                        // Start UI cooldown immediately to prevent double-taps
                        _startCooldown();

                        final controller = ref.read(
                          flightControllerProvider.notifier,
                        );
                        await controller.searchFlight(
                          _controller.text,
                        );

                        final newState = ref.read(
                          flightControllerProvider,
                        );
                        if (newState.hasValue && newState.value != null) {
                          await _launchSimBrief(newState.value!);
                          if (mounted) {
                            setState(() {
                              _hasLaunched = true;
                            });
                          }
                        }
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  disabledBackgroundColor: theme.colorScheme.surface.withValues(
                    alpha: 0.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: flightState.isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : Text(
                        _isCooldown ? "PLEASE WAIT..." : "GENERATE PLAN",
                        style: TextStyle(
                          color: isButtonDisabled
                              ? Colors.grey
                              : Colors.black, // Contrast for sky blue
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
              ),
            ),
            // State Feedback Area
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: flightState.when(
                data: (data) => data != null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 24.0),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _hasLaunched
                                    ? theme.colorScheme.primary.withValues(
                                        alpha: 0.1,
                                      )
                                    : Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _hasLaunched
                                      ? theme.colorScheme.primary.withValues(
                                          alpha: 0.3,
                                        )
                                      : Colors.green.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _hasLaunched
                                        ? Icons.open_in_new
                                        : Icons.check_circle_outline,
                                    color: _hasLaunched
                                        ? theme.colorScheme.primary
                                        : Colors.green,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _hasLaunched
                                        ? "Plan Opened in SimBrief"
                                        : "Redirecting...",
                                    style: TextStyle(
                                      color: _hasLaunched
                                          ? theme.colorScheme.primary
                                          : Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_hasLaunched) ...[
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () => _launchSimBrief(data),
                                child: Text(
                                  "Open again",
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ] else
                              TextButton(
                                onPressed: () => _launchSimBrief(data),
                                child: Text(
                                  "Click if not redirected",
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
                loading: () => const SizedBox.shrink(), // Handled in button
                error: (err, _) => Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    "Error: $err",
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
