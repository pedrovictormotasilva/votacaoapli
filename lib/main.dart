import 'package:flutter/material.dart';
import 'package:votacao/pages/login_screen.dart';
import 'package:votacao/pages/welcome_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 35, 77, 26)),
        useMaterial3: true,
      ),
      home: LoginScreen(), 
    );
  }
}
