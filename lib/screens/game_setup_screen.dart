import 'package:flutter/material.dart';
import '../models/game_models.dart';

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
          const Text(
            'Match Type',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SelectionButton(
                  label: 'Singles',
                  isSelected: widget.config.matchType == MatchType.singles,
                  onTap: () => widget.onConfigChanged(
                    widget.config.copyWith(matchType: MatchType.singles),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SelectionButton(
                  label: 'Doubles',
                  isSelected: widget.config.matchType == MatchType.doubles,
                  onTap: () => widget.onConfigChanged(
                    widget.config.copyWith(matchType: MatchType.doubles),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'Scoring System',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SelectionButton(
                  label: 'Traditional\n(Side-Out)',
                  isSelected: widget.config.scoringSystem == ScoringSystem.traditional,
                  onTap: () => widget.onConfigChanged(
                    widget.config.copyWith(scoringSystem: ScoringSystem.traditional),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SelectionButton(
                  label: 'Rally',
                  isSelected: widget.config.scoringSystem == ScoringSystem.rally,
                  onTap: () => widget.onConfigChanged(
                    widget.config.copyWith(scoringSystem: ScoringSystem.rally),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'Winning Score',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ScorePresetButton(
                score: 11,
                isSelected: widget.config.winningScore == 11,
                onTap: () => widget.onConfigChanged(
                  widget.config.copyWith(winningScore: 11),
                ),
              ),
              _ScorePresetButton(
                score: 15,
                isSelected: widget.config.winningScore == 15,
                onTap: () => widget.onConfigChanged(
                  widget.config.copyWith(winningScore: 15),
                ),
              ),
              _ScorePresetButton(
                score: 21,
                isSelected: widget.config.winningScore == 21,
                onTap: () => widget.onConfigChanged(
                  widget.config.copyWith(winningScore: 21),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                'Custom: ',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(
                width: 80,
                child: TextField(
                  controller: _customScoreController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(),
                    hintText: 'Any',
                  ),
                  onSubmitted: (value) {
                    final score = int.tryParse(value);
                    if (score != null && score > 0) {
                      widget.onConfigChanged(
                        widget.config.copyWith(winningScore: score),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SwitchListTile(
            title: const Text(
              'Win by 2',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('Game must be won by 2 or more points'),
            value: widget.config.winByTwo,
            onChanged: (value) => widget.onConfigChanged(
              widget.config.copyWith(winByTwo: value),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: widget.onStartGame,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'Start Game',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectionButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectionButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? const Color(0xFF1565C0) : Colors.grey[200],
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

class _ScorePresetButton extends StatelessWidget {
  final int score;
  final bool isSelected;
  final VoidCallback onTap;

  const _ScorePresetButton({
    required this.score,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? const Color(0xFF1565C0) : Colors.grey[200],
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          alignment: Alignment.center,
          child: Text(
            '$score',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}