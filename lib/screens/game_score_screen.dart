import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/game_models.dart';
import '../providers/game_state_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/score_card.dart';
import '../widgets/control_button.dart';
import '../widgets/game_over_sheet.dart';
import '../widgets/reset_confirm_sheet.dart';
import '../widgets/score_log_sheet.dart';

class GameScoreScreen extends StatefulWidget {
  final VoidCallback onBackToSetup;

  const GameScoreScreen({
    super.key,
    required this.onBackToSetup,
  });

  @override
  State<GameScoreScreen> createState() => _GameScoreScreenState();
}

class _GameScoreScreenState extends State<GameScoreScreen> {
  bool _gameOverShown = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<GameStateProvider>(
      builder: (context, gameState, child) {
        if (gameState.gameOver && !_gameOverShown) {
          _gameOverShown = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showGameOverSheet(context, gameState);
          });
        }

        return Column(
          children: [
            _buildTopBar(context, gameState),
            Expanded(
              child: _buildScoreDisplay(context, gameState),
            ),
            _buildScoreNotationBar(context, gameState),
            _buildControls(context, gameState),
          ],
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context, GameStateProvider gameState) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: AppColors.bgCard,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              gameState.resetGame();
              widget.onBackToSetup();
            },
            child: Row(
              children: [
                const Icon(
                  Icons.arrow_back,
                  color: AppColors.textMuted,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  'SETUP',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _ModeChip(label: gameState.isDoubles ? 'DOUBLES' : 'SINGLES'),
              const SizedBox(width: 8),
              _ModeChip(label: gameState.isRallyScoring ? 'RALLY' : 'TRAD'),
              if (gameState.config.winByTwo) ...[
                const SizedBox(width: 8),
                _ModeChip(label: 'WIN BY 2'),
              ],
            ],
          ),
          GestureDetector(
            onTap: () => _showScoreLogSheet(context, gameState),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.history,
                    color: AppColors.textMuted,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'LOG',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
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
              teamColor: AppColors.teamA,
              showServerInfo: true,
            ),
            ScoreCard(
              teamName: 'Team B',
              score: gameState.teamBScore,
              isServing: gameState.servingTeam == Team.b,
              teamColor: AppColors.teamB,
              showServerInfo: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScoreNotationBar(BuildContext context, GameStateProvider gameState) {
    String sideText = gameState.serverSide == CourtSide.right ? 'RIGHT COURT' : 'LEFT COURT';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.bgCardBorder),
      ),
      child: Column(
        children: [
          Text(
            gameState.scoreDisplay,
            style: GoogleFonts.bebasNeue(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.accent,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${gameState.servingTeam == Team.a ? 'Team A' : 'Team B'} · Server ${gameState.serverNumber == ServerNumber.one ? '1' : '2'} · $sideText',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(BuildContext context, GameStateProvider gameState) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ControlButton(
                  label: 'TEAM A',
                  sublabel: '+1',
                  color: AppColors.teamA,
                  onPressed: gameState.gameOver
                      ? null
                      : () {
                          HapticFeedback.mediumImpact();
                          gameState.recordPointForTeam(Team.a);
                        },
                  enabled: !gameState.gameOver,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ControlButton(
                  label: 'TEAM B',
                  sublabel: '+1',
                  color: AppColors.teamB,
                  onPressed: gameState.gameOver
                      ? null
                      : () {
                          HapticFeedback.mediumImpact();
                          gameState.recordPointForTeam(Team.b);
                        },
                  enabled: !gameState.gameOver,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ControlButton(
            label: 'FAULT / SIDE OUT',
            icon: Icons.flash_on,
            color: AppColors.fault,
            onPressed: gameState.gameOver || gameState.isRallyScoring
                ? null
                : () {
                    HapticFeedback.lightImpact();
                    gameState.recordFault();
                  },
            enabled: !gameState.isRallyScoring && !gameState.gameOver,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ControlButton(
                  label: 'UNDO',
                  icon: Icons.undo,
                  color: AppColors.textMuted,
                  outlined: true,
                  onPressed: gameState.canUndo && !gameState.gameOver
                      ? () => gameState.undoLastAction()
                      : null,
                  enabled: gameState.canUndo && !gameState.gameOver,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ControlButton(
                  label: 'RESET',
                  icon: Icons.refresh,
                  color: AppColors.textMuted,
                  outlined: true,
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ResetConfirmSheet(
        onReset: () {
          gameState.resetGame();
          Navigator.of(context).pop();
        },
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _showGameOverSheet(BuildContext context, GameStateProvider gameState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => GameOverSheet(
        winner: gameState.winner!,
        teamAScore: gameState.teamAScore,
        teamBScore: gameState.teamBScore,
        onNewGame: () {
          Navigator.of(context).pop();
          _gameOverShown = false;
        },
        onSetup: () {
          Navigator.of(context).pop();
          gameState.resetGame();
          _gameOverShown = false;
          widget.onBackToSetup();
        },
      ),
    );
  }

  void _showScoreLogSheet(BuildContext context, GameStateProvider gameState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ScoreLogSheet(
        actionLog: gameState.actionLog,
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final String label;

  const _ModeChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.accent,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}