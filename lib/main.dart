import 'package:flutter/material.dart';
import 'package:stride/view/home_view.dart'; // import your HomePage

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stride',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 107, 151, 92)),
            primaryColor: const Color.fromARGB(255, 107, 151, 92) ,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color.fromARGB(255, 235, 235, 235), 
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 107, 151, 92),
          foregroundColor: Colors.white,
          centerTitle: true,  
          titleTextStyle: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      home: const HomePage(), //home_view.dart
    );
  }
}
  