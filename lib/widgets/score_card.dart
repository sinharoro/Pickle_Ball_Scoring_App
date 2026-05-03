import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class ScoreCard extends StatefulWidget {
  final String teamName;
  final int score;
  final bool isServing;
  final Color teamColor;
  final int? serverNumber;
  final bool showServerInfo;

  const ScoreCard({
    super.key,
    required this.teamName,
    required this.score,
    required this.isServing,
    required this.teamColor,
    this.serverNumber,
    this.showServerInfo = false,
  });

  @override
  State<ScoreCard> createState() => _ScoreCardState();
}

class _ScoreCardState extends State<ScoreCard> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  int _previousScore = 0;

  @override
  void initState() {
    super.initState();
    _previousScore = widget.score;
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    if (widget.isServing) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ScoreCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.score != _previousScore) {
      _previousScore = widget.score;
    }
    if (widget.isServing && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isServing && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isServing ? _pulseAnimation.value : 1.0,
          child: child,
        );
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) {
          return ScaleTransition(
            scale: animation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: Container(
          key: ValueKey(widget.score),
          width: 160,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isServing ? AppColors.accent : AppColors.bgCardBorder,
              width: widget.isServing ? 2 : 1,
            ),
            boxShadow: widget.isServing
                ? [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.2),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.teamName.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: widget.isServing ? widget.teamColor : AppColors.textMuted,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.score}',
                style: GoogleFonts.bebasNeue(
                  fontSize: 96,
                  fontWeight: FontWeight.bold,
                  color: widget.isServing ? AppColors.textPrimary : AppColors.textMuted,
                  height: 1,
                ),
              ),
              if (widget.isServing && widget.showServerInfo) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'SERVING',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}