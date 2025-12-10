import 'package:flutter/material.dart';
import 'page_add.dart';
import 'page_collections.dart';
import 'page_home.dart';
import 'page_profile.dart';
import 'page_wardrobe.dart';

int currentBottomTab = 1;

final List<Widget> bottomNavBarPages = [
  PageCollections(),
  PageHome(),
  PageWardrobe(),
];

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Lunova()
    );
  }
}

class Lunova extends StatefulWidget {
  const Lunova({super.key});

  @override
  State<Lunova> createState() => _LunovaState();
}

class _LunovaState extends State<Lunova> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch:  Colors.indigo,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            titleTextStyle: TextStyle(
              fontFamily: 'Syncopate',
              fontSize: 20,
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            shape: CircleBorder()
          ),
          fontFamily: 'Michroma',
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 4,
            margin: EdgeInsets.all(8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            shadowColor: Colors.indigo,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          leading: const Icon(Icons.nights_stay_outlined),
          title: const Text('Lunova'),
          actions: [
            IconButton(
              icon: const Icon(Icons.account_circle_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PageProfile()),
                );
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: bottomNavBarPages[currentBottomTab],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentBottomTab,
          type: BottomNavigationBarType.fixed,
          onTap: (int index) {
            setState(() {
              currentBottomTab = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.collections_bookmark),
              label: 'Collections',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.checkroom),
              label: 'Wardrobe',
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PageAdd()),
                );
              },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
