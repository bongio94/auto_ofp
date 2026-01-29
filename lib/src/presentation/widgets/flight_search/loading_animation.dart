import 'dart:async';
import 'package:flutter/material.dart';

class LoadingTextAnimation extends StatefulWidget {
  const LoadingTextAnimation({super.key});

  @override
  State<LoadingTextAnimation> createState() => _LoadingTextAnimationState();
}

class _LoadingTextAnimationState extends State<LoadingTextAnimation> {
  int _index = 0;
  Timer? _timer;

  final List<String> _phrases = [
    "CONTACTING ATC...",
    "ALIGNING IRS...",
    "CHECKING OFP...",
    "LOADING CARGO...",
    "SPOOLING ENGINES...",
    "REQUESTING CLEARANCE...",
    "CHECKING WEATHER...",
    "CALCULATING PERFORMANCE...",
    "FILLING FUEL TANKS...",
    "BOARDING PASSENGERS...",
    "SYNCING FMC...",
    "CONFIGURING FLAPS...",
    "ARMING SPOILERS...",
    "CHECKING NOTAMS...",
    "VERIFYING PAYLOAD...",
    "SETTING TRANSPONDER...",
    "TUNING RADIOS...",
    "CALIBRATING ALTIMETER...",
    "CHECKING HYDRAULICS...",
    "TESTING APU...",
    "SECURING CABIN...",
    "UPDATING AIRAC...",
    "CALCULATING V-SPEEDS...",
    "CHECKING BRAKE TEMPS...",
    "INITIALIZING NAV DATA...",
    "VERIFYING FLIGHT PLAN...",
    "CHECKING ANTI-ICE...",
    "TESTING FIRE SYSTEMS...",
    "MONITORING OIL PRESSURE...",
    "ADJUSTING TRIM...",
  ];

  @override
  void initState() {
    super.initState();
    _phrases.shuffle();
    _timer = Timer.periodic(const Duration(milliseconds: 1200), (timer) {
      if (mounted) {
        setState(() {
          _index = (_index + 1) % _phrases.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      transitionBuilder: (child, animation) {
        final curve = CurvedAnimation(
          parent: animation,
          curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
        );

        final offset = Tween<Offset>(
          begin: const Offset(0.0, 0.5),
          end: Offset.zero,
        ).animate(curve);

        return SlideTransition(
          position: offset,
          child: FadeTransition(
            opacity: curve,
            child: child,
          ),
        );
      },
      child: Text(
        _phrases[_index],
        key: ValueKey<String>(_phrases[_index]),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
