import 'package:flutter/material.dart';
import 'package:votacao/pages/home_screen.dart';
import 'package:votacao/pages/page_one.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 35, 77, 26)),
        useMaterial3: true,
      ),
      home: const PageOne()
    );
  }
}
