import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/game_models.dart';
import '../engine/scoring_engine.dart';

class GameStateProvider extends ChangeNotifier {
  GameConfig _config = const GameConfig(
    matchType: MatchType.doubles,
    scoringSystem: ScoringSystem.traditional,
    winningScore: 11,
    winByTwo: true,
  );

  int _teamAScore = 0;
  int _teamBScore = 0;
  Team _servingTeam = Team.a;
  ServerNumber _serverNumber = ServerNumber.two;
  CourtSide _serverSide = CourtSide.right;
  bool _isFirstServe = true;
  bool _gameOver = false;
  Team? _winner;
  final List<GameStateSnapshot> _history = [];
  final List<String> _actionLog = [];

  GameConfig get config => _config;
  int get teamAScore => _teamAScore;
  int get teamBScore => _teamBScore;
  Team get servingTeam => _servingTeam;
  ServerNumber? get serverNumber => _config.matchType == MatchType.doubles ? _serverNumber : null;
  CourtSide get serverSide => _serverSide;
  bool get isFirstServe => _isFirstServe;
  bool get gameOver => _gameOver;
  Team? get winner => _winner;
  bool get canUndo => _history.isNotEmpty;
  bool get isDoubles => _config.matchType == MatchType.doubles;
  bool get isRallyScoring => _config.scoringSystem == ScoringSystem.rally;
  List<String> get actionLog => List.unmodifiable(_actionLog);

  String get scoreDisplay {
    int serverScore = ScoringEngine.getServerScore(_servingTeam, _teamAScore, _teamBScore);
    int receiverScore = ScoringEngine.getReceiverScore(_servingTeam, _teamAScore, _teamBScore);
    
    if (_config.matchType == MatchType.doubles) {
      int srvNum = _serverNumber == ServerNumber.one ? 1 : 2;
      return '$serverScore – $receiverScore – $srvNum';
    }
    return '$serverScore – $receiverScore';
  }

  int getServerScore() => ScoringEngine.getServerScore(_servingTeam, _teamAScore, _teamBScore);
  int getReceiverScore() => ScoringEngine.getReceiverScore(_servingTeam, _teamAScore, _teamBScore);

  void setConfig(GameConfig newConfig) {
    _config = newConfig;
    resetGame();
  }

  void updateMatchType(MatchType type) {
    _config = _config.copyWith(matchType: type);
    resetGame();
  }

  void updateScoringSystem(ScoringSystem system) {
    _config = _config.copyWith(scoringSystem: system);
    resetGame();
  }

  void updateWinningScore(int score) {
    _config = _config.copyWith(winningScore: score);
    resetGame();
  }

  void updateWinByTwo(bool value) {
    _config = _config.copyWith(winByTwo: value);
    notifyListeners();
  }

  void _saveState() {
    _history.add(GameStateSnapshot(
      teamAScore: _teamAScore,
      teamBScore: _teamBScore,
      servingTeam: _servingTeam,
      serverNumber: _serverNumber,
      serverSide: _serverSide,
      isFirstServe: _isFirstServe,
      timestamp: DateTime.now(),
    ));
  }

  void recordPointForTeam(Team team) {
    if (_gameOver) return;

    _saveState();

    if (_config.scoringSystem == ScoringSystem.rally) {
      _handleRallyScoringPoint(team);
    } else {
      _handleTraditionalScoringPoint(team);
    }

    _logAction('${team == Team.a ? 'Team A' : 'Team B'} scored (${scoreDisplay})');
    _checkGameOver();
    _updateServerSide();
    notifyListeners();
  }

  void _handleRallyScoringPoint(Team winningTeam) {
    if (winningTeam == Team.a) {
      _teamAScore++;
    } else {
      _teamBScore++;
    }

    if (_config.matchType == MatchType.doubles) {
      if (winningTeam != _servingTeam) {
        _servingTeam = winningTeam;
        _serverNumber = ServerNumber.one;
      }
    } else {
      if (winningTeam != _servingTeam) {
        _servingTeam = winningTeam;
      }
    }
    _isFirstServe = false;
  }

