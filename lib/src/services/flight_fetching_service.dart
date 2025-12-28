import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class FlightCandidate {
  final String icao24;
  final String callsign; // "TAP1094" (From URL)
  final String airlineCode; // "TAP"
  final String flightNumber; // "1094"
  final String type; // "A321" (From Worker)
  final String origin;
  final String destination;
  final String date;
  final String atcCallsign; // "TAP1094P" (Actual ATC callsign, for reference)

  FlightCandidate({
    required this.icao24,
    required this.callsign,
    required this.airlineCode,
    required this.flightNumber,
    required this.type,
    required this.origin,
    required this.destination,
    required this.date,
    required this.atcCallsign,
  });
}

final flightPlanCountProvider = StateProvider<int>((ref) => 0);

class FlightImporter {
  final String workerUrl = "https://opensky-authenticator.alezak94.workers.dev";
  Map<String, dynamic>? _aircraftDb;

  static int globalGeneratedCount = 0;

  Future<void> loadLocalDatabase() async {
    if (_aircraftDb != null) return;
    try {
      final String response = await rootBundle.loadString(
        'assets/aircraft_db.json',
      );
      _aircraftDb = json.decode(response);
      debugPrint("✅ Local Aircraft DB Loaded");
    } catch (e) {
      debugPrint("❌ Error loading local DB: $e");
    }
  }

  /// Robust splitter: Handles "TAP1094" and "TAP1094P" correctly
  List<String> _splitCallsign(String fullCallsign) {
    // 1. Try strict format: Letters + Numbers (Ignore suffix letters for flight num)
    final regExp = RegExp(r'^([A-Z]+)([0-9]+)([A-Z]*)$');
    final match = regExp.firstMatch(fullCallsign);

    if (match != null) {
      return [match.group(1)!, match.group(2)!]; // Group 1=TAP, Group 2=1094
    }

    // 2. Fallback
    final letters = fullCallsign.replaceAll(RegExp(r'[0-9]'), '');
    final numbers = fullCallsign.replaceAll(RegExp(r'[^0-9]'), '');
    return [letters, numbers];
  }

  Map<String, String>? parseFlightAwareUrl(String url) {
    // Matches: .../flight/TAP1094/history/20251225/1505Z/LPPT/LEVC
    final regExp = RegExp(
      r'flight\/([A-Z0-9]+)\/history\/([0-9]{8})\/[A-Z0-9]+\/([A-Z]{4})\/([A-Z]{4})',
    );
    final match = regExp.firstMatch(url);

    if (match != null) {
      return {
        'callsign': match.group(1)!,
        'date': match.group(2)!,
        'origin': match.group(3)!,
        'dest': match.group(4)!,
      };
    }
    return null;
  }

  Future<List<FlightCandidate>> getCandidatesFromUrl(String urlInput) async {
    await loadLocalDatabase();

    final params = parseFlightAwareUrl(urlInput);
    if (params == null) {
      debugPrint("❌ Invalid FlightAware URL");
      return [];
    }

    // Prepare "Master" details from the URL (The user's truth)
    final masterCallsign = params['callsign']!; // "TAP1094"
    final masterSplit = _splitCallsign(masterCallsign); // ["TAP", "1094"]
    final masterOrigin = params['origin']!;
    final masterDest = params['dest']!;
    final masterDate = params['date']!;

    debugPrint(
      "🚀 Looking for aircraft flying: $masterCallsign ($masterOrigin -> $masterDest)",
    );

    final uri = Uri.parse(workerUrl).replace(queryParameters: params);

    try {
      final response = await http.get(uri);
      List<FlightCandidate> resolved = [];

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['stats'] != null) {
          globalGeneratedCount = data['stats']['total_generated'] ?? 0;
          debugPrint("🌍 Global Plans Generated: $globalGeneratedCount");
        }

        final List rawCandidates = data['candidates'] ?? [];

        for (var c in rawCandidates) {
          String hex = c['icao24'].toString().toLowerCase();

          // Match ICAO24 to Local Aircraft DB
          if (_aircraftDb != null && _aircraftDb!.containsKey(hex)) {
            // WE FOUND THE PLANE!
            // Now, combine the WORKER's physics (Type/Hex)
            // with the URL's metadata (Airline/FlightNum).

            resolved.add(
              FlightCandidate(
                icao24: hex,
                // User "Master" Data for SimBrief
                callsign: masterCallsign,
                airlineCode: masterSplit[0],
                flightNumber: masterSplit[1],
                origin: masterOrigin,
                destination: masterDest,
                date: masterDate,
                // Worker Data for Reality Check
                type: _aircraftDb![hex],
                atcCallsign: c['callsign'] ?? "Unknown", // "TAP1094P"
              ),
            );
          }
        }
      }

      // Fallback: If no plane found, return the URL data with default type
      if (resolved.isEmpty) {
        debugPrint("⚠️ No aircraft found. Using URL data with default type.");
        resolved.add(
          FlightCandidate(
            icao24: "unknown",
            callsign: masterCallsign,
            airlineCode: masterSplit[0],
            flightNumber: masterSplit[1],
            type: "A320",
            origin: masterOrigin,
            destination: masterDest,
            date: masterDate,
            atcCallsign: masterCallsign,
          ),
        );
      }

      return resolved;
    } catch (e) {
      debugPrint("❌ Network Error: $e");
      return [];
    }
  }

  Future<int?> fetchGlobalStats() async {
    // Call the /stats endpoint to get count without incrementing
    final uri = Uri.parse("$workerUrl/stats");

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        int? count;
        if (data['total_generated'] != null) {
          count = data['total_generated'];
        } else if (data['stats'] != null) {
          count = data['stats']['total_generated'];
        }

        if (count != null) {
          // Update static cache
          globalGeneratedCount = count;
          return count;
        }
      }
    } catch (e) {
      debugPrint("❌ Error fetching stats: $e");
    }
    return null;
  }

  void launchSimBrief(FlightCandidate selection) {
    final url = Uri.parse("https://dispatch.simbrief.com/options/custom")
        .replace(
          queryParameters: {
            'airline': selection.airlineCode,
            'fltnum': selection.flightNumber,
            'orig': selection.origin,
            'dest': selection.destination,
            'type': selection.type,
          },
        );

    launchUrl(url, mode: LaunchMode.externalApplication);
  }
}
