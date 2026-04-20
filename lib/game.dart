import 'package:flutter/material.dart';
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
  const Game({super.key});

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

  // ================= BANK SOAL =================
  List<Question> bankSoal = [
    Question(
      kategory: "mobil",
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
      pilihan: [
        "assets/images/sepatu1.png",
        "assets/images/sepatu2.png",
        "assets/images/sepatu3.png",
        "assets/images/sepatu4.png",
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

  // ================= SETUP =================
  void setupGame() {
    _questions.clear();
    _memoryImages.clear();

    List<Question> shuffled = List.from(bankSoal);
    shuffled.shuffle();

    for (var q in shuffled) {
      List<String> imgs = List.from(q.pilihan);
      imgs.shuffle();

      // random jawaban
      String correct = imgs[Random().nextInt(imgs.length)];

      // ambil 4 pilihan
      List<String> options = List.from(imgs)..shuffle();
      options = options.take(4).toList();

      _questions.add(
        Question(
          kategory: q.kategory,
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
                        const Text(
                          "Ingat gambar ini",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Image.asset(
                          _memoryImages[_memoryIndex],
                          height: 200,
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
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
                          itemCount:
                              _questions[_questionIndex].pilihan.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemBuilder: (context, index) {
                            String img =
                                _questions[_questionIndex].pilihan[index];

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