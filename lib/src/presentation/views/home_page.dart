import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/flight_search_card.dart';
import '../widgets/home_footer.dart';
import '../widgets/home_header.dart';

class FlightSearchScreen extends ConsumerStatefulWidget {
  const FlightSearchScreen({super.key});

  @override
  ConsumerState<FlightSearchScreen> createState() => _FlightSearchScreenState();
}

class _FlightSearchScreenState extends ConsumerState<FlightSearchScreen> {
  @override
  Widget build(BuildContext context) {
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
        child: const Center(
          child: /* Text(
            "We'll be back soon!",
            style: TextStyle(color: Colors.white, fontSize: 24),
          ) */ SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                HomeHeader(),
                SizedBox(height: 48),
                FlightSearchCard(),
                SizedBox(height: 32),
                HomeFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
