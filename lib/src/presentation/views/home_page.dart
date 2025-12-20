import 'dart:async';
import 'package:auto_ofp/src/services/flight_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class FlightSearchScreen extends ConsumerStatefulWidget {
  const FlightSearchScreen({super.key});

  @override
  ConsumerState<FlightSearchScreen> createState() => _FlightSearchScreenState();
}

class _FlightSearchScreenState extends ConsumerState<FlightSearchScreen> {
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
    _cooldownTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => _isCooldown = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch the flight controller state
    final flightState = ref.watch(flightControllerProvider);
    final theme = Theme.of(context);

    // Button is disabled if loading or in cooldown
    final isButtonDisabled = flightState.isLoading || _isCooldown;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.5,
            colors: [
              Color(0xFF1E293B), // Slate 800
              Color(0xFF0F172A), // Slate 900
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header
                Icon(
                  Icons.flight_takeoff_rounded,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  "AUTO OFP",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Fast Track to SimBrief",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 48),

                // Main Card
                Container(
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
                      TextField(
                        controller: _controller,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        onChanged: (_) {
                          if (_hasLaunched) {
                            setState(() => _hasLaunched = false);
                          }
                        },
                        textAlign: TextAlign.center,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
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
                                  if (newState.hasValue &&
                                      newState.value != null) {
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
                            disabledBackgroundColor: theme.colorScheme.surface
                                .withValues(alpha: 0.5),
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
                                  _isCooldown
                                      ? "PLEASE WAIT..."
                                      : "GENERATE PLAN",
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
                                              ? theme.colorScheme.primary
                                                    .withValues(alpha: 0.1)
                                              : Colors.green.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: _hasLaunched
                                                ? theme.colorScheme.primary
                                                      .withValues(alpha: 0.3)
                                                : Colors.green.withValues(alpha: 0.3),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
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
                                          onPressed: () =>
                                              _launchSimBrief(data),
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
                                          onPressed: () =>
                                              _launchSimBrief(data),
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
                          loading: () =>
                              const SizedBox.shrink(), // Handled in button
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
                const SizedBox(height: 32),
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
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchSimBrief(Map<String, dynamic> data) async {
    final ident = data['ident'] as String? ?? '';
    final origin = data['origin'] as String? ?? '';
    final dest = data['destination'] as String? ?? '';
    final type = data['aircraft_type'] as String? ?? '';

    // Split ident into airline and fltnum
    // Heuristic: separate letters from numbers
    final airlineMatch = RegExp(r'^([A-Z]+)').firstMatch(ident.toUpperCase());
    final fltNumMatch = RegExp(r'(\d+)$').firstMatch(ident);

    final airline = airlineMatch?.group(1) ?? '';
    final fltnum =
        fltNumMatch?.group(1) ??
        ident; // Fallback to full ident if no digits found?

    final uri = Uri.https('www.simbrief.com', '/system/dispatch.php', {
      'airline': airline,
      'fltnum': fltnum,
      'orig': origin,
      'dest': dest,
      'type': type,
      // 'date': 'today', // Optional: SimBrief defaults to today
    });

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint("Could not launch $uri");
    }
  }
}

// FlightResultCard removed as requested
