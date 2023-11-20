import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  XFile? _pickedImage;
  bool fotoCarregada = false;
  String? imageUrl;

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
    final ImagePicker imagePicker = ImagePicker();
    final XFile? pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      print('Imagem escolhida: ${pickedImage.path}');
      setState(() {
        _pickedImage = pickedImage;
        fotoCarregada = true;
      });
    } else {
      print('Nenhuma imagem escolhida');
    }
  }

  Future<void> _uploadImage(String imagePath) async {
    try {
      final Dio dio = Dio();
      final FormData formData = FormData.fromMap({
        'images': await MultipartFile.fromFile(imagePath, filename: 'image.jpg'),
      });

      final Response response = await dio.post(
        'http://10.0.0.10:3000/Candidatos', 
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer ${widget.accessToken}'},
        ),
      );

      if (response.statusCode == 200) {
        final imageUrl = response.data['url'];
        print('URL da imagem recebido: $imageUrl');
        setState(() {
          this.imageUrl = imageUrl;
          fotoCarregada = true;
        });
        showSuccessSnackbar();
      } else {
        print('Erro no upload da imagem. Response: ${response.data}');
      }
    } catch (e) {
      print('Erro no upload da imagem: $e');
    }
  }

  Future<void> cadastrarCandidato() async {
    print('Valor de _pickedImage: $_pickedImage');
    print('Valor de fotoCarregada: $fotoCarregada');

    if (_pickedImage == null || fotoCarregada == false) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Por favor, carregue uma imagem antes de cadastrar."),
        duration: Duration(seconds: 2),
      ));
      return;
    }

    try {
      final Dio dio = Dio();
      final FormData formData = FormData.fromMap({
        'name': nomeController.text,
        'apelido': apelidoController.text,
        'Partido': partidoController.text,
        'cep': cepController.text,
        'cidade': municipioSelecionado,
        'estado': estadoSelecionado,
        'images': await MultipartFile.fromFile(_pickedImage!.path, filename: 'image.jpg'),
      });

      final Response response = await dio.post(
        'http://10.0.0.10:3000/Candidatos', // Substitua pela URL correta da sua API
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer ${widget.accessToken}'},
        ),
      );

      if (response.statusCode == 200) {
        print('Candidato cadastrado com sucesso!');
      } else {
        print('Erro ao cadastrar candidato. Response: ${response.data}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Erro ao cadastrar candidato. Verifique os dados."),
          duration: Duration(seconds: 2),
        ));
      }
    } catch (e) {
      print('Erro ao cadastrar candidato: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Erro ao cadastrar candidato. Verifique sua conexão."),
        duration: Duration(seconds: 2),
      ));
    }
  }

  void showSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Imagem carregada com sucesso!"),
      duration: Duration(seconds: 2),
    ));
  }

  Icon _buildCheckIcon() {
    return Icon(
      Icons.check,
      color: Colors.green,
      size: 20,
    );
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
                  if (fotoCarregada) _buildCheckIcon(),
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
