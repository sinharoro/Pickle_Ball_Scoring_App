import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_state_provider.dart';
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
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1565C0),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
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
  bool _isGameStarted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isGameStarted
          ? AppBar(
              title: const Text('Pickleball Scorekeeper'),
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _isGameStarted = false),
              ),
            )
          : AppBar(
              title: const Text('Pickleball Scorekeeper'),
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
              centerTitle: true,
            ),
      body: _isGameStarted
          ? const GameScoreScreen()
          : Consumer<GameStateProvider>(
              builder: (context, gameState, child) {
                return GameSetupScreen(
                  config: gameState.config,
                  onConfigChanged: (config) => gameState.setConfig(config),
                  onStartGame: () => setState(() => _isGameStarted = true),
                );
              },
            ),
    );
  }
}