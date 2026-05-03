import '../models/game_models.dart';

class ScoringEngine {
  static int getServerScore(Team serverTeam, int teamAScore, int teamBScore) {
    return serverTeam == Team.a ? teamAScore : teamBScore;
  }

  static int getReceiverScore(Team serverTeam, int teamAScore, int teamBScore) {
    return serverTeam == Team.a ? teamBScore : teamAScore;
  }

  static CourtSide getServerSide(int serverScore) {
    return serverScore % 2 == 0 ? CourtSide.right : CourtSide.left;
  }

  static String getSideText(CourtSide side) {
    return side == CourtSide.right ? 'RIGHT' : 'LEFT';
  }
}