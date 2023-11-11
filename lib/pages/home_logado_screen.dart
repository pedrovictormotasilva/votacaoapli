import 'package:flutter/material.dart';
import 'package:votacao/pages/cadastro_cadidato_screen.dart';
import 'package:votacao/pages/dashboard_screen.dart';
import 'package:votacao/pages/page_one.dart';
import 'package:votacao/pages/login_screen.dart';

class PaginaPrincipal extends StatelessWidget {
  final String accessToken;

  PaginaPrincipal({required this.accessToken});

  void clearToken(BuildContext context) {
    //FAZER FUNCAO PRA APAGAR O TOKEN
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Página Principal'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Menu'),
            ),
            ListTile(
              title: Text('Logout'),
              onTap: () {
                clearToken(context);
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CadastroCandidato(accessToken: accessToken),
                  ),
                );
              },
              child: Text('Cadastro de Candidatos'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PageOne(accessToken: accessToken),
                  ),
                );
              },
              child: Text('Lista de Candidatos'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DashboardScreen(accessToken: accessToken),
                  ),
                );
              },
              child: Text('Painel Administrativo'),
            ),
          ],
        ),
      ),
    );
  }
}
