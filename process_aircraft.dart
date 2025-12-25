import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';

void main() async {
  final sourceFiles = [
    File(r'c:\Users\Ale\Desktop\aircraft-database-complete-2025-02.csv'),
    File(r'c:\Users\Ale\Desktop\aircraft-database-complete-2025-08.csv'),

    // Add more files here as needed
    // File(r'c:\Users\Ale\Desktop\part2.csv'),
  ];

  final outputDir = Directory('assets');
  final outputFile = File('${outputDir.path}/aircraft_db.json');

  final whitelist = {
    // Narrow bodies
    'A19N', 'A20N', 'A21N', 'A318', 'A319', 'A320', 'A321',
    'B37M', 'B38M', 'B39M', 'B3XM', 'B712', 'B736', 'B737',
    'B738', 'B739', 'BCS1', 'BCS3', 'E170', 'E190', 'E195',
    'E290', 'E295', 'CRJ2', 'CRJ7', 'CRJ9', 'CRJX',

    // Wide bodies
    'A332', 'A333', 'A338', 'A339', 'A343', 'A346', 'A359',
    'A35K', 'A388', 'B744', 'B748', 'B752', 'B753', 'B763',
    'B764', 'B772', 'B77L', 'B77W', 'B788', 'B789', 'B78X',
    'MD11',

    // Regional / Turboprops
    'AT43', 'AT45', 'AT46', 'AT72', 'AT75', 'AT76', 'DH8D',
    'DH8C', 'B190', 'B350', 'C208', 'PC12', 'SA34', 'SB20',
  };

  final data = <String, String>{};

  if (!await outputDir.exists()) {
    await outputDir.create();
  }

  int totalMatches = 0;
  int totalRows = 0;

  for (final sourceFile in sourceFiles) {
    if (!await sourceFile.exists()) {
      debugPrint('Skipping ${sourceFile.path} (not found)');
      continue;
    }

    debugPrint('Processing ${sourceFile.path}...');

    // Reading line by line to handle massive file
    final stream = sourceFile
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter());

    int count = 0;
    int fileMatchCount = 0;
    int icaoIndex = -1;
    int typeIndex = -1;

    try {
      await for (final line in stream) {
        // 1. Parse Header
        if (count == 0) {
          final headers = line
              .split(',')
              .map(
                (e) => e
                    .replaceAll("'", "")
                    .replaceAll('"', '')
                    .trim()
                    .toLowerCase(),
              )
              .toList();
          debugPrint('    Headers found: $headers');

          icaoIndex = headers.indexOf('icao24');

          // Try to find the type/model column
          if (headers.contains('typecode')) {
            typeIndex = headers.indexOf('typecode');
          } else if (headers.contains('model')) {
            typeIndex = headers.indexOf('model');
          } else {
            // Fallback check for common mismatch
            int modelIdx = headers.indexWhere(
              (h) => h.contains('model') || h.contains('type'),
            );
            if (modelIdx != -1) typeIndex = modelIdx;
          }

          debugPrint('    -> Column Indices: icao24=$icaoIndex, type=$typeIndex');

          if (icaoIndex == -1 || typeIndex == -1) {
            debugPrint(
              '    ❌ CRITICAL: Could not find required columns in extracting headers per file.',
            );
            // We continue, but subsequent extraction will fail or skip
          }

          count++;
          continue;
        }

        // 2. Parse Rows
        if (icaoIndex == -1 || typeIndex == -1) continue;

        // Simple CSV split
        final parts = line.split(',');

        // Ensure extraction is safe
        if (parts.length <= icaoIndex || parts.length <= typeIndex) continue;

        String icao = parts[icaoIndex]
            .replaceAll("'", "")
            .replaceAll('"', '')
            .trim();
        String typecode = parts[typeIndex]
            .replaceAll("'", "")
            .replaceAll('"', '')
            .trim();

        if (whitelist.contains(typecode)) {
          data[icao] = typecode;
          fileMatchCount++;
        }

        count++;
        if (count % 100000 == 0) {
          debugPrint('  Processed $count rows in this file...');
        }
      }
    } catch (e) {
      debugPrint('Error processing ${sourceFile.path}: $e');
    }

    debugPrint('  -> Finished ${sourceFile.path}. Matches: $fileMatchCount');
    totalMatches += fileMatchCount;
    totalRows += count;
  }

  debugPrint('Finished. Total rows: $totalRows. Total matches: $totalMatches');

  await outputFile.writeAsString(jsonEncode(data));
  debugPrint('Written to ${outputFile.path}');
}
