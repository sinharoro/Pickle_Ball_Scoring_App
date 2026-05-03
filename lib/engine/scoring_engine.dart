import '../models/game_models.dart';

class ScoringEngine {
  static const int defaultWinningScore = 11;
  static const int defaultWinByTwo = 2;

  static int getServerScore(Team serverTeam, int teamAScore, int teamBScore) {
    return serverTeam == Team.a ? teamAScore : teamBScore;
  }

  static int getReceiverScore(Team serverTeam, int teamAScore, int teamBScore) {
    return serverTeam == Team.a ? teamBScore : teamAScore;
  }

  static CourtSide getServerSide(int serverScore) {
    return serverScore % 2 == 0 ? CourtSide.right : CourtSide.left;
  }

  static bool shouldPlayBeyond(Team servingTeam, int teamAScore, int teamBScore, int winningScore, bool winByTwo) {
    if (!winByTwo) return false;
    
    int serverTeamScore = servingTeam == Team.a ? teamAScore : teamBScore;
    int receiverTeamScore = servingTeam == Team.a ? teamBScore : teamAScore;
    
    return serverTeamScore >= winningScore - 1 && 
           receiverTeamScore >= winningScore - 1 &&
           (serverTeamScore - receiverTeamScore).abs() < 2;
  }

  static bool isGameOver(Team servingTeam, int teamAScore, int teamBScore, int winningScore, bool winByTwo) {
    int serverTeamScore = servingTeam == Team.a ? teamAScore : teamBScore;
    int receiverTeamScore = servingTeam == Team.a ? teamBScore : teamAScore;
    
    if (serverTeamScore >= winningScore) {
      if (!winByTwo) return true;
      return serverTeamScore - receiverTeamScore >= defaultWinByTwo;
    }
    
    return false;
  }

  static Team? getWinningTeam(Team servingTeam, int teamAScore, int teamBScore, int winningScore, bool winByTwo) {
    if (teamAScore >= winningScore || teamBScore >= winningScore) {
      if (!winByTwo) {
        return teamAScore > teamBScore ? Team.a : Team.b;
      }
      
      int margin = teamAScore - teamBScore;
      if (margin >= defaultWinByTwo) return Team.a;
      if (-margin >= defaultWinByTwo) return Team.b;
    }
    return null;
  }

  static ServerNumber getInitialServerNumber() {
    return ServerNumber.two;
  }

  static ServerNumber getNextServerNumber(ServerNumber current, Team servingTeam, int teamAScore, int teamBScore) {
    if (current == ServerNumber.one) {
      return ServerNumber.two;
    }
    return ServerNumber.one;
  }

  static bool shouldSwitchServers(ServerNumber current, bool pointWon) {
    if (!pointWon) return true;
    return current == ServerNumber.one;
  }

  static Team getNextServingTeam(ServerNumber currentServerNumber, bool pointWon) {
    return pointWon ? Team.a : Team.b;
  }
}