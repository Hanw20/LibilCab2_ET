import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'highscore.dart';

String active_user = "";

// ================= USER =================
Future<String> checkUser() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("user_id") ?? '';
}

Future<String> topUser() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("top_user") ?? '';
}

Future<int> topPoint() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt("top_point") ?? 0;
}

// ================= MODEL =================
class Question {
  String correctImage;
  List<String> options;

  Question({required this.correctImage, required this.options});
}

// ================= GAME =================
class Game extends StatefulWidget {
  const Game({super.key});

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  // TIMER
  late Timer _timer;
  int _timeLeft = 30;
  int _initTime = 30;

  // GAME STATE
  int _questionIndex = 0;
  int _score = 0;
  bool _isGameOver = false;

  // MEMORY MODE
  bool _isMemorizing = true;
  int _memoryIndex = 0;

  List<String> _memoryImages = [];
  List<Question> _questions = [];

  // ================= INIT =================
  @override
  void initState() {
    super.initState();

    checkUser().then((value) {
      setState(() {
        active_user = value;
      });
    });

    setupGame();
  }

  // ================= SETUP =================
  void setupGame() {
    // GANTI DENGAN ASSET KAMU
    _memoryImages = [
      "assets/pencil_blue.png",
      "assets/apple_red.png",
      "assets/car_green.png",
      "assets/ball_yellow.png",
      "assets/book_blue.png",
    ];

    _memoryImages.shuffle();

    // buat soal dari memory
    for (var img in _memoryImages) {
      _questions.add(
        Question(
          correctImage: img,
          options: generateOptions(img),
        ),
      );
    }

    startMemorizing();
  }

  // ================= GENERATE OPTIONS =================
  List<String> generateOptions(String correct) {
    // contoh sederhana (HARUS kamu sesuaikan asset)
    List<String> all = [
      "assets/pencil_blue.png",
      "assets/pencil_red.png",
      "assets/pencil_green.png",
      "assets/pencil_yellow.png",
    ];

    all.shuffle();

    if (!all.contains(correct)) {
      all[0] = correct;
    }

    all.shuffle();
    return all.take(4).toList();
  }

  // ================= MEMORY PHASE =================
  void startMemorizing() async {
    for (int i = 0; i < _memoryImages.length; i++) {
      setState(() {
        _memoryIndex = i;
      });
      await Future.delayed(const Duration(seconds: 3));
    }

    setState(() {
      _isMemorizing = false;
    });

    startTimer();
  }

  // ================= TIMER =================
  void startTimer() {
    _timeLeft = _initTime;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeLeft--;

        if (_timeLeft == 0) {
          nextQuestion();
        }
      });
    });
  }

  // ================= ANSWER =================
  void answer(String selected) {
    _timer.cancel();

    if (selected == _questions[_questionIndex].correctImage) {
      _score += _timeLeft;
    }

    nextQuestion();
  }

  // ================= NEXT =================
  void nextQuestion() {
    _timer.cancel();

    if (_questionIndex < _questions.length - 1) {
      setState(() {
        _questionIndex++;
      });
      startTimer();
    } else {
      endGame();
    }
  }

  // ================= END =================
  void endGame() async {
    _timer.cancel();

    int top = await topPoint();

    if (_score >= top) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setInt("top_point", _score);
      prefs.setString("top_user", active_user);
    }

    setState(() {
      _isGameOver = true;
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Game Finished"),
        content: Text("Your Score: $_score"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => HighScore()),
              );
            },
            child: const Text("SEE HIGHSCORE"),
          )
        ],
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Memory Game")),
      body: Center(
        child: _isGameOver
            ? Text(
                "Game Over\nScore: $_score",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24),
              )
            : _isMemorizing
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Ingat gambar ini",
                        style: TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 20),
                      Image.asset(
                        _memoryImages[_memoryIndex],
                        height: 200,
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Time Left: $_timeLeft",
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 20),

                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        children: _questions[_questionIndex]
                            .options
                            .map((img) {
                          return GestureDetector(
                            onTap: () => answer(img),
                            child: Card(
                              child: Image.asset(img),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
      ),
    );
  }

  // ================= DISPOSE =================
  @override
  void dispose() {
    try {
      _timer.cancel();
    } catch (_) {}
    super.dispose();
  }
}