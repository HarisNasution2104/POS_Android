import 'package:flutter/material.dart';
import 'login_page.dart';  // Pastikan file ini ada dan diimpor
import 'select_user_page.dart';   // Pastikan file ini ada dan diimpor
import 'home.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POS System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder<bool>(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasData) {
            if (snapshot.data == true) {
              return const HomePage();
            } else {
              return const LoginPage();
            }
          } else {
            return const Scaffold(
              body: Center(child: Text('Error loading login status')),
            );
          }
        },
      ),
      routes: {
        '/login': (context) => const LoginPage(),
        '/select':(context) => const SelectUserPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }

  Future<bool> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }
}
