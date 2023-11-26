import 'package:flutter/material.dart';
import 'package:votacao/pages/adm/registration_screen.dart';
import 'package:votacao/pages/adm/results_screen.dart';
import 'package:votacao/pages/adm/cadastro_cadidato_screen.dart';
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

  Widget buildSquareButton(
    BuildContext context,
    String buttonText,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(8),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            primary: Color(0xFF118E51),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 30,
                color: Colors.white,
              ),
              SizedBox(height: 10),
              Text(
                buttonText,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(''),
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
              title: Text(
                'Sair da Conta',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
              onTap: () {
                clearToken(context);
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Row(
              children: [
                buildSquareButton(
                  context,
                  'Cadastro de Candidatos',
                  Icons.person_add,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CadastroCandidato(
                          accessToken: accessToken,
                        ),
                      ),
                    );
                  },
                ),
                buildSquareButton(
                  context,
                  'Lista de Candidatos',
                  Icons.list,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PageOne(
                          accessToken: accessToken,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            Row(
              children: [
                buildSquareButton(
                  context,
                  'Painel Administrativo',
                  Icons.dashboard,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DashboardScreen(
                          accessToken: accessToken,
                        ),
                      ),
                    );
                  },
                ),
                buildSquareButton(
                  context,
                  'Resultados dos Votos',
                  Icons.bar_chart,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResultadoVotosScreen(
                          accessToken: accessToken,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            Row(
              children: [
                buildSquareButton(
                  context,
                  'Cadastro de Pesquisadores',
                  Icons.person_add,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegistrationScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              "Faça sua voz ser ouvida!",
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF395B6B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
