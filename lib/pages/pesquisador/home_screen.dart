import 'package:flutter/material.dart';
import 'package:votacao/pages/adm/cadastro_pesquisador_screen.dart';
import 'package:votacao/pages/adm/results_screen.dart';
import 'package:votacao/pages/adm/cadastro_cadidato_screen.dart';
import 'package:votacao/pages/adm/dashboard_screen.dart';
import 'package:votacao/pages/pesquisador/listaDeCandidatos_screen.dart';
import 'package:votacao/pages/pesquisador/login_screen.dart';

class PaginaPrincipal extends StatelessWidget {
  final String emailUsuario;
  final String accessToken;
  final int roleID;
  final String cidade;
  final String estado;

  PaginaPrincipal({
    required this.emailUsuario,
    required this.accessToken,
    required this.roleID,
    required this.cidade,
    required this.estado,
  });

  void clearToken(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  Widget buildSquareButton(BuildContext context, String buttonText,
      IconData icon, VoidCallback onPressed,
      {double width = double.infinity}) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(10),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            primary: Color(0xFF118E51),
            onPrimary: Colors.white,
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: EdgeInsets.all(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
              ),
              SizedBox(height: 10),
              Text(
                buttonText,
                style: TextStyle(
                  fontSize: 16,
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  if (roleID == 2)
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
                  if (roleID == 2)
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
              Row(
                children: [
                  if (roleID == 2)
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
                  if (roleID == 2)
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
                    'Lista de Candidatos',
                    Icons.list,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PageOne(
                            accessToken: accessToken,
                            cidade: cidade,
                            estado: estado,
                            roleID: roleID,
                          ),
                        ),
                      );
                    },
                    width: MediaQuery.of(context).size.width / 2,
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
      ),
    );
  }
}
