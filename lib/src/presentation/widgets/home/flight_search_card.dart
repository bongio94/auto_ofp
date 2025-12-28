import 'package:auto_ofp/src/services/flight_fetching_service.dart';
import 'package:auto_ofp/src/services/airline_fleet_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../flight_search/aircraft_selection_grid.dart';
import '../flight_search/manual_selection_button.dart';
import '../flight_search/search_input_section.dart';
import '../flight_search/trip_summary_header.dart';

class FlightSearchCard extends ConsumerStatefulWidget {
  final ValueChanged<bool>? onResultsFound;
  const FlightSearchCard({super.key, this.onResultsFound});

  @override
  ConsumerState<FlightSearchCard> createState() => _FlightSearchCardState();
}

class _FlightSearchCardState extends ConsumerState<FlightSearchCard> {
  final TextEditingController _controller = TextEditingController();
  bool _hasLaunched = false;
  bool _isLoading = false;
  bool _showDetectedAircraft = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  var candidates = <FlightCandidate>[];
  var suggestedCandidates = <FlightCandidate>[];

  Future<void> _performSearch() async {
    // Reset state for new search
    if (_hasLaunched) {
      setState(() => _hasLaunched = false);
    }

    setState(() {
      _isLoading = true;
      candidates = []; // Clear previous results
      suggestedCandidates = [];
    });
    widget.onResultsFound?.call(false);

    try {
      final results = await FlightImporter().getCandidatesFromUrl(
        _controller.text,
      );

      // Update Global Stats
      if (mounted) {
        ref.read(flightPlanCountProvider.notifier).state =
            FlightImporter.globalGeneratedCount;
      }

      final uniqueResults = <FlightCandidate>[];
      final newSuggestions = <FlightCandidate>[];
      final seenTypes = <String>{};

      if (results.isNotEmpty) {
        final base = results.first;

        // 1. Suggestions Logic (Priority: Matches user request to favor suggestions)
        final suggestedTypes = AirlineFleetService.getSuggestedAircraft(
          base.airlineCode,
        );

        for (final type in suggestedTypes) {
          if (seenTypes.add(type)) {
            // Add returns true if type was not in set
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

        // 2. Detected Logic (Deduplicate & Remove if already in Suggestions)
        for (final candidate in results) {
          if (seenTypes.add(candidate.type)) {
            uniqueResults.add(candidate);
          }
        }
      }

      if (mounted) {
        setState(() {
          candidates = uniqueResults;
          suggestedCandidates = newSuggestions;
        });
        widget.onResultsFound?.call(
          uniqueResults.isNotEmpty || newSuggestions.isNotEmpty,
        );
      }
    } catch (e) {
      // Handle error (maybe show snackbar)
      debugPrint("Error fetching flight info: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onManualSelection() {
    if (candidates.isEmpty && suggestedCandidates.isEmpty) return;

    // Use whatever data we have to pre-fill the manual form (SimBrief launcher)
    final base = candidates.isNotEmpty
        ? candidates.first
        : suggestedCandidates.first;

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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasResults = candidates.isNotEmpty || suggestedCandidates.isNotEmpty;
    // Helper to get a candidate for header display
    final displayCandidate = candidates.isNotEmpty
        ? candidates.first
        : (suggestedCandidates.isNotEmpty ? suggestedCandidates.first : null);

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
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SearchInputSection(
              controller: _controller,
              isLoading: _isLoading,
              onSearch: _performSearch,
              onChanged: (_) {
                if (_hasLaunched) {
                  setState(() => _hasLaunched = false);
                }
              },
            ),

            if (!hasResults &&
                _isLoading == false &&
                _controller.text.isNotEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Text(
                  "No candidates found yet...",
                  style: TextStyle(color: Colors.white54),
                ),
              ),

            if (hasResults && displayCandidate != null) ...[
              const SizedBox(height: 24),

              // Common Trip Details Header
              TripSummaryHeader(candidate: displayCandidate),

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

                AircraftSelectionGrid(
                  candidates: suggestedCandidates,
                  accentColor: theme.colorScheme.secondary,
                  textColor: Colors.white70,
                  onSelected: (c) => FlightImporter().launchSimBrief(c),
                ),

                const SizedBox(height: 24),
              ],

              // Detected Aircraft Section (Accordion)
              if (candidates.isNotEmpty) ...[
                InkWell(
                  onTap: () {
                    setState(() {
                      _showDetectedAircraft = !_showDetectedAircraft;
                    });
                  },
                  splashColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  highlightColor: theme.colorScheme.primary.withValues(
                    alpha: 0.05,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            child: Divider(
                              color: _showDetectedAircraft
                                  ? theme.colorScheme.primary.withValues(
                                      alpha: 0.5,
                                    )
                                  : Colors.white24,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                style: theme.textTheme.labelSmall!.copyWith(
                                  color: _showDetectedAircraft
                                      ? theme.colorScheme.primary
                                      : Colors.white60,
                                  letterSpacing: 2.0,
                                  fontWeight: FontWeight.bold,
                                ),
                                child: const Text("DETECTED AIRCRAFT"),
                              ),
                              const SizedBox(width: 8),
                              AnimatedRotation(
                                turns: _showDetectedAircraft ? 0.5 : 0.0,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutBack,
                                child: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: _showDetectedAircraft
                                      ? theme.colorScheme.primary
                                      : Colors.white60,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            child: Divider(
                              color: _showDetectedAircraft
                                  ? theme.colorScheme.primary.withValues(
                                      alpha: 0.5,
                                    )
                                  : Colors.white24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                AnimatedSize(
                  duration: const Duration(milliseconds: 400),
                  alignment: Alignment.topCenter,
                  curve: Curves.fastOutSlowIn,
                  child: _showDetectedAircraft
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: AircraftSelectionGrid(
                            candidates: candidates,
                            accentColor: theme.colorScheme.primary,
                            textColor: Colors.white,
                            onSelected: (c) =>
                                FlightImporter().launchSimBrief(c),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 24),
              ],

              ManualSelectionButton(onPressed: _onManualSelection),
            ],
          ],
        ),
      ),
    );
  }
}
