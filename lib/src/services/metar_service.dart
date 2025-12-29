import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MetarData {
  final String station;
  final String flightRules; // VFR, IFR, MVFR, LIFR
  final String raw;
  final int? temperature;
  final String? wind; // 120@12

  MetarData({
    required this.station,
    required this.flightRules,
    required this.raw,
    this.temperature,
    this.wind,
  });

  factory MetarData.fromJson(String station, Map<String, dynamic> json) {
    String? windString;
    if (json['wind_direction'] != null && json['wind_speed'] != null) {
      windString =
          "${json['wind_direction']['value']}@${json['wind_speed']['value']}";
    }

    return MetarData(
      station: station,
      flightRules: json['flight_rules'] ?? 'UNKNOWN',
      raw: json['raw'] ?? '',
      temperature: json['temperature'] != null
          ? json['temperature']['value']
          : null,
      wind: windString,
    );
  }
}

class MetarService {
  static const String _baseUrl =
      "https://opensky-authenticator.alezak94.workers.dev/metar";

  Future<MetarData?> getMetar(String station) async {
    try {
      // The worker expects: /metar?station=KJFK
      final uri = Uri.parse(
        _baseUrl,
      ).replace(queryParameters: {'station': station});

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return MetarData.fromJson(station, data);
      } else {
        debugPrint(
          "❌ METAR Fetch Failed for $station: ${response.statusCode} ${response.body}",
        );
        return null;
      }
    } catch (e) {
      debugPrint("❌ METAR Fetch Error for $station: $e");
      return null;
    }
  }
}

final metarServiceProvider = Provider((ref) => MetarService());

final metarProvider = FutureProvider.family<MetarData?, String>((
  ref,
  station,
) async {
  final service = ref.watch(metarServiceProvider);
  return service.getMetar(station);
});
