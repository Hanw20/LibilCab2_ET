import 'package:flutter/material.dart';
import 'game.dart';
import 'highscore.dart';

class Hasil extends StatelessWidget {
  final int score;
  final int correct;
  final int total;

  const Hasil({
    super.key,
    required this.score,
    required this.correct,
    required this.total,
  });

  // ================= GELAR SESUAI SOAL =================
  String getGelar() {
    switch (correct) {
      case 5:
        return "Maestro dell'Indovinello 🏆";
      case 4:
        return "Esperto dell'Indovinello 🔥";
      case 3:
        return "Abile Indovinatore 👍";
      case 2:
        return "Principiante dell'Indovinello 🙂";
      case 1:
        return "Neofita dell'Indovinello 😅";
      default:
        return "Sfortunato Indovinatore 😢";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hasil Permainan")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // SCORE
              Text(
                "Score: $score",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              // JUMLAH BENAR
              Text(
                "$correct dari $total tebakan benar",
                style: const TextStyle(fontSize: 20),
              ),

              const SizedBox(height: 20),

              // GELAR
              Text(
                getGelar(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),

              const SizedBox(height: 40),

              // BUTTON PLAY AGAIN
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const Game()),
                  );
                },
                child: const Text("Play Again"),
              ),

              const SizedBox(height: 10),

              // BUTTON HIGHSCORE
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => HighScore()),
                  );
                },
                child: const Text("High Scores"),
              ),

              const SizedBox(height: 10),

              // BUTTON MAIN MENU (sementara balik ke game lagi kalau belum ada menu)
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Main Menu"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}