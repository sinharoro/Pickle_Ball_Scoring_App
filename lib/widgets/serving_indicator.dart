import 'package:flutter/material.dart';
import '../models/game_models.dart';

class ServingIndicator extends StatelessWidget {
  final Team team;
  final ServerNumber? serverNumber;
  final bool isDoubles;
  final CourtSide serverSide;

  const ServingIndicator({
    super.key,
    required this.team,
    required this.serverNumber,
    required this.isDoubles,
    required this.serverSide,
  });

  @override
  Widget build(BuildContext context) {
    final teamName = team == Team.a ? 'Team A' : 'Team B';
    final teamColor = team == Team.a 
        ? const Color(0xFF1976D2) 
        : const Color(0xFFD32F2F);
    final sideText = serverSide == CourtSide.right ? 'RIGHT' : 'LEFT';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: teamColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: teamColor, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sports_tennis, color: teamColor, size: 24),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Serving: $teamName',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: teamColor,
                ),
              ),
              Row(
                children: [
                  Text(
                    'Position: $sideText',
                    style: TextStyle(
                      fontSize: 14,
                      color: teamColor,
                    ),
                  ),
                  if (isDoubles && serverNumber != null) ...[
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: teamColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        serverNumber == ServerNumber.one ? 'Server 1' : 'Server 2',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}