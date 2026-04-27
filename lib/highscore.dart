import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HighScore extends StatefulWidget {
  const HighScore({super.key});

  @override
  State<HighScore> createState() => _HighScoreState();
}

class _HighScoreState extends State<HighScore> {
  List<List<String>> scores = [];

  Future<void> loadScores() async {
    final prefs = await SharedPreferences.getInstance();

    List<String> data = prefs.getStringList("scores") ?? [];

    scores = data.map((e) => e.split("|")).toList();

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loadScores();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("High Score"), centerTitle: true),

      body: scores.isEmpty
          ? const Center(child: Text("Belum ada data"))
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(scores.length, (index) {
                return Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: index == 0
                        ? Colors.amber.shade200
                        : index == 1
                        ? Colors.grey.shade300
                        : index == 2
                        ? Colors.orange.shade200
                        : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "#${index + 1}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        scores[index][0], // USER
                        style: const TextStyle(fontSize: 18),
                      ),

                      Text(
                        scores[index][1], // SCORE
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                );
              }),
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        },
        child: const Icon(Icons.home),
      ),
    );
  }
}
