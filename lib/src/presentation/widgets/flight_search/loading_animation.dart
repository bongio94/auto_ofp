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
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
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
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        final offset =
            Tween<Offset>(
              begin: const Offset(0.0, 0.5),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            );
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: offset,
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
