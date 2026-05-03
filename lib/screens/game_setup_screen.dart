import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_models.dart';
import '../theme/app_colors.dart';

class GameSetupScreen extends StatefulWidget {
  final GameConfig config;
  final Function(GameConfig) onConfigChanged;
  final VoidCallback onStartGame;

  const GameSetupScreen({
    super.key,
    required this.config,
    required this.onConfigChanged,
    required this.onStartGame,
  });

  @override
  State<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends State<GameSetupScreen> {
  late TextEditingController _customScoreController;
  final List<int> _scorePresets = [11, 15, 21];
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _customScoreController = TextEditingController();
  }

  @override
  void dispose() {
    _customScoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.sports_tennis,
                color: AppColors.accent,
                size: 32,
              ),
              const SizedBox(width: 8),
              Text(
                'PICKLEBALL',
                style: GoogleFonts.bebasNeue(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'SCOREKEEPER',
                style: GoogleFonts.bebasNeue(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMuted,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          _SectionHeader(title: 'MATCH TYPE'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _OptionCard(
                  label: 'SINGLES',
                  isSelected: widget.config.matchType == MatchType.singles,
                  onTap: () => widget.onConfigChanged(
                    widget.config.copyWith(matchType: MatchType.singles),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _OptionCard(
                  label: 'DOUBLES',
                  isSelected: widget.config.matchType == MatchType.doubles,
                  onTap: () => widget.onConfigChanged(
                    widget.config.copyWith(matchType: MatchType.doubles),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _SectionHeader(title: 'SCORING SYSTEM'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _OptionCard(
                  label: 'TRADITIONAL',
                  subtitle: 'Side-Out scoring',
                  isSelected: widget.config.scoringSystem == ScoringSystem.traditional,
                  onTap: () => widget.onConfigChanged(
                    widget.config.copyWith(scoringSystem: ScoringSystem.traditional),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _OptionCard(
                  label: 'RALLY',
                  subtitle: 'Every rally scores',
                  isSelected: widget.config.scoringSystem == ScoringSystem.rally,
                  onTap: () => widget.onConfigChanged(
                    widget.config.copyWith(scoringSystem: ScoringSystem.rally),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _SectionHeader(title: 'GAME TO'),
          const SizedBox(height: 12),
          Row(
            children: [
              ..._scorePresets.map((score) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: score != _scorePresets.last ? 12 : 0,
                  ),
                  child: _PillButton(
                    label: '$score',
                    isSelected: widget.config.winningScore == score,
                    onTap: () => widget.onConfigChanged(
                      widget.config.copyWith(winningScore: score),
                    ),
                  ),
                ),
              )),
            ],
          ),
          const SizedBox(height: 16),
          _CustomScoreField(
            controller: _customScoreController,
            onSubmit: (value) {
              final score = int.tryParse(value);
              if (score != null && score > 0 && !_scorePresets.contains(score)) {
                widget.onConfigChanged(
                  widget.config.copyWith(winningScore: score),
                );
              }
            },
          ),
          const SizedBox(height: 32),
          _SectionHeader(title: 'WIN BY 2'),
          const SizedBox(height: 12),
          _CustomToggle(
            value: widget.config.winByTwo,
            onChanged: (value) => widget.onConfigChanged(
              widget.config.copyWith(winByTwo: value),
            ),
          ),
          const SizedBox(height: 40),
          GestureDetector(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) {
              setState(() => _isPressed = false);
              HapticFeedback.mediumImpact();
              widget.onStartGame();
            },
            onTapCancel: () => setState(() => _isPressed = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              transform: Matrix4.identity()..scale(_isPressed ? 0.97 : 1.0),
              transformAlignment: Alignment.center,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'START GAME',
                  style: GoogleFonts.bebasNeue(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.bg,
                    letterSpacing: 3,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
        letterSpacing: 1.5,
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionCard({
    required this.label,
    this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.bgCardBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: GoogleFonts.bebasNeue(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.accent : AppColors.textMuted,
                letterSpacing: 2,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PillButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.bgCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.bgCardBorder,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.bebasNeue(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isSelected ? AppColors.bg : AppColors.textMuted,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomScoreField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSubmit;

  const _CustomScoreField({
    required this.controller,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: GoogleFonts.inter(
        fontSize: 18,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: 'Custom',
        hintStyle: GoogleFonts.inter(
          fontSize: 16,
          color: AppColors.textMuted,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: AppColors.bgCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.bgCardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.bgCardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.accent, width: 2),
        ),
      ),
      onSubmitted: onSubmit,
    );
  }
}

class _CustomToggle extends StatefulWidget {
  final bool value;
  final Function(bool) onChanged;

  const _CustomToggle({
    required this.value,
    required this.onChanged,
  });

  @override
  State<_CustomToggle> createState() => _CustomToggleState();
}

class _CustomToggleState extends State<_CustomToggle> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.bgCardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Win by 2 points',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onChanged(!widget.value);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52,
              height: 32,
              decoration: BoxDecoration(
                color: widget.value ? AppColors.accent : AppColors.bgCardBorder,
                borderRadius: BorderRadius.circular(16),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: widget.value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 28,
                  height: 28,
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}