import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:votacao/pages/login_screen.dart';
import 'dart:convert';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameEditingController = TextEditingController();
  final emailEditingController = TextEditingController();
  final passwordEditingController = TextEditingController();
  final cpfEditingController = TextEditingController();

  void showSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Cadastro bem-sucedido!"),
      duration: Duration(seconds: 2),
    ));
  }

  void showErrorSnackbar(String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Erro no cadastro: $errorMessage"),
      duration: Duration(seconds: 4),
    ));
  }

  Future<void> sendRegistrationData() async {
    if (_formKey.currentState!.validate()) {
      final url = Uri.parse(
          'https://api-sistema-de-votacao.vercel.app/cadastro'); // Altere o URL para o seu servidor local

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': nameEditingController.text,
          'email': emailEditingController.text,
          'senha': passwordEditingController.text,
          'cpf': cpfEditingController.text,
        }),
      );

      if (response.statusCode == 200) {
        showSuccessSnackbar();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ),
        );
      } else {
        showErrorSnackbar(
            "Erro ao enviar os dados para a API. Status Code: ${response.statusCode}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: const Color.fromARGB(255, 35, 77, 26),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(36.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 200,
                    child: Image.asset(
                      "assets/arce.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 45),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          controller: nameEditingController,
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                            labelText: 'Nome Completo',
                            prefixIcon: Icon(Icons.account_circle),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Campo obrigatório';
                            } else if (value.length < 3) {
                              return 'Nome deve conter no mínimo 3 dígitos';
                            }

                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: cpfEditingController,
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                            labelText: 'CPF',
                            prefixIcon: Icon(Icons.account_circle),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Campo obrigatório';
                            } else if (value.length != 11) {
                              return 'CPF deve conter 11 dígitos';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: emailEditingController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.mail),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Campo obrigatório';
                            } else if (!value.contains('@')) {
                              return 'Email inválido';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: passwordEditingController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            prefixIcon: Icon(Icons.vpn_key),
                          ),
                          validator: (value) {
                            if (value == null || value.length < 6) {
                              return 'Senha deve conter pelo menos 6 caracteres';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        Material(
                          elevation: 5,
                          borderRadius: BorderRadius.circular(30),
                          color: Color(0xFF118E51),
                          child: MaterialButton(
                            padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                            minWidth: MediaQuery.of(context).size.width,
                            onPressed: () {
                              sendRegistrationData();
                            },
                            child: Text(
                              "Cadastre-se",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}