import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class FlightAwareService {
  static const apiKey = String.fromEnvironment('FLIGHTAWARE_API_KEY');
  static const baseUrl = 'https://aeroapi.flightaware.com/aeroapi';

  Future<Map<String, dynamic>?> getFlight(String ident) async {
    final url = Uri.parse('$baseUrl/flights/$ident');

    try {
      final response = await http.get(
        url,
        headers: {'x-apikey': apiKey, 'content-type': 'application/json'},
      );

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
          'route': flight['route'] ?? 'DIRECT',
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
