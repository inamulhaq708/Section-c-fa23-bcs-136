import 'package:flutter/material.dart';
import 'widgets/animated_background.dart';
import 'utils/color_extensions.dart';
import 'dart:math';

void main() => runApp(const GuessNumberApp());

class GuessNumberApp extends StatelessWidget {
  const GuessNumberApp({super.key});
  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF1A1A2E);
    const accent = Color(0xFFD4AF37);
    return MaterialApp(
      title: 'Guess The Number',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(primary: primary, secondary: accent),
        scaffoldBackgroundColor: Colors.transparent,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late int secretNumber;
  int? playerGuess;
  int attempts = 0;
  late List<int> guessHistory;
  String feedback = '';
  bool gameWon = false;
  bool gameLost = false;

  late final AnimationController _titleController;
  late final AnimationController _feedbackController;
  late final AnimationController _guessController;
  late final AnimationController _buttonScaleController;

  final TextEditingController _guessInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeGame();

    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _guessController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _buttonScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _titleController.forward();
  }

  void _initializeGame() {
    secretNumber = Random().nextInt(100) + 1;
    playerGuess = null;
    attempts = 0;
    guessHistory = [];
    feedback = 'Guess a number between 1 and 100!';
    gameWon = false;
    gameLost = false;
  }

  void _makeGuess() {
    final guess = int.tryParse(_guessInputController.text);
    if (guess == null || guess < 1 || guess > 100) {
      setState(() {
        feedback = 'Please enter a valid number (1-100)!';
      });
      _playFeedbackAnimation();
      return;
    }

    setState(() {
      playerGuess = guess;
      guessHistory.add(guess);
      attempts++;

      if (guess == secretNumber) {
        feedback = '🎉 Correct! You found it in $attempts attempt(s)!';
        gameWon = true;
      } else if (guess < secretNumber) {
        feedback = '⬆️ Too low! Try a higher number.';
      } else {
        feedback = '⬇️ Too high! Try a lower number.';
      }

      if (attempts >= 7 && !gameWon) {
        feedback = '💔 Game Over! The number was $secretNumber.';
        gameLost = true;
      }
    });

    _guessInputController.clear();
    _playFeedbackAnimation();
    _buttonScaleController.forward().then((_) {
      _buttonScaleController.reverse();
    });
  }

  void _playFeedbackAnimation() {
    _feedbackController.forward(from: 0);
  }

  void _resetGame() {
    setState(() {
      _initializeGame();
    });
    _guessInputController.clear();
    _titleController.forward(from: 0);
  }

  @override
  void dispose() {
    _guessInputController.dispose();
    _titleController.dispose();
    _feedbackController.dispose();
    _guessController.dispose();
    _buttonScaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedGradientBackground(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title with scale animation
                ScaleTransition(
                  scale: CurvedAnimation(
                    parent: _titleController,
                    curve: Curves.elasticOut,
                  ),
                  child: ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        colors: [
                          const Color(0xFFD4AF37),
                          const Color(0xFFFFC700),
                          const Color(0xFFD4AF37),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.srcIn,
                    child: const Text(
                      'Guess The Number',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _titleController,
                    curve: const Interval(0.5, 1.0),
                  ),
                  child: Text(
                    'Think you can find it?',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFFD4AF37).withOpacityF(0.7),
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                // Attempts counter with animation
                ScaleTransition(
                  scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _titleController,
                      curve: Curves.easeOut,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFD4AF37).withOpacityF(0.1),
                          const Color(0xFFFFC700).withOpacityF(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withOpacityF(0.3),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Attempts',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: const Color(
                                  0xFFD4AF37,
                                ).withOpacityF(0.6),
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$attempts / 7',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD4AF37),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Guess history
                if (guessHistory.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16213E).withOpacityF(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withOpacityF(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Guesses:',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: const Color(
                                  0xFFD4AF37,
                                ).withOpacityF(0.6),
                              ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: guessHistory.map((g) {
                            return ScaleTransition(
                              scale: Tween<double>(begin: 0, end: 1).animate(
                                CurvedAnimation(
                                  parent: _guessController,
                                  curve: Curves.elasticOut,
                                ),
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFD4AF37,
                                  ).withOpacityF(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(
                                      0xFFD4AF37,
                                    ).withOpacityF(0.3),
                                  ),
                                ),
                                child: Text(
                                  '$g',
                                  style: const TextStyle(
                                    color: Color(0xFFD4AF37),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 32),

                // Feedback message
                FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _feedbackController,
                    curve: Curves.easeOut,
                  ),
                  child: SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(0, -0.1),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: _feedbackController,
                            curve: Curves.easeOut,
                          ),
                        ),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _getFeedbackColor().withOpacityF(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getFeedbackColor().withOpacityF(0.4),
                          width: 2,
                        ),
                      ),
                      child: Text(
                        feedback,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _getFeedbackColor(),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Input field and submit button (hidden if game ended)
                if (!gameWon && !gameLost) ...[
                  TextField(
                    controller: _guessInputController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD4AF37),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter your guess',
                      hintStyle: TextStyle(
                        color: const Color(0xFFD4AF37).withOpacityF(0.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFD4AF37),
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: const Color(0xFFD4AF37).withOpacityF(0.5),
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFD4AF37),
                          width: 2,
                        ),
                      ),
                    ),
                    onSubmitted: (_) => _makeGuess(),
                  ),
                  const SizedBox(height: 24),
                  _buildAnimatedButton(
                    label: 'Submit Guess',
                    onPressed: _makeGuess,
                  ),
                ] else
                  _buildAnimatedButton(
                    label: 'Play Again',
                    onPressed: _resetGame,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getFeedbackColor() {
    if (gameWon) return const Color(0xFF00D26A);
    if (gameLost) return const Color(0xFFFF6B6B);
    if (feedback.contains('low')) return const Color(0xFF4ECDC4);
    if (feedback.contains('high')) return const Color(0xFFFF6B6B);
    return const Color(0xFFD4AF37);
  }

  Widget _buildAnimatedButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return ScaleTransition(
      scale: Tween<double>(begin: 1, end: 1.08).animate(
        CurvedAnimation(
          parent: _buttonScaleController,
          curve: Curves.elasticOut,
        ),
      ),
      child: Stack(
        children: [
          // Animated underline
          Positioned(
            bottom: -8,
            left: 0,
            right: 0,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(
                  parent: _buttonScaleController,
                  curve: Curves.elasticOut,
                ),
              ),
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withOpacityF(0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Button
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              backgroundColor: const Color(0xFFD4AF37),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 8,
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
