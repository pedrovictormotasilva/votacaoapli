import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:votacao/pages/pesquisador/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailEditingController = TextEditingController();
  final passwordEditingController = TextEditingController();

  bool isLoading = false;
  bool isPasswordVisible = false; 
  String errorMessage = '';

  void showSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Login bem-sucedido!"),
      duration: Duration(seconds: 2),
      backgroundColor: Colors.green,
    ));
  }

  Future<void> login() async {
    if (_formKey.currentState!.validate()) {
      final email = emailEditingController.text;
      final password = passwordEditingController.text;

      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final url = Uri.parse('https://api-sistema-de-votacao.vercel.app/Login');

      try {
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'email': email,
            'senha': password,
            
          }),
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);

          if (responseData.containsKey('role')) {
            final roleID = responseData['role'];
            final cidade = responseData['cidade'];
            final estado = responseData['estado'];
            final nome = responseData['name'] ?? '';
            

            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => PaginaPrincipal(
                  emailUsuario: email,
                  accessToken: response.body.trim(),
                  roleID: roleID,
                  cidade: cidade,
                  estado: estado,
                  nomeUsuario: nome, 

                 
                ),
              ),
            );
            showSuccessSnackbar();
          } else {
            setState(() {
              errorMessage = "roleId não encontrado na resposta da API.";
            });
          }
        } else {
          setState(() {
            errorMessage = "Falha ao fazer login. Verifique suas credenciais.";
          });
        }
      } catch (e) {
        setState(() {
          errorMessage = "Conecte-se em uma rede Wi-fi para logar.";
        });
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                        SizedBox(height: 15),
                        TextFormField(
                          controller: passwordEditingController,
                          obscureText: !isPasswordVisible, 
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            prefixIcon: Icon(Icons.vpn_key),
                            suffixIcon: IconButton(
                              icon: Icon(
                                isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  isPasswordVisible = !isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.length < 6) {
                              return 'Campo obrigatório';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        if (errorMessage.isNotEmpty)
                          Text(
                            errorMessage,
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        SizedBox(height: 15),
                        buildMaterialButton(
                          onPressed: login,
                          label: "Logar",
                        ),
                        SizedBox(height: 10),
                        if (isLoading) CircularProgressIndicator(),
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

  Widget buildMaterialButton({
    required VoidCallback onPressed,
    required String label,
  }) {
    return Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: Color(0xFF118E51),
      child: MaterialButton(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20), 
        minWidth: MediaQuery.of(context).size.width,
        onPressed: onPressed,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
