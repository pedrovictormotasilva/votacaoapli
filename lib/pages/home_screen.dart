import 'package:flutter/material.dart';
import 'package:votacao/pages/candidato/cadastro_cadidato_screen.dart';
import 'package:votacao/pages/adm/dashboard_screen.dart';
import 'package:votacao/pages/candidato/listaDeCandidatos_screen.dart';
import 'package:votacao/pages/login_screen.dart';

class PaginaPrincipal extends StatelessWidget {
  final String accessToken;
  final String emailUsuario;

  PaginaPrincipal({
    required this.accessToken,
    required this.emailUsuario,
  });

  void clearToken(BuildContext context) {
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
            UserAccountsDrawerHeader(
              accountName: Text(''), // Texto vazio para accountName
              accountEmail: Text(emailUsuario),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  emailUsuario.isEmpty ? 'U' : emailUsuario[0].toUpperCase(),
                  style: TextStyle(fontSize: 40.0),
                ),
              ),
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
                    builder: (context) =>
                        PageOne(accessToken: accessToken),
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
