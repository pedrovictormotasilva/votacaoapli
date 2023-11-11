import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CadastroCandidato extends StatefulWidget {
  final String accessToken;

  const CadastroCandidato({Key? key, required this.accessToken})
      : super(key: key);

  @override
  _CadastroCandidatoState createState() => _CadastroCandidatoState();
}

class _CadastroCandidatoState extends State<CadastroCandidato> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController apelidoController = TextEditingController();
  final TextEditingController cepController = TextEditingController();
  String estadoSelecionado = "";
  String municipioSelecionado = "";

  Future<void> buscarEndereco(String cep) async {
    try {
      final response = await http.get(
        Uri.parse('https://viacep.com.br/ws/$cep/json/'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('erro') && data['erro'] == true) {
          setState(() {
            estadoSelecionado = "CEP não encontrado";
            municipioSelecionado = "";
          });
        } else {
          setState(() {
            estadoSelecionado = data['uf'];
            municipioSelecionado = data['localidade'];
          });
        }
      } else {
        setState(() {
          estadoSelecionado = "Erro na busca do CEP";
          municipioSelecionado = "";
        });
      }
    } catch (e) {
      setState(() {
        estadoSelecionado = "Erro na busca do CEP";
        municipioSelecionado = "";
      });
    }
  }

  Future<void> cadastrarCandidato() async {
    final nome = nomeController.text;
    final apelido = apelidoController.text;
    final cep = cepController.text;
    final partido = "Partido";

    var endereco = {
  'estado_id': estadoSelecionado ?? '',
  'municipio_id': municipioSelecionado ?? '',
};

var request = http.Request(
  'POST',
  Uri.parse('https://api-sistema-de-votacao.vercel.app/Candidatos'),
);
request.headers['Content-Type'] = 'application/json';
request.headers['Authorization'] = 'Bearer ${widget.accessToken}';
request.body = json.encode({
  'name': nome,
  'apelido': apelido,
  'Partido': partido,
  'endereco': endereco,
});


    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Candidato cadastrado com sucesso.'),
          duration: Duration(seconds: 2),
        ));
        print('Candidato cadastrado com sucesso');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Erro no cadastro do candidato. Response -> ${await response.stream.bytesToString()}'),
          duration: Duration(seconds: 2),
        ));
        print(
            'Erro no cadastro do candidato, response -> ${await response.stream.bytesToString()}');
      }
    } catch (e) {
      print('Erro na requisição: $e');
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
            Text("Estado: $estadoSelecionado"),
            Text("Município: $municipioSelecionado"),
            ElevatedButton(
              onPressed: () {
                // Implemente a lógica para carregar imagens, se necessário
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

class Candidato {
  final String nome;
  final String apelido;
  final String cep;
  final String partido;
  final String estadoId;
  final String municipioId;

  Candidato({
    required this.nome,
    required this.apelido,
    required this.cep,
    required this.partido,
    required this.estadoId,
    required this.municipioId,
  });

  Map<String, String> toJson() {
    return {
      'name': nome,
      'apelido': apelido,
      'Partido': partido,
      'estado_id': estadoId,
      'municipio_id': municipioId,
    };
  }
}
