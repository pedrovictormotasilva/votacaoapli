import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:votacao/pages/home_screen.dart';

import 'package:votacao/pages/registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailEditingController = TextEditingController();
  final passwordEditingController = TextEditingController();
 

  void showSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Login bem-sucedido!"),
      duration: Duration(seconds: 2),
      
    ));
  }

  String errorMessage = '';

  Future<void> login() async {
  final email = emailEditingController.text;
  final password = passwordEditingController.text;

  if (email.isEmpty || password.isEmpty) {
    setState(() {
      errorMessage = "Por favor, preencha todos os campos.";
    });
    return;
  }

  final url = Uri.parse('http://10.0.0.10:3000/Login');

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
    final token = response.body.trim();
    final decodedToken = decodeToken(token);

    if (decodedToken != null) {
      // Obtendo o nome do pesquisador do token
      final nomePesquisador = decodedToken['name'];

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PaginaPrincipal(
            accessToken: token,
            emailUsuario: email,
          ),
        ),
      );
      showSuccessSnackbar();
    } else {
      setState(() {
        errorMessage = "Token inválido. Por favor, tente novamente.";
      });
    }
  } else if (response.statusCode == 401) {
    setState(() {
      errorMessage = "Email ou senha incorretos";
    });
  } else {
    setState(() {
      errorMessage =
          "Ocorreu um erro inesperado. Por favor, tente novamente mais tarde.";
    });
  }
}



  Map<String, dynamic>? decodeToken(String token) {
    try {
      final decoded = JwtDecoder.decode(token);
      print(decoded);
      return decoded;
    } catch (e) {
      print("");
      return null;
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
                  SizedBox(height: 10),
                  if (errorMessage.isNotEmpty)
                    Text(
                      errorMessage,
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  SizedBox(height: 25),
                  buildMaterialButton(
                    onPressed: login,
                    label: "Logar",
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => RegistrationScreen(),
                        ),
                      );
                    },
                    child: Text("Não tem uma conta? Cadastre-se"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(prefixIcon),
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
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
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
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
