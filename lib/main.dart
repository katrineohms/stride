import 'package:flutter/material.dart';
import 'package:stride/service/client_data_service.dart';
import 'package:flutter/services.dart';
import 'package:stride/view/home_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ClientDataService().init();
  // Enable immersive sticky system UI across the entire app
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stride',
      builder: (context, child) => SafeArea(
        left: false,
        top: false,
        right: false,
        bottom: true,
        minimum: const EdgeInsets.only(bottom: 50),
        child: child ?? const SizedBox.shrink(),
      ),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 107, 151, 92)),
            primaryColor: const Color.fromARGB(255, 107, 151, 92),
        cardColor: Colors.white,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color.fromARGB(255, 240, 240, 240),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
          ),
        ),
        drawerTheme: DrawerThemeData(
          backgroundColor: Colors.white,
        ),
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
