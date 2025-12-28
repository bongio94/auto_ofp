import 'dart:async';
import 'package:auto_ofp/src/services/flight_fetching_service.dart';
import 'package:auto_ofp/src/services/airline_fleet_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FlightSearchCard extends ConsumerStatefulWidget {
  const FlightSearchCard({super.key});

  @override
  ConsumerState<FlightSearchCard> createState() => _FlightSearchCardState();
}

class _FlightSearchCardState extends ConsumerState<FlightSearchCard> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();
  bool _hasLaunched = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  var candidates = [];
  var suggestedCandidates = <FlightCandidate>[];

  String _getManufacturer(String type) {
    type = type.toUpperCase();
    if (type.startsWith('A') &&
        type.length > 1 &&
        RegExp(r'[0-9]').hasMatch(type[1])) {
      return 'AIRBUS';
    }
    if (type.startsWith('B') &&
        type.length > 1 &&
        RegExp(r'[0-9]').hasMatch(type[1])) {
      return 'BOEING';
    }
    if (type.startsWith('E')) return 'EMBRAER';
    if (type.startsWith('CRJ') || type.startsWith('Q')) return 'BOMBARDIER';
    if (type.startsWith('MD') || type.startsWith('DC')) {
      return 'MCDONNELL DOUGLAS';
    }
    return 'OTHER AIRCRAFT';
  }

  Map<String, List<FlightCandidate>> _groupCandidates(List<dynamic> input) {
    final groups = <String, List<FlightCandidate>>{};
    for (final item in input) {
      final c = item as FlightCandidate;
      final m = _getManufacturer(c.type);
      groups.putIfAbsent(m, () => []).add(c);
    }

    // Sort keys: Airbus/Boeing first, Others last
    final sortedKeys = groups.keys.toList()
      ..sort((a, b) {
        if (a == 'OTHER AIRCRAFT') return 1;
        if (b == 'OTHER AIRCRAFT') return -1;
        return a.compareTo(b);
      });

    return {for (var k in sortedKeys) k: groups[k]!};
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                  return 'Please paste a FlightAware link';
                }
                final urlResult = FlightImporter().parseFlightAwareUrl(
                  value.trim(),
                );
                if (urlResult == null) {
                  return 'Invalid link. Must be a specific FlightAware history URL\n(e.g .../flight/AAL1/history/20251221/...)';
                }
                return null;
              },
              onChanged: (_) {
                if (_hasLaunched) {
                  setState(() => _hasLaunched = false);
                }
              },
              textAlign: TextAlign.center,

              decoration: InputDecoration(
                errorMaxLines: 3,
                hintText: "Paste FlightAware Link",
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
                onPressed: _isLoading
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }

                        // Reset state for new search
                        if (_hasLaunched) {
                          setState(() => _hasLaunched = false);
                        }

                        setState(() {
                          _isLoading = true;
                          candidates = []; // Clear previous results
                          suggestedCandidates = [];
                        });

                        try {
                          final results = await FlightImporter()
                              .getCandidatesFromUrl(
                                _controller.text,
                              );

                          // Update Global Stats
                          if (mounted) {
                            ref.read(flightPlanCountProvider.notifier).state =
                                FlightImporter.globalGeneratedCount;
                          }

                          // Deduplicate: User only cares about distinct Aircraft Types
                          final uniqueResults = <FlightCandidate>[];
                          final seenTypes = <String>{};
                          for (final candidate in results) {
                            if (seenTypes.add(candidate.type)) {
                              uniqueResults.add(candidate);
                            }
                          }

                          // Suggestions Logic
                          final newSuggestions = <FlightCandidate>[];
                          if (uniqueResults.isNotEmpty) {
                            final base = uniqueResults.first;
                            final suggestedTypes =
                                AirlineFleetService.getSuggestedAircraft(
                                  base.airlineCode,
                                );

                            for (final type in suggestedTypes) {
                              if (!seenTypes.contains(type)) {
                                newSuggestions.add(
                                  FlightCandidate(
                                    icao24: 'suggested',
                                    callsign: base.callsign,
                                    airlineCode: base.airlineCode,
                                    flightNumber: base.flightNumber,
                                    type: type,
                                    origin: base.origin,
                                    destination: base.destination,
                                    date: base.date,
                                    atcCallsign: base.atcCallsign,
                                  ),
                                );
                              }
                            }
                          }

                          if (mounted) {
                            setState(() {
                              candidates = uniqueResults;
                              suggestedCandidates = newSuggestions;
                            });
                          }
                        } finally {
                          if (mounted) {
                            setState(() {
                              _isLoading = false;
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
                child: _isLoading
                    ? const _LoadingTextAnimation()
                    : const Text(
                        "GENERATE PLAN",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
              ),
            ),

            if (candidates.isEmpty &&
                _isLoading == false &&
                _controller.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  "No candidates found yet...",
                  style: TextStyle(color: Colors.white54),
                ),
              ),

            if (candidates.isNotEmpty) ...[
              const SizedBox(height: 24),

              // Common Trip Details Header
              Container(
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
                          "https://media.githubusercontent.com/media/airframesio/airline-images/main/fr24_logos/${candidates.first.airlineCode.toUpperCase()}.png",
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
                                candidates.first.airlineCode.substring(0, 1),
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
                      children: [
                        Text(
                          candidates.first.origin,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
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
                        Text(
                          candidates.first.destination,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "CALLSIGN: ${candidates.first.callsign}",
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              if (suggestedCandidates.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Row(
                    children: [
                      const Expanded(child: Divider(color: Colors.white24)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "SUGGESTED FLEET",
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white70,
                            letterSpacing: 2.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(color: Colors.white24)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                for (final group in _groupCandidates(
                  suggestedCandidates,
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
                          onTap: () => FlightImporter().launchSimBrief(c),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: 100,
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: theme.colorScheme.secondary.withValues(
                                  alpha: 0.3,
                                ),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.secondary.withValues(
                                    alpha: 0.1,
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.flight,
                                  color: Colors.white70,
                                  size: 24,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  c.type,
                                  style: const TextStyle(
                                    color: Colors.white70,
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
                const SizedBox(height: 24),
              ],

              if (suggestedCandidates.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Row(
                    children: [
                      const Expanded(child: Divider(color: Colors.white24)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "DETECTED AIRCRAFT",
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.8,
                            ),
                            letterSpacing: 2.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(color: Colors.white24)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              for (final group in _groupCandidates(candidates).entries) ...[
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
                        onTap: () => FlightImporter().launchSimBrief(c),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 100, // Fixed width for uniformity
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.3,
                              ),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.1,
                                ),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.flight,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                c.type,
                                style: const TextStyle(
                                  color: Colors.white,
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

              const SizedBox(height: 24),
              Center(
                child: OutlinedButton.icon(
                  onPressed: () {
                    final base = candidates.first;
                    final manual = FlightCandidate(
                      icao24: '',
                      callsign: base.callsign,
                      airlineCode: base.airlineCode,
                      flightNumber: base.flightNumber,
                      type: '', // Empty type to let user choose
                      origin: base.origin,
                      destination: base.destination,
                      date: base.date,
                      atcCallsign: base.atcCallsign,
                    );
                    FlightImporter().launchSimBrief(manual);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.edit_note, color: Colors.white70),
                  label: const Text(
                    "I'LL CHOOSE AIRCRAFT MANUALLY",
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LoadingTextAnimation extends StatefulWidget {
  const _LoadingTextAnimation();

  @override
  State<_LoadingTextAnimation> createState() => _LoadingTextAnimationState();
}

class _LoadingTextAnimationState extends State<_LoadingTextAnimation> {
  int _index = 0;
  Timer? _timer;

  final List<String> _phrases = [
    "CONTACTING ATC...",
    "ALIGNING IRS...",
    "CHECKING OFP...",
    "LOADING CARGO...",
    "SPOOLING ENGINES...",
    "REQUESTING CLEARANCE...",
    "CHECKING WEATHER...",
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (mounted) {
        setState(() {
          _index = (_index + 1) % _phrases.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        final offset =
            Tween<Offset>(
              begin: const Offset(0.0, 0.5),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
              ),
            );
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: offset,
            child: child,
          ),
        );
      },
      child: Text(
        _phrases[_index],
        key: ValueKey<String>(_phrases[_index]),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
