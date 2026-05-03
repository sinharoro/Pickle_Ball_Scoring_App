import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_models.dart';
import '../providers/game_state_provider.dart';
import '../widgets/score_card.dart';
import '../widgets/control_button.dart';
import '../widgets/serving_indicator.dart';
import '../widgets/game_over_dialog.dart';

class GameScoreScreen extends StatelessWidget {
  const GameScoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameStateProvider>(
      builder: (context, gameState, child) {
        if (gameState.gameOver) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showGameOverDialog(context, gameState);
          });
        }

        return Column(
          children: [
            _buildScoreHeader(context, gameState),
            Expanded(
              child: _buildScoreDisplay(context, gameState),
            ),
            _buildServingInfo(context, gameState),
            _buildControls(context, gameState),
          ],
        );
      },
    );
  }

  Widget _buildScoreHeader(BuildContext context, GameStateProvider gameState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF1565C0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            gameState.isDoubles ? 'Doubles' : 'Singles',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'First to ${gameState.config.winningScore}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          Row(
            children: [
              if (gameState.isRallyScoring)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Rally',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              if (gameState.config.winByTwo) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Win by 2',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDisplay(BuildContext context, GameStateProvider gameState) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ScoreCard(
              teamName: 'Team A',
              score: gameState.teamAScore,
              isServing: gameState.servingTeam == Team.a,
              teamColor: const Color(0xFF1976D2),
            ),
            ScoreCard(
              teamName: 'Team B',
              score: gameState.teamBScore,
              isServing: gameState.servingTeam == Team.b,
              teamColor: const Color(0xFFD32F2F),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            gameState.scoreDisplay,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServingInfo(BuildContext context, GameStateProvider gameState) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ServingIndicator(
            team: gameState.servingTeam,
            serverNumber: gameState.serverNumber,
            isDoubles: gameState.isDoubles,
            serverSide: gameState.serverSide,
          ),
        ],
      ),
    );
  }

  Widget _buildControls(BuildContext context, GameStateProvider gameState) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ControlButton(
                  label: 'Point for Team A',
                  color: const Color(0xFF1976D2),
                  onPressed: gameState.gameOver
                      ? null
                      : () => gameState.recordPointForTeam(Team.a),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ControlButton(
                  label: 'Point for Team B',
                  color: const Color(0xFFD32F2F),
                  onPressed: gameState.gameOver
                      ? null
                      : () => gameState.recordPointForTeam(Team.b),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ControlButton(
                  label: gameState.isRallyScoring ? 'N/A' : 'Fault / Side Out',
                  color: Colors.orange[700]!,
                  onPressed: gameState.gameOver || gameState.isRallyScoring
                      ? null
                      : () => gameState.recordFault(),
                  enabled: !gameState.isRallyScoring && !gameState.gameOver,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ControlButton(
                  label: 'Undo Last Action',
                  color: Colors.grey[600]!,
                  onPressed: gameState.canUndo && !gameState.gameOver
                      ? () => gameState.undoLastAction()
                      : null,
                  enabled: gameState.canUndo && !gameState.gameOver,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ControlButton(
                  label: 'Reset Game',
                  color: Colors.red[700]!,
                  onPressed: () => _showResetConfirmation(context, gameState),
                  enabled: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showResetConfirmation(BuildContext context, GameStateProvider gameState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Game?'),
        content: const Text('Are you sure you want to reset the game? All scores will be cleared.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              gameState.resetGame();
              Navigator.of(context).pop();
            },
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showGameOverDialog(BuildContext context, GameStateProvider gameState) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameOverDialog(
        winner: gameState.winner!,
        teamAScore: gameState.teamAScore,
        teamBScore: gameState.teamBScore,
        onNewGame: () {
          Navigator.of(context).pop();
          gameState.resetGame();
        },
        onSetup: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}