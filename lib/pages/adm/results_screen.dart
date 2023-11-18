import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResultadoVotosScreen extends StatefulWidget {
  final String accessToken;

  ResultadoVotosScreen({required this.accessToken, Key? key}) : super(key: key);

  @override
  _ResultadoVotosScreenState createState() => _ResultadoVotosScreenState();
}

class _ResultadoVotosScreenState extends State<ResultadoVotosScreen> {
  List<Candidate> candidates = [];
  String? selectedState;
  String? selectedMunicipio;
  String? cep;

  Map<String, List<String>> brazilianMunicipios = {};
  int totalVotes = 0;

  @override
  void initState() {
    super.initState();
    fetchCandidates();
    fetchBrazilianMunicipios();
  }

  Future<void> fetchCandidates() async {
    final response = await http.get(
      Uri.parse('http://localhost:3000/Candidatos'),
      headers: {
        'Authorization': 'Bearer ${widget.accessToken}',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        candidates = data.map((e) => Candidate.fromJson(e)).toList();
        calculateTotalVotes(); 
      });
    }
  }

  Future<void> fetchBrazilianMunicipios() async {
    final response = await http.get(
      Uri.parse('https://servicodados.ibge.gov.br/api/v1/localidades/estados/'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      for (var estado in data) {
        final siglaEstado = estado['sigla'];
        final municipios = await fetchMunicipiosByEstado(siglaEstado);
        brazilianMunicipios[siglaEstado] = municipios;
      }
    }
  }

  Future<List<String>> fetchMunicipiosByEstado(String estado) async {
    final response = await http.get(
      Uri.parse(
          'https://servicodados.ibge.gov.br/api/v1/localidades/estados/$estado/municipios'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((municipio) => municipio['nome'] as String).toList();
    }

    return [];
  }

  Future<void> fetchCandidateVotes(Candidate candidate) async {
  final responseVotes = await http.get(
    Uri.parse('http://localhost:3000/Resultado'),
    headers: {
      'Authorization': 'Bearer ${widget.accessToken}',
    },
  );

  if (responseVotes.statusCode == 200) {
    final List<dynamic> dataVotes = json.decode(responseVotes.body);

    final int candidateVotes = dataVotes
        .firstWhere((result) => result['id_candidato'] == candidate.candidatoId)['totalVotos'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalhes do Candidato'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Nome: ${candidate.nome}'),
              Text('Apelido: ${candidate.apelido}'),
              Text('Total de Votos: $candidateVotes'),
              Text('Porcentagem: ${calculatePercentage(candidateVotes)}%'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Icon(Icons.close, color: Colors.red),
            ),
          ],
        );
      },
    );

    
    calculateTotalVotes();
  }
}


  Future<void> fetchCEPDetails(String cep) async {
    final response = await http.get(
      Uri.parse('https://viacep.com.br/ws/$cep/json/'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final String estado = data['uf'];
      final String municipio = data['localidade'];

      setState(() {
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
        title: Text('Resultados dos Votos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(labelText: 'CEP'),
                    onChanged: (value) {
                      setState(() {
                        cep = value;
                      });
                    },
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    fetchCEPDetails(cep!);
                  },
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 35, 77, 26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Estado'),
              value: selectedState,
              items: brazilianMunicipios.keys
                  .map((estado) => DropdownMenuItem(
                        value: estado,
                        child: Text(estado),
                      ))
                  .toList(),
              onChanged: (estado) {
                setState(() {
                  selectedState = estado;
                  selectedMunicipio = null;
                });
              },
            ),
            SizedBox(height: 16),
            if (selectedState != null)
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Município'),
                value: selectedMunicipio,
                items: (brazilianMunicipios[selectedState!] ?? [])
                    .map((municipio) => DropdownMenuItem(
                          value: municipio,
                          child: Text(municipio),
                        ))
                    .toList(),
                onChanged: (municipio) {
                  setState(() {
                    selectedMunicipio = municipio;
                  });
                },
              ),
            SizedBox(height: 16),
            Text('Total de Votos: $totalVotes'),
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
                              Text(
                                "Partido: ${candidate.partido}",
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
                      trailing: GestureDetector(
                        onTap: () {
                          fetchCandidateVotes(candidate);
                        },
                        child: Icon(Icons.info, color: Colors.black),
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

  void calculateTotalVotes() {
    int total = 0;
    for (var candidate in candidates) {
      total += candidate.totalVotes;
    }
    setState(() {
      totalVotes = total;
    });
  }

  double calculatePercentage(int votes) {
    if (totalVotes == 0) {
      return 0.0;
    }
    final percentage = (votes / totalVotes) * 100;
    return double.parse(percentage.toStringAsFixed(2));
  }
}

class Candidate {
  final int candidatoId;
  final String nome;
  final String apelido;
  final String estado;
  final String municipio;
  final String partido;
  final int totalVotes;

  Candidate({
    required this.candidatoId,
    required this.nome,
    required this.apelido,
    required this.estado,
    required this.municipio,
    required this.partido,
    required this.totalVotes,
  });

  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(
      candidatoId: json['id_candidato'] ?? 0,
      partido: json['Partido'] ?? '',
      nome: json['name'] ?? '',
      apelido: json['apelido'] ?? '',
      estado: json['estado'] ?? '',
      municipio: json['cidade'] ?? '',
      totalVotes: json['totalVotos'] ?? 0,
    );
  }
}
