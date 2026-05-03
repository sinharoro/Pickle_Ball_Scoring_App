import 'package:flutter/material.dart';
import '../models/game_models.dart';

class GameOverDialog extends StatelessWidget {
  final Team winner;
  final int teamAScore;
  final int teamBScore;
  final VoidCallback onNewGame;
  final VoidCallback onSetup;

  const GameOverDialog({
    super.key,
    required this.winner,
    required this.teamAScore,
    required this.teamBScore,
    required this.onNewGame,
    required this.onSetup,
  });

  @override
  Widget build(BuildContext context) {
    final winnerName = winner == Team.a ? 'Team A' : 'Team B';
    final winnerColor = winner == Team.a 
        ? const Color(0xFF1976D2) 
        : const Color(0xFFD32F2F);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.emoji_events, color: Colors.amber[700], size: 32),
          const SizedBox(width: 8),
          const Text('Game Over!'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Winner: $winnerName',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: winnerColor,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Text(
                      'Team A',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                    Text(
                      '$teamAScore',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                  ],
                ),
                const Text(
                  'vs',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                Column(
                  children: [
                    const Text(
                      'Team B',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD32F2F),
                      ),
                    ),
                    Text(
                      '$teamBScore',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD32F2F),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onSetup,
          child: const Text('Game Setup'),
        ),
        ElevatedButton(
          onPressed: onNewGame,
          style: ElevatedButton.styleFrom(
            backgroundColor: winnerColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('New Game'),
        ),
      ],
    );
  }
}