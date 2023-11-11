import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  final String accessToken; // Adicionado o parâmetro 'token'

  const DashboardScreen({Key? key, required this.accessToken}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Token recebido na Dashboard:',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              Text(
                widget.accessToken, // Acesso ao token através do widget
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
