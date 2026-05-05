import 'package:flutter/material.dart';
import 'package:projectuts_libilcab2/hasil.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projectuts_libilcab2/class/question.dart';
import 'package:percent_indicator/percent_indicator.dart';

String active_user = "";

// ================= USER =================
Future<String> checkUser() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("user_id") ?? '';
}

Future<void> saveScore(String user, int correct, int score) async {
  final prefs = await SharedPreferences.getInstance();

  List<String> data = prefs.getStringList("scores") ?? [];
  List<List<String>> scores = data.map((e) => e.split("|")).toList();

  scores.add([user, correct.toString(), score.toString()]);
  scores.sort((a, b) => int.parse(b[2]).compareTo(int.parse(a[2])));

  if (scores.length > 3) {
    scores = scores.sublist(0, 3);
  }

  List<String> saveData = scores.map((e) => "${e[0]}|${e[1]}|${e[2]}").toList();
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
  int _waktuGame = 30;
  final int _setWaktuGame = 30;
  int _jumlahJawabanBenar = 0;
  int _waktuHapal = 3;
  final int _setWaktuHapal = 3;

  int _indexSoal = 0;
  int _score = 0;
  bool _isGameOver = false;

  bool _isMemorizing = true;
  int _memoryIndex = 0;

  List<String> _listGambar = [];
  List<Question> _soal = [];
  double _imageOpacity = 0.0;
  double _soalOpacity = 1.0;
  int? _tappedIndex;

  // ================= FIX JUMLAH SOAL =================
  int get _totalSoal => 5;

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
    Question(
      kategory: "kucing",
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
    _soal.clear();
    _listGambar.clear();

    // ================= RANDOM SEMUA SOAL =================
    List<Question> filtered = List.from(bankSoal);
    filtered.shuffle();
    filtered = filtered.take(_totalSoal).toList();

    for (var q in filtered) {
      List<String> imgs = List.from(q.pilihan);
      imgs.shuffle();
      String correct = imgs[0];
      List<String> options = List.from(imgs)..shuffle();
      _soal.add(
        Question(kategory: q.kategory, pilihan: options, jawaban: correct),
      );
      _listGambar.add(correct);
    }

    startMemorizing();
  }

  // ================= MEMORY =================
  void startMemorizing() async {
    for (int i = 0; i < _listGambar.length; i++) {
      setState(() {
        _memoryIndex = i;
        _waktuHapal = _setWaktuHapal;
        _imageOpacity = 0.0; // fade out dulu sebelum gambar baru muncul
      });

      await Future.delayed(const Duration(milliseconds: 300));

      setState(() {
        _imageOpacity = 1.0; // fade in gambar
      });

      for (int t = _setWaktuHapal; t >= 0; t--) {
        setState(() {
          _waktuHapal = t;
        });
        await Future.delayed(const Duration(seconds: 1));
      }

      setState(() {
        _imageOpacity = 0.0; // fade out sebelum ganti soal berikutnya
      });
      await Future.delayed(const Duration(milliseconds: 500));
    }

    setState(() {
      _isMemorizing = false;
    });

    startTimer();
  }

  // ================= TIMER =================
  void startTimer() {
    _timer?.cancel();
    _waktuGame = _setWaktuGame;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _waktuGame--;

        if (_waktuGame == 0) {
          nextSoal();
        }
      });
    });
  }

  // ================= ANSWER =================
  void answer(String selected) {
    _timer?.cancel();

    if (selected == _soal[_indexSoal].jawaban) {
      _score += _waktuGame;
      _jumlahJawabanBenar++;
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      nextSoal();
    });
  }

  // ================= NEXT =================
  void nextSoal() async {
    _timer?.cancel();

    setState(() {
      _soalOpacity = 0.0; // fade out
      _tappedIndex = null;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    if (_indexSoal < _soal.length - 1) {
      setState(() {
        _indexSoal++;
        _soalOpacity = 1.0; // fade in
      });
      startTimer();
    } else {
      endGame();
    }
  }

  // ================= END =================
  void endGame() async {
    _timer?.cancel();
    await saveScore(
      active_user.isEmpty ? "Guest" : active_user,
      _jumlahJawabanBenar,
      _score,
    );

    setState(() {
      _isGameOver = true;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => Hasil(
          score: _score,
          correct: _jumlahJawabanBenar,
          total: _totalSoal,
        ),
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Memory Game"),
      ),
      backgroundColor: const Color.fromARGB(255, 217, 241, 219),

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
                      "Soal ${_memoryIndex + 1} / $_totalSoal",
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
                    AnimatedOpacity(
                      opacity: _imageOpacity,
                      duration: const Duration(milliseconds: 500),
                      child: Image.asset(
                        _listGambar[_memoryIndex],
                        height: 200,
                      ),
                    ),

                    Text(
                      "Waktu Menghapal:",
                      style: const TextStyle(fontSize: 20),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: CircularPercentIndicator(
                        radius: 120.0,
                        lineWidth: 20.0,
                        percent: 1 - (_waktuHapal / _setWaktuHapal),
                        center: Text("$_waktuHapal"),
                        progressColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              )
            : AnimatedOpacity(
                opacity: _soalOpacity,
                duration: const Duration(milliseconds: 500),
                child: Column(
                  children: [
                    Text(
                      "Soal ${_indexSoal + 1} / $_totalSoal",
                      style: const TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                    LinearProgressIndicator(
                      value: (_indexSoal + 1) / _totalSoal,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Time Left: $_waktuGame",
                      style: const TextStyle(fontSize: 20),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: LinearProgressIndicator(
                        value: _waktuGame / _setWaktuGame,
                        minHeight: 10,
                        backgroundColor: Colors.brown[300],
                        color: Colors.red,
                      ),
                    ),
                    Text(
                      "Score Saat Ini : $_score",
                      style: const TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Kategori: ${_soal[_indexSoal].kategory}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: GridView.builder(
                        itemCount: _soal[_indexSoal].pilihan.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                        itemBuilder: (context, index) {
                          String img = _soal[_indexSoal].pilihan[index];
                          bool isTapped = _tappedIndex == index;
                          bool isCorrect = img == _soal[_indexSoal].jawaban;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _tappedIndex = index;
                              });
                              answer(img);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.fastOutSlowIn,
                              decoration: BoxDecoration(
                                color: isTapped
                                    ? (isCorrect
                                          ? Colors.green.shade100
                                          : Colors.red.shade100)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(
                                  isTapped ? 20 : 8,
                                ),
                                border: Border.all(
                                  color: isTapped
                                      ? (isCorrect ? Colors.green : Colors.red)
                                      : Colors.grey.shade300,
                                  width: isTapped ? 3 : 1,
                                ),
                              ),
                              padding: const EdgeInsets.all(5),
                              child: Center(
                                child: Image.asset(img, fit: BoxFit.contain),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
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
