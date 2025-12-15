import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'page_add.dart';
import 'page_collections.dart';
import 'page_home.dart';
import 'page_profile.dart';
import 'page_wardrobe.dart';

int currentBottomTab = 1;   // Set home page to default

final List<Widget> bottomNavBarPages = [
  PageCollections(),
  PageHome(),
  PageWardrobe(),
];

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FlutterNativeSplash.remove();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // ----- App Theme -----
      
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
      home: Lunova()
      
    );
  }
}

// ----- Main app widget-----

class Lunova extends StatefulWidget {
  const Lunova({super.key});

  @override
  State<Lunova> createState() => _LunovaState();
}

class _LunovaState extends State<Lunova> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // ----- Navigation bar -----

        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.all(8.0), 
            child: Image.asset(
              'assets/media/logo.png',
              fit: BoxFit.contain,
            ),
          ),
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

      // ----- App body -----

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

        // Floating "+" button in bottom right corner
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PageAdd()),
            );
          },
          child: const Icon(Icons.add),
        ),
      );
  }
}
