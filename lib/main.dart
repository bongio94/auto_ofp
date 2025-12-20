import 'package:auto_ofp/src/presentation/views/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const ProviderScope(child: AutoOfpApp()));
}

class AutoOfpApp extends StatelessWidget {
  const AutoOfpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'AutoOFP',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate 900
          primaryColor: const Color(0xFF38BDF8), // Sky 400
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF38BDF8),
            secondary: Color(0xFF818CF8), // Indigo 400
            surface: Color(0xFF1E293B), // Slate 800
          ),
          textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
          useMaterial3: true,
        ),
        home: FlightSearchScreen(),
      ),
    );
  }
}
