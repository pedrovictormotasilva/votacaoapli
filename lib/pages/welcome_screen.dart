import 'package:flutter/material.dart';
import 'package:votacao/pages/login_screen.dart';
import 'package:votacao/pages/adm/registration_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF118E51),
        
        centerTitle: true,
        title: Image.asset(
          'assets/arce.png',
          width: 70,
          height: 70,
          color: Colors.white
        ),
        
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              width: 350,
              height: 350,
            ),
            SizedBox(height: 25),
            Text(
              "Bem-vindo à Votação Governamental",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF395B6B),
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Participe e faça sua voz ser ouvida",
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF395B6B),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF118E51),
                minimumSize: Size(200, 50),
              ),
              child: Text(
                "Logar",
                style: TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
