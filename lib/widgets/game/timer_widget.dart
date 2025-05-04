import 'package:flutter/material.dart';

class TimerWidget extends StatelessWidget {
  final int remainingTime;

  const TimerWidget({super.key, required this.remainingTime});

  @override
  Widget build(BuildContext context) {
    final minutes = remainingTime ~/ 60;
    final seconds = remainingTime % 60;

    final timeString =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    Color color = Colors.green;
    if (remainingTime <= 10) {
      color = Colors.red;
    } else if (remainingTime <= 30) {
      color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha((0.2 * 255).round()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer, color: color, size: 20),
          const SizedBox(width: 4),
          Text(
            timeString,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
