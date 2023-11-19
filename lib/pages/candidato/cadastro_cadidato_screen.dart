import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

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
  final TextEditingController partidoController = TextEditingController();
  String estadoSelecionado = "";
  String municipioSelecionado = "";
  PickedFile? _pickedImage;

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

  Future<void> _pickImage() async {
  final imagePicker = ImagePicker();
  final XFile? pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);

  if (pickedImage != null) {
    setState(() {
      _pickedImage = PickedFile(pickedImage.path);
    });
  }
}



  Future<void> _uploadImage(String imagePath) async {
    try {
      final Uri uploadUri = Uri.parse('http://localhost:3000/upload'); 
      var request = http.MultipartRequest('POST', uploadUri);
      request.headers['Authorization'] = 'Bearer ${widget.accessToken}';
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));

      final response = await request.send();

      if (response.statusCode == 200) {
        final imageUrl = await response.stream.bytesToString();
        print('Imagem enviada com sucesso. URL: $imageUrl');
      } else {
        print('Erro no upload da imagem. Response: ${await response.stream.bytesToString()}');
      }
    } catch (e) {
      print('Erro no upload da imagem: $e');
    }
  }

  Future<void> cadastrarCandidato() async {
    final nome = nomeController.text;
    final apelido = apelidoController.text;
    final cep = cepController.text;
    final partido = partidoController.text;

    await buscarEndereco(cep);

    var request = http.Request(
      'POST',
      Uri.parse('http://localhost:3000/Candidatos'),
    );
    request.headers['Content-Type'] = 'application/json';
    request.headers['Authorization'] = 'Bearer ${widget.accessToken}';
    request.body = json.encode({
      'name': nome,
      'apelido': apelido,
      'Partido': partido,
      'cidade': municipioSelecionado,
      'estado': estadoSelecionado,
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

    if (_pickedImage != null) {
      await _uploadImage(_pickedImage!.path);
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
            Text(
              "Nome:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
            ),
            TextField(
              controller: nomeController,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              "Apelido:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
            ),
            TextField(
              controller: apelidoController,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              "CEP:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: cepController,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    buscarEndereco(cepController.text);
                  },
                  child: Text("Buscar Endereço"),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              "Partido:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
            ),
            TextField(
              controller: partidoController,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              "Estado: $estadoSelecionado",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
            ),
            Text(
              "Município: $municipioSelecionado",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_upload),
                  SizedBox(width: 8),
                  Text("Carregar Imagem"),
                ],
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                cadastrarCandidato();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
              ),
              child: Text("Cadastrar Candidato"),
            ),
          ],
        ),
      ),
    );
  }
}
