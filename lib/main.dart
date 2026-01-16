import 'package:flutter/material.dart';
import 'package:stride/view/home_view.dart'; // import your HomePage

void main() {
  runApp(const StrideApp());
}

class StrideApp extends StatelessWidget {
  const StrideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stride',
      // Custom theme for the app to match branding ideas
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            // Customized colored AppBar
            seedColor: const Color.fromARGB(255, 97, 164, 97)),
        useMaterial3: true,

        appBarTheme: const AppBarTheme(
          // Customized colored AppBar
          backgroundColor: Color.fromARGB(255, 97, 164, 97),
          // Color of text and icons
          foregroundColor: Colors.white,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}
