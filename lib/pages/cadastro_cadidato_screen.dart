import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MaterialApp(
    home: CadastroCandidato(),
  ));
}

class CadastroCandidato extends StatefulWidget {
  const CadastroCandidato({Key? key}) : super(key: key);

  @override
  _CadastroCandidatoState createState() => _CadastroCandidatoState();
}

class _CadastroCandidatoState extends State<CadastroCandidato> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController apelidoController = TextEditingController();
  final TextEditingController cepController = TextEditingController();
  String? estadoSelecionado;
  String? municipioSelecionado;

  Future<void> buscarEndereco(String cep) async {
    final response =
        await http.get(Uri.parse('https://viacep.com.br/ws/$cep/json/'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        estadoSelecionado = data['uf'];
        municipioSelecionado = data['localidade'];
      });
    }
  }

  Future<void> cadastrarCandidato() async {
    final nome = nomeController.text;
    final apelido = apelidoController.text;
    final cep = cepController.text;
    final partido = "Partido"; 

    var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://api-sistema-de-votacao.vercel.app/Candidatos')); 

   

    request.fields['name'] = nome;
    request.fields['apelido'] = apelido;
    request.fields['estado_id'] = estadoSelecionado ?? '';
    request.fields['municipio_id'] = municipioSelecionado ?? '';
    request.fields['Partido'] = partido;

    

    var response = await request.send();
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Candidato cadastrado com sucesso.'),
        duration: Duration(seconds: 2),
      ));
      print('Candidato cadastrado com sucesso');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erro no cadastro do candidato.'),
        duration: Duration(seconds: 2),
      ));
      print('Erro no cadastro do candidato');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastro de Candidato"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nome:"),
            TextField(
              controller: nomeController,
            ),
            Text("Apelido:"),
            TextField(
              controller: apelidoController,
            ),
            Text("CEP:"),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: cepController,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    buscarEndereco(cepController.text);
                  },
                  child: Text("Buscar Endereço"),
                ),
              ],
            ),
            Text("Estado: ${estadoSelecionado ?? 'Nenhum estado selecionado'}"),
            Text(
                "Município: ${municipioSelecionado ?? 'Nenhum município selecionado'}"),
           
            ElevatedButton(
              onPressed: () {
               
              },
              child: Text("Carregar Imagem"),
            ),
            
            ElevatedButton(
              onPressed: () {
                cadastrarCandidato();
              },
              child: Text("Cadastrar Candidato"),
            ),
          ],
        ),
      ),
    );
  }
}
