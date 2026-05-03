import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_state_provider.dart';
import 'theme/app_theme.dart';
import 'screens/game_setup_screen.dart';
import 'screens/game_score_screen.dart';

void main() {
  runApp(const PickleballScorekeeperApp());
}

class PickleballScorekeeperApp extends StatelessWidget {
  const PickleballScorekeeperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameStateProvider(),
      child: MaterialApp(
        title: 'Pickleball Scorekeeper',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToScore() {
    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _navigateToSetup() {
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Consumer<GameStateProvider>(
            builder: (context, gameState, child) {
              return GameSetupScreen(
                config: gameState.config,
                onConfigChanged: (config) => gameState.setConfig(config),
                onStartGame: _navigateToScore,
              );
            },
          ),
          GameScoreScreen(
            onBackToSetup: _navigateToSetup,
          ),
        ],
      ),
    );
  }
}