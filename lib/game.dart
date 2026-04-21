import 'package:flutter/material.dart';
import 'package:projectuts_libilcab2/level_selection.dart';
import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'highscore.dart';
import 'package:projectuts_libilcab2/class/question.dart';

String active_user = "";

// ================= USER =================
Future<String> checkUser() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("user_id") ?? '';
}

Future<int> topPoint() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt("top_point") ?? 0;
}



  

// ================= GAME =================
class Game extends StatefulWidget {
  final String level; // tambahan parameter level

  const Game({super.key, required this.level});

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  Timer? _timer;
  int _timeLeft = 30;
  final int _initTime = 30;

  int _questionIndex = 0;
  int _score = 0;
  bool _isGameOver = false;

  bool _isMemorizing = true;
  int _memoryIndex = 0;

  List<String> _memoryImages = [];
  List<Question> _questions = [];

  // ================= JUMLAH SOAL BERDASARKAN LEVEL =================
  int get _totalQuestions {
    switch (widget.level) {
      case "medium":
        return 10;
      case "hard":
        return 15;
      default: // easy
        return 5;
    }
  }

  List<Question> bankSoal = [
    // ===== EASY =====
    Question(
      kategory: "mobil",
      level: "easy",
      pilihan: [
        "assets/images/mobil1.png",
        "assets/images/mobil2.png",
        "assets/images/mobil3.png",
        "assets/images/mobil4.png",
      ],
      jawaban: "",
    ),
    Question(
      kategory: "apel",
      level: "easy",
      pilihan: [
        "assets/images/apel1.png",
        "assets/images/apel2.png",
        "assets/images/apel3.png",
        "assets/images/apel4.png",
      ],
      jawaban: "",
    ),
    Question(
      kategory: "pensil",
      level: "easy",
      pilihan: [
        "assets/images/pensil1.png",
        "assets/images/pensil2.png",
        "assets/images/pensil3.png",
        "assets/images/pensil4.png",
      ],
      jawaban: "",
    ),
    Question(
      kategory: "bola",
      level: "easy",
      pilihan: [
        "assets/images/bola1.png",
        "assets/images/bola2.png",
        "assets/images/bola3.png",
        "assets/images/bola4.png",
      ],
      jawaban: "",
    ),
    Question(
      kategory: "sepatu",
      level: "easy",
      pilihan: [
        "assets/images/sepatu1.png",
        "assets/images/sepatu2.png",
        "assets/images/sepatu3.png",
        "assets/images/sepatu4.png",
      ],
      jawaban: "",
    ),

    // ===== MEDIUM =====
    Question(
      kategory: "kucing",
      level: "medium",
      pilihan: [
        "assets/images/kucing1.png",
        "assets/images/kucing2.png",
        "assets/images/kucing3.png",
        "assets/images/kucing4.png",
      ],
      jawaban: "",
    ),
    Question(
      kategory: "rumah",
      level: "medium",
      pilihan: [
        "assets/images/rumah1.png",
        "assets/images/rumah2.png",
        "assets/images/rumah3.png",
        "assets/images/rumah4.png",
      ],
      jawaban: "",
    ),
    Question(
      kategory: "bunga",
      level: "medium",
      pilihan: [
        "assets/images/bunga1.png",
        "assets/images/bunga2.png",
        "assets/images/bunga3.png",
        "assets/images/bunga4.png",
      ],
      jawaban: "",
    ),
    Question(
      kategory: "pohon",
      level: "medium",
      pilihan: [
        "assets/images/pohon1.png",
        "assets/images/pohon2.png",
        "assets/images/pohon3.png",
        "assets/images/pohon4.png",
      ],
      jawaban: "",
    ),
    Question(
      kategory: "buku",
      level: "medium",
      pilihan: [
        "assets/images/buku1.png",
        "assets/images/buku2.png",
        "assets/images/buku3.png",
        "assets/images/buku4.png",
      ],
      jawaban: "",
    ),

    // ===== HARD =====
    Question(
      kategory: "meja",
      level: "hard",
      pilihan: [
        "assets/images/meja1.png",
        "assets/images/meja2.png",
        "assets/images/meja3.png",
        "assets/images/meja4.png",
      ],
      jawaban: "",
    ),
    Question(
      kategory: "kursi",
      level: "hard",
      pilihan: [
        "assets/images/kursi1.png",
        "assets/images/kursi2.png",
        "assets/images/kursi3.png",
        "assets/images/kursi4.png",
      ],
      jawaban: "",
    ),
    Question(
      kategory: "tas",
      level: "hard",
      pilihan: [
        "assets/images/tas1.png",
        "assets/images/tas2.png",
        "assets/images/tas3.png",
        "assets/images/tas4.png",
      ],
      jawaban: "",
    ),
    Question(
      kategory: "jam",
      level: "hard",
      pilihan: [
        "assets/images/jam1.png",
        "assets/images/jam2.png",
        "assets/images/jam3.png",
        "assets/images/jam4.png",
      ],
      jawaban: "",
    ),
    Question(
      kategory: "kunci",
      level: "hard",
      pilihan: [
        "assets/images/kunci1.png",
        "assets/images/kunci2.png",
        "assets/images/kunci3.png",
        "assets/images/kunci4.png",
      ],
      jawaban: "",
    ),
  ];

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

