import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HighScore extends StatefulWidget {
  const HighScore({super.key});

  @override
  State<HighScore> createState() => _HighScoreState();
}

class _HighScoreState extends State<HighScore> {
  List<Map<String, dynamic>> scores = [];

  Future<void> loadScores() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> scoreList = prefs.getStringList("scores") ?? [];

    scores = scoreList
        .map((e) => jsonDecode(e) as Map<String, dynamic>)
        .toList();

    setState(() {});
  }

  Future<int> topPoint() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("top_point") ?? 0;
  }

  Future<String> topUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("top_user") ?? '-';
  }

  @override
  void initState() {
    super.initState();
    loadScores();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard'), centerTitle: true),

      body: scores.isEmpty
          ? const Center(
              child: Text("Belum ada score", style: TextStyle(fontSize: 18)),
            )
          : ListView.builder(
              itemCount: scores.length,
              itemBuilder: (context, index) {
                final s = scores[index];

                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: index == 0
                        ? Colors
                              .amber
                              .shade200 // rank 1
                        : index == 1
                        ? Colors
                              .grey
                              .shade300 // rank 2
                        : index == 2
                        ? Colors
                              .orange
                              .shade200 // rank 3
                        : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Text(
                      "#${index + 1}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    title: Text(
                      s["user"],
                      style: const TextStyle(fontSize: 16),
                    ),

                    subtitle: Text(
                      "Tanggal: ${s["date"]}",
                      style: const TextStyle(fontSize: 12),
                    ),

                    trailing: Text(
                      "${s["score"]}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
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
