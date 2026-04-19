import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HighScore extends StatefulWidget {
  const HighScore({super.key});

  @override
  State<HighScore> createState() => _HighScoreState();
  
}

class _HighScoreState extends State<HighScore> {
  String user = "-";
  int point = 0;

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
    loadData();
  }

  void loadData() async {
    user = await topUser();
    point = await topPoint();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('High Score'), centerTitle: true),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                blurRadius: 5,
                color: Colors.black12,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, size: 50, color: Colors.orange),
              const SizedBox(height: 10),

              const Text(
                "TOP PLAYER",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const Divider(height: 30, thickness: 1),

              Text("User: $user", style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),

              Text(
                "Point: $point",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                 Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                },
                child: const Text("Back to Home"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
