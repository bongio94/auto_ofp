import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class FlightAwareService {

  Future<Map<String, dynamic>?> getFlight(String ident) async {
    final workerUrl = 'https://auto-ofp-flightaware.alezak94.workers.dev/?ident=$ident';
    final url = Uri.parse(workerUrl);

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List flights = data['flights'];

        if (flights.isEmpty) {
          throw Exception('No flight data found for $ident');
        }

        final flight = flights.first;

        return {
          'origin': flight['origin']['code_icao'],
          'destination': flight['destination']['code_icao'],
          'aircraft_type': flight['aircraft_type'],
          'ident': flight['ident'],
        };
      } else {
        throw Exception('Failed to load flight: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching flight: $e');
      return null;
    }
  }
}
