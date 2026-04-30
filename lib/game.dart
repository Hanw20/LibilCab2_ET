import 'package:flutter/material.dart';
import 'package:projectuts_libilcab2/hasil.dart';

import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'highscore.dart';
import 'package:projectuts_libilcab2/class/question.dart';

String active_user = "";

// ================= USER =================
Future<String> checkUser() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("user_id") ?? '';
}

Future<void> saveScore(String user, int score) async {
  final prefs = await SharedPreferences.getInstance();

  List<String> data = prefs.getStringList("scores") ?? [];
  List<List<String>> scores = data.map((e) => e.split("|")).toList();

  scores.add([user, score.toString()]);
  scores.sort((a, b) => int.parse(b[1]).compareTo(int.parse(a[1])));

  if (scores.length > 3) {
    scores = scores.sublist(0, 3);
  }

  List<String> saveData = scores.map((e) => "${e[0]}|${e[1]}").toList();
  prefs.setStringList("scores", saveData);
}

// ================= GAME =================
class Game extends StatefulWidget {
  const Game({super.key});

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  Timer? _timer;
  int _timeLeft = 30;
  final int _initTime = 30;
  int _correctAnswers = 0;

  int _questionIndex = 0;
  int _score = 0;
  bool _isGameOver = false;

  bool _isMemorizing = true;
  int _memoryIndex = 0;

  List<String> _memoryImages = [];
  List<Question> _questions = [];

  // ================= FIX JUMLAH SOAL =================
  int get _totalQuestions => 5;

  List<Question> bankSoal = [
    Question(
      kategory: "mobil",
      level: "",
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
      level: "",
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
      level: "",
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
      level: "",
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
      level: "",
      pilihan: [
        "assets/images/sepatu1.png",
        "assets/images/sepatu2.png",
        "assets/images/sepatu3.png",
        "assets/images/sepatu4.png",
      ],
      jawaban: "",
    ),
    Question(
      kategory: "kucing",
      level: "",
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
      level: "",
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
      level: "",
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
      level: "",
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
      level: "",
      pilihan: [
        "assets/images/buku1.png",
        "assets/images/buku2.png",
        "assets/images/buku3.png",
        "assets/images/buku4.png",
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

    // ================= RANDOM SEMUA SOAL =================
    List<Question> filtered = List.from(bankSoal);
    filtered.shuffle();
    filtered = filtered.take(_totalQuestions).toList();

    for (var q in filtered) {
      List<String> imgs = List.from(q.pilihan);
      imgs.shuffle();

      // ✅ FIX: jawaban = gambar pertama (konsisten dengan memory)
      String correct = imgs[0];

      List<String> options = List.from(imgs)..shuffle();

      _questions.add(
        Question(
          kategory: q.kategory,
          level: "",
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
    _timer?.cancel(); // FIX
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
      _correctAnswers++; // TAMBAH INI
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      nextQuestion();
    });
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
    await saveScore(active_user.isEmpty ? "Guest" : active_user, _score);

    setState(() {
      _isGameOver = true;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => Hasil(
          score: _score,
          correct: _correctAnswers,
          total: _totalQuestions,
        ),
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Memory Game")),
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
                            childAspectRatio: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                      itemBuilder: (context, index) {
                        String img = _questions[_questionIndex].pilihan[index];

                        return GestureDetector(
                          onTap: () => answer(img),
                          child: Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Center(
                                child: Image.asset(img, fit: BoxFit.contain),
                              ),
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
