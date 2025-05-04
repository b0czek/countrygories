import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class LetterWheel extends StatefulWidget {
  final VoidCallback? onStop;

  const LetterWheel({super.key, this.onStop});

  @override
  State<LetterWheel> createState() => _LetterWheelState();
}

class _LetterWheelState extends State<LetterWheel> {
  final List<String> _letters = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'R',
    'S',
    'T',
    'U',
    'W',
    'Z',
  ];

  final Random _random = Random();
  Timer? _timer;
  int _currentIndex = 0;
  bool _isSpinning = false;

  @override
  void initState() {
    super.initState();
    _startSpinning();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startSpinning() {
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
    });

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _currentIndex = _random.nextInt(_letters.length);
      });
    });
  }

  void _stopSpinning() {
    if (!_isSpinning || widget.onStop == null) return;

    _timer?.cancel();

    setState(() {
      _isSpinning = false;
    });

    widget.onStop?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _stopSpinning,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.2 * 255).round()),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 100),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Text(
              _letters[_currentIndex],
              key: ValueKey<int>(_currentIndex),
              style: const TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
