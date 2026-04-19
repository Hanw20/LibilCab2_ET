import 'package:flutter/material.dart';
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
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
      routes: {     
        'highscore': (context) => HighScore(),
      },
    );
    //tes bolo
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int _currentIndex = 0;
  // final List<Widget> _screens = [Home(), Search(), History()];
  // final List<String> _title = ['Home', 'Search', 'History'];

  void doLogout() async {
    //later, we use web service here to check the user id and password
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

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // bottomNavigationBar: myBottomNav(),
      // persistentFooterButtons: <Widget>[
      //   ElevatedButton(
      //     onPressed: () {},
      //     child: const Icon(Icons.skip_previous),
      //   ),
      //   ElevatedButton(onPressed: () {}, child: const Icon(Icons.skip_next)),
      // ],
      drawer: myDrawer(),

      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Home")
      ),
      // body: _screens[_currentIndex],
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ),
    );
  }

  // BottomNavigationBar myBottomNav() {
  //   return BottomNavigationBar(
  //     currentIndex: _currentIndex,
  //     onTap: (int index) {
  //       setState(() {
  //         _currentIndex = index;
  //       });
  //     },

  //     fixedColor: Colors.teal,
  //     items: const [
  //       BottomNavigationBarItem(label: "Home", icon: Icon(Icons.home)),
  //       BottomNavigationBarItem(label: "Search", icon: Icon(Icons.search)),
  //       BottomNavigationBarItem(label: "History", icon: Icon(Icons.history)),
  //     ],
  //   );
  // }

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
