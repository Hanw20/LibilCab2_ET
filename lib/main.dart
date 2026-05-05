import 'package:flutter/material.dart';
import 'package:projectuts_libilcab2/game.dart';
import 'package:projectuts_libilcab2/highscore.dart';

import 'package:projectuts_libilcab2/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

String active_user = "";

Future<String> checkUser() async {
  final prefs = await SharedPreferences.getInstance();
  String user_id = prefs.getString("user_id") ?? '';
  return user_id;
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  checkUser().then((String result) {
    if (result == '')
      runApp(MyLogin());
    else {
      active_user = result;
      runApp(MyApp());
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.greenAccent)),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
      routes: {
        'highscore': (context) => HighScore(),
        'game': (context) => Game(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  void doLogout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("user_id");
    main();
  }

  @override
  void initState() {
    super.initState();
    checkUser().then(
      (value) => setState(() {
        active_user = value;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: myDrawer(),

      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Home"),
      ),
      backgroundColor: const Color.fromARGB(255, 217, 241, 219),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Cara Bermain:\nJawab semua pertanyaan dengan benar untuk mendapatkan skor tertinggi! \n\nPoin akan ditentukan dari seberapa cepat pertanyaan dijawab. \n\nSemakin banyak jawaban benar, semakin tinggi gelar yang kamu dapatkan!\n\n Selamat bermain!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, "game");
              },
              child: Text("Play Game"),
            ),
          ],
        ),
      ),
    );
  }

  Widget myDrawer() {
    return Drawer(
      elevation: 16.0,
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(active_user),
            accountEmail: Text("$active_user@gmail.com"),
            currentAccountPicture: CircleAvatar(
              backgroundImage: NetworkImage("https://i.pravatar.cc/150"),
            ),
          ),
          ListTile(
            title: const Text("High Score"),
            leading: const Icon(Icons.timelapse),
            onTap: () {
              Navigator.pushNamed(context, "highscore");
            },
          ),
          ListTile(
            title: const Text("Log Out"),
            leading: const Icon(Icons.logout),
            onTap: () {
              doLogout();
            },
          ),
        ],
      ),
    );
  }
}
