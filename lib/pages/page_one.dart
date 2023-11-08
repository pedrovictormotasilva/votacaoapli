import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MaterialApp(
    home: PageOne(),
  ));
}

class PageOne extends StatefulWidget {
  const PageOne({Key? key}) : super(key: key);

  @override
  _PageOneState createState() => _PageOneState();
}

class _PageOneState extends State<PageOne> {
  List<Candidate> candidates = [];
  String? selectedState;
  String? selectedMunicipio;
  String? cep;
  String? estado;
  String? municipio;
  Candidate? selectedCandidate;

  Map<String, List<String>> brazilianMunicipios = {};

  @override
  void initState() {
    super.initState();
    fetchCandidates();
    fetchBrazilianStatesAndMunicipios();
  }

  Future<void> fetchCandidates() async {
    final response = await http
        .get(Uri.parse('https://api-sistema-de-votacao.vercel.app/Candidatos'));

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
        Uri.parse('https://servicodados.ibge.gov.br/api/v1/localidades/estados'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      for (var stateData in data) {
        final state = stateData['sigla'];
        final stateResponse = await http.get(Uri.parse(
            'https://servicodados.ibge.gov.br/api/v1/localidades/estados/$state/municipios'));
        if (stateResponse.statusCode == 200) {
          final List<dynamic> municipiosData = json.decode(stateResponse.body);
          final municipios = municipiosData.map((m) => m['nome']).cast<String>().toList();
          brazilianMunicipios[state] = municipios;
        }
      }
    }
  }

  Future<void> fetchAddressDetails(String? cep) async {
  final response = await http.get(Uri.parse('https://viacep.com.br/ws/$cep/json/'));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    setState(() {
      estado = data['uf'];
      municipio = data['localidade'];
      selectedState = estado; 
      selectedMunicipio = municipio; 
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
      body: Column(
        children: [
          // Campo para inserir o CEP
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
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
          ),

          // Exibir estado e município
          Text("Estado: ${estado ?? 'Nenhum estado selecionado'}"),
          Text("Município: ${municipio ?? 'Nenhum município selecionado'}"),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton<String>(
                value: selectedState,
                hint: Text("Selecione o Estado"),
                items: [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text("Todos os Estados"),
                  ),
                  ...brazilianMunicipios.keys.map((state) {
                    return DropdownMenuItem<String>(
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
              if (selectedState != null && brazilianMunicipios.containsKey(selectedState))
                DropdownButton<String>(
                  value: selectedMunicipio,
                  hint: Text("Selecione o Município"),
                  items: [
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text("Todos os Municípios"),
                    ),
                    ...brazilianMunicipios[selectedState]!.map((municipio) {
                      return DropdownMenuItem<String>(
                        value: municipio,
                        child: Text(municipio),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedMunicipio = value;
                    });
                  },
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
                  margin: EdgeInsets.all(16),
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
  final String estado;
  final String municipio;
  final String apelido;

  Candidate({
    required this.nome,
    required this.estado,
    required this.municipio,
    required this.apelido,
  });

  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(
      nome: json['name'],
      estado: json['estado']['Estado'],
      municipio: json['Municipio']['Municipio'],
      apelido: json['apelido'],
    );
  }
}
