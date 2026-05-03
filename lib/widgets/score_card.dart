import 'package:flutter/material.dart';

class ScoreCard extends StatelessWidget {
  final String teamName;
  final int score;
  final bool isServing;
  final Color teamColor;

  const ScoreCard({
    super.key,
    required this.teamName,
    required this.score,
    required this.isServing,
    required this.teamColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isServing ? teamColor : Colors.grey[300]!,
          width: isServing ? 3 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                teamName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: teamColor,
                ),
              ),
              if (isServing) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.sports_tennis,
                  size: 16,
                  color: teamColor,
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$score',
            style: TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
              color: isServing ? teamColor : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}