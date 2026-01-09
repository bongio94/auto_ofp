import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:auto_ofp/src/services/flight_fetching_service.dart';

class SimbriefLauncherService {
  static Future<void> launchSimBrief(FlightCandidate selection) async {
    String formattedDate = selection.date;
    String deph = "";
    String depm = "";

    try {
      // 1. Format Date: YYYYMMDD -> DDMONYY
      if (selection.date.length == 8) {
        final year = selection.date.substring(2, 4);
        final monthStr = selection.date.substring(4, 6);
        final day = selection.date.substring(6, 8);

        const months = [
          "JAN",
          "FEB",
          "MAR",
          "APR",
          "MAY",
          "JUN",
          "JUL",
          "AUG",
          "SEP",
          "OCT",
          "NOV",
          "DEC",
        ];
        final monthIndex = int.parse(monthStr) - 1;
        if (monthIndex >= 0 && monthIndex < 12) {
          formattedDate = "$day${months[monthIndex]}$year";
        }
      }

      // 2. Extract Time: HHMMZ -> deph, depm
      final cleanTime = selection.time.replaceAll(RegExp(r'[^0-9]'), '');
      if (cleanTime.length >= 4) {
        deph = cleanTime.substring(0, 2);
        depm = cleanTime.substring(2, 4);
      }
    } catch (e) {
      debugPrint("Error formatting date/time for SimBrief: $e");
    }

    final url = Uri.parse("https://dispatch.simbrief.com/options/custom")
        .replace(
          queryParameters: {
            'airline': selection.airlineCode,
            'fltnum': selection.flightNumber,
            'orig': selection.origin,
            'dest': selection.destination,
            'type': selection.type,
            'date': formattedDate,
            if (deph.isNotEmpty) 'deph': deph,
            if (depm.isNotEmpty) 'depm': depm,
          },
        );

    launchUrl(url, mode: LaunchMode.externalApplication);
  }
}
