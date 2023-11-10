import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

class PageOne extends StatefulWidget {
  final String AcessToken;

  PageOne({required this.AcessToken, Key? key}) : super(key: key);

  @override
  _PageOneState createState() => _PageOneState();
}

class _PageOneState extends State<PageOne> {
  List<Candidate> candidates = [];
  String? selectedState;
  String? selectedMunicipio;
  String? cep;
  Candidate? selectedCandidate;

  Map<String, List<String>> brazilianMunicipios = {};

  @override
  void initState() {
    super.initState();
    fetchCandidates();
    fetchBrazilianStatesAndMunicipios();
  }

  Future<void> fetchCandidates() async {
    final response = await http.get(
      Uri.parse('https://api-sistema-de-votacao.vercel.app/Candidatos'),
      headers: {
        'Authorization': 'Bearer ${widget.AcessToken}',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final List<Candidate> fetchedCandidates =
          data.map((e) => Candidate.fromJson(e)).toList();
      setState(() {
        candidates = fetchedCandidates;
      });
    }
  }

  Future<void> voteCandidate(Candidate candidate) async {
    print('Votou em ${candidate.nome}');
  }

  Future<void> fetchBrazilianStatesAndMunicipios() async {
    final response = await http.get(
      Uri.parse('https://servicodados.ibge.gov.br/api/v1/localidades/estados'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      for (var stateData in data) {
        final state = stateData['sigla'];
        final stateResponse = await http.get(
          Uri.parse(
              'https://servicodados.ibge.gov.br/api/v1/localidades/estados/$state/municipios'),
        );
        if (stateResponse.statusCode == 200) {
          final List<dynamic> municipiosData =
              json.decode(stateResponse.body);
          final municipios =
              municipiosData.map((m) => m['nome']).cast<String>().toList();
          brazilianMunicipios[state] = municipios;
        }
      }
    }
  }

  Future<void> fetchAddressDetails(String? cep) async {
    final response = await http.get(
      Uri.parse('https://api-sistema-de-votacao.vercel.app/Candidatos'),
      headers: {
        'Authorization': 'Bearer ${widget.AcessToken}',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        selectedState = data['uf'];
        selectedMunicipio = data['localidade'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Candidate> filteredCandidates = candidates.where((candidate) {
      if (selectedMunicipio != null) {
        return candidate.municipio == selectedMunicipio;
      } else if (selectedState != null) {
        return candidate.estado == selectedState;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Candidatos"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo para inserir o CEP
            TextField(
              decoration: InputDecoration(labelText: "CEP"),
              onChanged: (value) {
                setState(() {
                  cep = value;
                });
              },
              onEditingComplete: () {
                fetchAddressDetails(cep);
              },
            ),
            SizedBox(height: 16),
            Text("Estado: ${selectedState ?? 'Nenhum estado selecionado'}"),
            Text(
                "Município: ${selectedMunicipio ?? 'Nenhum município selecionado'}"),
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedState,
                    hint: Text("Selecione o Estado"),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text("Todos os Estados"),
                      ),
                      ...brazilianMunicipios.keys.map((state) {
                        return DropdownMenuItem(
                          value: state,
                          child: Text(state),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedState = value;
                        selectedMunicipio = null;
                      });
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedMunicipio,
                    hint: Text("Selecione o Município"),
                    items: selectedState != null
                        ? brazilianMunicipios[selectedState]!.map((municipio) {
                            return DropdownMenuItem(
                              value: municipio,
                              child: Text(municipio),
                            );
                          }).toList()
                        : [],
                    onChanged: (value) {
                      setState(() {
                        selectedMunicipio = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: filteredCandidates.length,
                itemBuilder: (context, index) {
                  final candidate = filteredCandidates[index];
                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      title: Row(
                        children: [
                          Icon(
                            Icons.account_circle,
                            size: 48,
                            color: Color.fromARGB(255, 35, 77, 26),
                          ),
                          SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                candidate.nome,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                candidate.apelido,
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      subtitle: Text(
                        "Estado: ${candidate.estado}, Município: ${candidate.municipio}",
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.info),
                        onPressed: () {
                          setState(() {
                            selectedCandidate = candidate;
                          });
                          _showCandidateDetails(context);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCandidateDetails(BuildContext context) {
    if (selectedCandidate != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 10.0,
                    offset: Offset(0.0, 10.0),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.account_circle,
                    size: 96,
                    color: Color.fromARGB(255, 35, 77, 26),
                  ),
                  SizedBox(height: 16),
                  Text(
                    selectedCandidate!.nome,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    selectedCandidate!.apelido,
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  Text("Estado: ${selectedCandidate!.estado}"),
                  Text("Município: ${selectedCandidate!.municipio}"),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      voteCandidate(selectedCandidate!);
                      Navigator.of(context).pop();
                    },
                    child: Text("Votar"),
                  ),
                  SizedBox(height: 16),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey, size: 32),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }
}

class Candidate {
  final String nome;
  final String apelido;
  final String estado;
  final String municipio;

  Candidate({
    required this.nome,
    required this.apelido,
    required this.estado,
    required this.municipio,
  });

  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(
      nome: json['name'] ?? '',
      apelido: json['apelido'] ?? '',
      estado: json['estado'] ?? '',
      municipio: json['municipio'] ?? '',
    );
  }
}
