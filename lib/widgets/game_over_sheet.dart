import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/game_models.dart';
import '../providers/game_state_provider.dart';
import '../theme/app_colors.dart';

class GameOverSheet extends StatefulWidget {
  final Team winner;
  final int teamAScore;
  final int teamBScore;
  final VoidCallback onNewGame;
  final VoidCallback onSetup;

  const GameOverSheet({
    super.key,
    required this.winner,
    required this.teamAScore,
    required this.teamBScore,
    required this.onNewGame,
    required this.onSetup,
  });

  @override
  State<GameOverSheet> createState() => _GameOverSheetState();
}

class _GameOverSheetState extends State<GameOverSheet> with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late AnimationController _slideController;
  final List<ConfettiParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    for (int i = 0; i < 40; i++) {
      _particles.add(ConfettiParticle(
        x: _random.nextDouble(),
        speed: 0.3 + _random.nextDouble() * 0.7,
        size: 6 + _random.nextDouble() * 8,
        color: [
          AppColors.accent,
          AppColors.teamA,
          AppColors.teamB,
          AppColors.fault,
        ][_random.nextInt(4)],
      ));
    }

    _slideController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _confettiController.repeat();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final winnerName = widget.winner == Team.a ? 'TEAM A' : 'TEAM B';
    final winnerColor = widget.winner == Team.a ? AppColors.teamA : AppColors.teamB;
    final loserScore = widget.winner == Team.a ? widget.teamBScore : widget.teamAScore;
    final winnerScore = widget.winner == Team.a ? widget.teamAScore : widget.teamBScore;

    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _slideController.value) * 300),
          child: Opacity(
            opacity: _slideController.value,
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.bgCardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _confettiController,
                    builder: (context, _) {
                      return CustomPaint(
                        size: const Size(double.infinity, 100),
                        painter: ConfettiPainter(
                          particles: _particles,
                          progress: _confettiController.value,
                        ),
                      );
                    },
                  ),
                  Text(
                    'GAME OVER',
                    style: GoogleFonts.bebasNeue(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                      letterSpacing: 4,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                '$winnerName WINS!',
                style: GoogleFonts.bebasNeue(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: winnerColor,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ScoreBox(
                    score: winnerScore,
                    teamName: winnerName,
                    color: winnerColor,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'VS',
                      style: GoogleFonts.bebasNeue(
                        fontSize: 24,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  _ScoreBox(
                    score: loserScore,
                    teamName: widget.winner == Team.a ? 'TEAM B' : 'TEAM A',
                    color: widget.winner == Team.a ? AppColors.teamB : AppColors.teamA,
                  ),
                ],
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<GameStateProvider>().resetGame();
                    widget.onNewGame();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.bg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'PLAY AGAIN',
                    style: GoogleFonts.bebasNeue(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: widget.onSetup,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.bgCardBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'CHANGE SETUP',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreBox extends StatelessWidget {
  final int score;
  final String teamName;
  final Color color;

  const _ScoreBox({
    required this.score,
    required this.teamName,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            '$score',
            style: GoogleFonts.bebasNeue(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            teamName,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class ConfettiParticle {
  final double x;
  final double speed;
  final double size;
  final Color color;

  ConfettiParticle({
    required this.x,
    required this.speed,
    required this.size,
    required this.color,
  });
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;

  ConfettiPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final y = (progress * particle.speed * 3 + 0.1) % 1.2 - 0.1;
      final paint = Paint()
        ..color = particle.color.withOpacity(1 - progress * 0.8)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(particle.x * size.width, y * size.height),
        particle.size / 2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}