 void setupGame() {
  _questions.clear();
  _memoryImages.clear();

  // ↓ GANTI BAGIAN INI ↓
  List<String> allowedLevels = widget.level == "easy"
      ? ["easy"]
      : widget.level == "medium"
          ? ["easy", "medium"]
          : ["easy", "medium", "hard"];

  List<Question> filtered = bankSoal
      .where((q) => allowedLevels.contains(q.level))
      .toList();
  // ↑ SAMPAI SINI ↑

  // Sisanya tetap sama
  filtered.shuffle();
  filtered = filtered.take(_totalQuestions).toList();

  for (var q in filtered) {
    List<String> imgs = List.from(q.pilihan);
    imgs.shuffle();

    String correct = imgs[Random().nextInt(imgs.length)];

    List<String> options = List.from(imgs)..shuffle();
    options = options.take(4).toList();

    _questions.add(
      Question(
        kategory: q.kategory,
        level: q.level,
        pilihan: options,
        jawaban: correct,
      ),
    );

    _memoryImages.add(correct);
  }

  startMemorizing();
}

  // ================= MEMORY =================
  void startMemorizing() async {
    for (int i = 0; i < _memoryImages.length; i++) {
      setState(() {
        _memoryIndex = i;
      });
      await Future.delayed(const Duration(seconds: 2));
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
    _timer?.cancel();

    if (selected == _questions[_questionIndex].jawaban) {
      _score += _timeLeft;
    }

    nextQuestion();
  }

  // ================= NEXT =================
  void nextQuestion() {
    _timer?.cancel();

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
    _timer?.cancel();

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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Level: ${widget.level.toUpperCase()}"),
            Text("Your Score: $_score"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LevelSelection()),
                (route) => false,
              );
            },
            child: const Text("MAIN LAGI"),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => HighScore()),
              );
            },
            child: const Text("SEE HIGHSCORE"),
          ),
        ],
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Memory Game - ${widget.level.toUpperCase()}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: _isGameOver
            ? Center(
                child: Text(
                  "Game Over\nScore: $_score",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24),
                ),
              )
            : _isMemorizing
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Soal ${_memoryIndex + 1} / $_totalQuestions",
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Ingat gambar ini",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Image.asset(_memoryImages[_memoryIndex], height: 200),
                  ],
                ),
              )
            : Column(
                children: [
                  // Progress soal
                  Text(
                    "Soal ${_questionIndex + 1} / $_totalQuestions",
                    style: const TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                  LinearProgressIndicator(
                    value: (_questionIndex + 1) / _totalQuestions,
                  ),
                  const SizedBox(height: 8),

                  Text(
                    "Time Left: $_timeLeft",
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 10),

                  Text(
                    "Kategori: ${_questions[_questionIndex].kategory}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: GridView.builder(
                      itemCount: _questions[_questionIndex].pilihan.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                      itemBuilder: (context, index) {
                        String img = _questions[_questionIndex].pilihan[index];

                        return GestureDetector(
                          onTap: () => answer(img),
                          child: Card(
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Image.asset(img),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
