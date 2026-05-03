enum MatchType { singles, doubles }

enum ScoringSystem { traditional, rally }

enum Team { a, b }

enum CourtSide { left, right }

enum ServerNumber { one, two }

class GameConfig {
  final MatchType matchType;
  final ScoringSystem scoringSystem;
  final int winningScore;
  final bool winByTwo;

  const GameConfig({
    required this.matchType,
    required this.scoringSystem,
    required this.winningScore,
    required this.winByTwo,
  });

  GameConfig copyWith({
    MatchType? matchType,
    ScoringSystem? scoringSystem,
    int? winningScore,
    bool? winByTwo,
  }) {
    return GameConfig(
      matchType: matchType ?? this.matchType,
      scoringSystem: scoringSystem ?? this.scoringSystem,
      winningScore: winningScore ?? this.winningScore,
      winByTwo: winByTwo ?? this.winByTwo,
    );
  }
}

class GameStateSnapshot {
  final int teamAScore;
  final int teamBScore;
  final Team servingTeam;
  final ServerNumber? serverNumber;
  final CourtSide serverSide;
  final bool isFirstServe;
  final DateTime timestamp;

  const GameStateSnapshot({
    required this.teamAScore,
    required this.teamBScore,
    required this.servingTeam,
    required this.serverNumber,
    required this.serverSide,
    required this.isFirstServe,
    required this.timestamp,
  });
}