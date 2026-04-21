import 'package:flutter/material.dart';
import 'package:projectuts_libilcab2/game.dart';


class LevelSelection extends StatelessWidget {
  const LevelSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Memory Game")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Pilih Level",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),

            _levelButton(
              context,
              label: "Easy",
              subtitle: "5 Soal",
              color: Colors.green,
              level: "easy",
            ),
            const SizedBox(height: 16),

            _levelButton(
              context,
              label: "Medium",
              subtitle: "10 Soal",
              color: Colors.orange,
              level: "medium",
            ),
            const SizedBox(height: 16),

            _levelButton(
              context,
              label: "Hard",
              subtitle: "15 Soal",
              color: Colors.red,
              level: "hard",
            ),
          ],
        ),
      ),
    );
  }

  Widget _levelButton(
    BuildContext context, {
    required String label,
    required String subtitle,
    required Color color,
    required String level,
  }) {
    return SizedBox(
      width: 220,
      height: 65,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => Game(level: level),
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            Text(subtitle, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}