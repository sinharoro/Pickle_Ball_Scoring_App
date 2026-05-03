import 'package:flutter/foundation.dart';
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

  String get scoreDisplay {
    int serverScore = ScoringEngine.getServerScore(_servingTeam, _teamAScore, _teamBScore);
    int receiverScore = ScoringEngine.getReceiverScore(_servingTeam, _teamAScore, _teamBScore);
    
    if (_config.matchType == MatchType.doubles) {
      return '$serverScore - $receiverScore - ${_serverNumber == ServerNumber.one ? 1 : 2}';
    }
    return '$serverScore - $receiverScore';
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
      _handleServerRotationDoubles(winningTeam == _servingTeam);
    }
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
        _handleServerRotationDoubles(false);
      }
    }
  }

  void _handleServerRotationDoubles(bool pointWon) {
    if (pointWon) {
      if (_serverNumber == ServerNumber.one) {
        _serverNumber = ServerNumber.two;
      }
    } else {
      if (_serverNumber == ServerNumber.two) {
        _serverNumber = ServerNumber.one;
        _switchServingTeam();
      } else {
        _serverNumber = ServerNumber.one;
      }
    }
    _isFirstServe = false;
  }

  void _switchServingTeam() {
    _servingTeam = _servingTeam == Team.a ? Team.b : Team.a;
    _serverNumber = ServerNumber.two;
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
      _handleServerRotationDoubles(false);
    } else {
      _switchServingTeam();
    }

    _updateServerSide();
    notifyListeners();
  }

  void _checkGameOver() {
    int serverScore = _servingTeam == Team.a ? _teamAScore : _teamBScore;
    int receiverScore = _servingTeam == Team.a ? _teamBScore : _teamAScore;
    
    if (_config.scoringSystem == ScoringSystem.rally) {
      if (serverScore >= _config.winningScore || receiverScore >= _config.winningScore) {
        if (_config.winByTwo) {
          if (serverScore >= _config.winningScore - 1 && 
              receiverScore >= _config.winningScore - 1) {
            int margin = serverScore - receiverScore;
            if (margin >= 2) {
              _winner = _servingTeam;
              _gameOver = true;
            } else if (-margin >= 2) {
              _winner = _servingTeam == Team.a ? Team.b : Team.a;
              _gameOver = true;
            }
          }
        } else {
          _winner = serverScore > receiverScore ? _servingTeam : (receiverScore > serverScore ? (_servingTeam == Team.a ? Team.b : Team.a) : null);
          _gameOver = _winner != null;
        }
      }
    } else {
      if (_config.winByTwo) {
        if (serverScore >= _config.winningScore - 1 && receiverScore >= _config.winningScore - 1) {
          int margin = serverScore - receiverScore;
          if (margin >= 2) {
            _winner = _servingTeam;
            _gameOver = true;
          }
        } else if (serverScore >= _config.winningScore) {
          _winner = _servingTeam;
          _gameOver = true;
        }
      } else {
        if (serverScore >= _config.winningScore) {
          _winner = _servingTeam;
          _gameOver = true;
        }
      }
    }
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
    
    notifyListeners();
  }
}