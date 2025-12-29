import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/home/flight_search_card.dart';
import '../widgets/home/home_footer.dart';
import '../widgets/home/home_header.dart';
import '../widgets/home/community_feed.dart';

class FlightSearchScreen extends ConsumerStatefulWidget {
  const FlightSearchScreen({super.key});

  @override
  ConsumerState<FlightSearchScreen> createState() => _FlightSearchScreenState();
}

class _FlightSearchScreenState extends ConsumerState<FlightSearchScreen> {
  bool _hasResults = false;
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 900;

            if (isDesktop) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(left: 100, right: 4),
                            width: 814,
                            child: CommunityFeed(),
                          ),
                          const SizedBox(height: 24),
                          IntrinsicHeight(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(
                                  width: 350,
                                  child: AnimatedAlign(
                                    duration: const Duration(milliseconds: 600),
                                    curve: Curves.fastOutSlowIn,
                                    alignment: _hasResults
                                        ? Alignment.topRight
                                        : Alignment.centerRight,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        HomeHeader(),
                                        SizedBox(height: 16),
                                        HomeFooter(),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 64),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: FlightSearchCard(
                                    onResultsFound: (val) {
                                      if (_hasResults != val) {
                                        setState(() => _hasResults = val);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      HomeHeader(),
                      SizedBox(height: 48),
                      FlightSearchCard(),
                      SizedBox(height: 32),
                      CommunityFeed(),
                      SizedBox(height: 16),
                      HomeFooter(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
