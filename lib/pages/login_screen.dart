import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:votacao/pages/page_one.dart';
import 'package:votacao/pages/registration_screen.dart'; // Importe a RegistrationScreen

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailEditingController = TextEditingController();
  final passwordEditingController = TextEditingController();

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

    final url = Uri.parse('https://api-sistema-de-votacao.vercel.app/login');

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
      final token = response.body;
      final decodedToken = decodeToken(token);
      print(token);

      if (decodedToken != null) {
        // Token válido, redirecione o usuário para a próxima tela
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => PageOne(AcessToken: token),
          ),
        );
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
      return decoded;
    } catch (e) {
      print("Erro ao decodificar o token: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final emailField = TextFormField(
      autofocus: false,
      controller: emailEditingController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.mail),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Email",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    final passwordField = TextFormField(
      autofocus: false,
      controller: passwordEditingController,
      obscureText: true,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.vpn_key),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Senha",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    final loginButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: Color(0xFF118E51),
      child: MaterialButton(
        padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        minWidth: MediaQuery.of(context).size.width,
        onPressed: login,
        child: Text(
          "Logar",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    final registerButton = ElevatedButton(
      onPressed: () {
        Navigator.of(context).pushNamed('/registration');
      },
      child: Text("Não tem uma conta? Cadastre-se"),
    );

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
                  emailField,
                  SizedBox(height: 25),
                  passwordField,
                  SizedBox(height: 10),
                  if (errorMessage.isNotEmpty)
                    Text(
                      errorMessage,
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  SizedBox(height: 25),
                  loginButton,
                  SizedBox(height: 10),
                  registerButton, // Botão de registro
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