  void _handleTraditionalScoringPoint(Team team) {
    if (team == _servingTeam) {
      if (team == Team.a) {
        _teamAScore++;
      } else {
        _teamBScore++;
      }

      if (_config.matchType == MatchType.doubles) {
        _handleServerRotationDoubles(true);
      }
    } else {
      if (_config.matchType == MatchType.doubles) {
        _handleDoubleFault();
      } else {
        _servingTeam = _servingTeam == Team.a ? Team.b : Team.a;
      }
    }
  }

  void _handleServerRotationDoubles(bool pointWon) {
    if (pointWon) {
      _isFirstServe = false;
    } else {
      _handleDoubleFault();
    }
  }

  void _handleDoubleFault() {
    if (_isFirstServe) {
      _isFirstServe = false;
      _servingTeam = _servingTeam == Team.a ? Team.b : Team.a;
      _serverNumber = ServerNumber.two;
      _logAction('Side-out → ${_servingTeam == Team.a ? 'Team A' : 'Team B'} serves (${scoreDisplay})');
    } else if (_serverNumber == ServerNumber.two) {
      _serverNumber = ServerNumber.one;
      _logAction('Fault → Server 1 serves (${scoreDisplay})');
    } else {
      _servingTeam = _servingTeam == Team.a ? Team.b : Team.a;
      _serverNumber = ServerNumber.two;
      _logAction('Side-out → ${_servingTeam == Team.a ? 'Team A' : 'Team B'} serves (${scoreDisplay})');
    }
    _isFirstServe = false;
  }

  void _updateServerSide() {
    int score = _servingTeam == Team.a ? _teamAScore : _teamBScore;
    _serverSide = ScoringEngine.getServerSide(score);
  }

  void recordFault() {
    if (_gameOver) return;
    if (_config.scoringSystem == ScoringSystem.rally) return;

    _saveState();

    if (_config.matchType == MatchType.doubles) {
      _handleDoubleFault();
    } else {
      _servingTeam = _servingTeam == Team.a ? Team.b : Team.a;
      _logAction('Side-out → ${_servingTeam == Team.a ? 'Team A' : 'Team B'} serves (${scoreDisplay})');
    }

    _updateServerSide();
    notifyListeners();
  }

  void _checkGameOver() {
    final int aScore = _teamAScore;
    final int bScore = _teamBScore;
    final int target = _config.winningScore;

    bool aWins = aScore >= target;
    bool bWins = bScore >= target;

    if (!aWins && !bWins) return;

    if (_config.winByTwo) {
      int diff = (aScore - bScore).abs();
      if (diff < 2) return;
      _winner = aScore > bScore ? Team.a : Team.b;
    } else {
      _winner = aScore >= target && aScore > bScore
          ? Team.a
          : bScore >= target && bScore > aScore
              ? Team.b
              : null;
    }

    if (_winner != null) {
      _gameOver = true;
      HapticFeedback.heavyImpact();
      _logAction('Game Over! ${_winner == Team.a ? 'Team A' : 'Team B'} wins ${aScore}-$bScore');
    }
  }

  void _logAction(String message) {
    _actionLog.add(message);
  }

  void undoLastAction() {
    if (_history.isEmpty) return;

    final snapshot = _history.removeLast();
    _teamAScore = snapshot.teamAScore;
    _teamBScore = snapshot.teamBScore;
    _servingTeam = snapshot.servingTeam;
    _serverNumber = snapshot.serverNumber ?? ServerNumber.two;
    _serverSide = snapshot.serverSide;
    _isFirstServe = snapshot.isFirstServe;
    _gameOver = false;
    _winner = null;
    
    if (_actionLog.isNotEmpty) {
      _actionLog.removeLast();
    }
    HapticFeedback.lightImpact();
    notifyListeners();
  }

  void resetGame() {
    _teamAScore = 0;
    _teamBScore = 0;
    _servingTeam = Team.a;
    _serverNumber = ServerNumber.two;
    _serverSide = CourtSide.right;
    _isFirstServe = true;
    _gameOver = false;
    _winner = null;
    _history.clear();
    _actionLog.clear();
    
    notifyListeners();
  }
}