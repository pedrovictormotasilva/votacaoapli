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
    fetchCandidates(null, null); // Adicionei valores padrão nulos
    fetchBrazilianMunicipios();
  }

  void showErrorSnackbar(String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Erro: $errorMessage"),
      duration: Duration(seconds: 4),
    ));
  }

  Future<void> fetchCandidates([String? estado, String? municipio]) async {
  try {
    final response = await http.get(
      Uri.parse('http://10.0.0.10:3000/Candidatos'),
      headers: {
        'Authorization': 'Bearer ${widget.accessToken}',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      setState(() {
        candidates = data
            .map((e) => Candidate.fromJson(e))
            .where((candidate) =>
                (municipio == null ||
                    candidate.municipio.toLowerCase() ==
                        municipio.toLowerCase()))
            .toList();
        fetchCandidatesVotes();
      });
    } else {
      throw Exception('Erro ao obter a lista de candidatos');
    }
  } catch (error) {
    print('Erro ao buscar candidatos: $error');
    showErrorSnackbar('Erro ao buscar candidatos.');
  }
}

  Future<void> fetchCandidatesVotes() async {
    try {
      final responseVotes = await http.get(
        Uri.parse('http://10.0.0.10:3000/Resultado'),
        headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
        },
      );

      if (responseVotes.statusCode == 200) {
        final List<dynamic> data = json.decode(responseVotes.body);

        for (var candidate in candidates) {
          final result = data.firstWhere(
            (result) => result['id_candidato'] == candidate.candidatoId,
            orElse: () => {},
          );

          if (result.isNotEmpty) {
            candidate.votos = result['Votos'] ?? 0;
          }
        }

        calculateTotalVotes();
      } else {
        throw Exception('Erro ao obter os resultados dos votos');
      }
    } catch (error) {
      print('Erro ao buscar votos dos candidatos: $error');
      showErrorSnackbar('Erro ao buscar votos dos candidatos.');
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
    try {
      final responseVotes = await http.get(
        Uri.parse('http://10.0.0.10:3000/Resultado'),
        headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
        },
      );

      if (responseVotes.statusCode == 200) {
        final List<dynamic> data = json.decode(responseVotes.body);

        final result = data.firstWhere(
          (result) => result['id_candidato'] == candidate.candidatoId,
          orElse: () => {},
        );

        if (result.isNotEmpty) {
          final int candidateVotes = result['Votos'] ?? 0;

          showCandidateDetails(
            context,
            candidate,
            candidateVotes,
            totalVotes,
          );
        } else {
          showErrorSnackbar(
              'Erro ao buscar votos do candidato: Resultado vazio ou sem votos.');
        }
      } else {
        throw Exception('Erro ao obter os resultados dos votos');
      }
    } catch (error) {
      print('Erro ao buscar votos do candidato: $error');
      showErrorSnackbar('Erro ao buscar votos do candidato.');
    }
  }

  void showCandidateDetails(
    BuildContext context, Candidate candidate, int candidateVotes, int totalVotes) {
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
              Text('Porcentagem: ${calculatePercentage(candidateVotes).toStringAsFixed(2)}%'),
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

      fetchCandidates(selectedState!, selectedMunicipio!);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                fetchCandidates(selectedState!, selectedMunicipio!);
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
                  fetchCandidates(selectedState!, selectedMunicipio!);
                },
              ),
            SizedBox(height: 16),
            Text('Total de Votos: $totalVotes'),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: candidates.length,
                itemBuilder: (context, index) {
                  final candidate = candidates[index];
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
      total += candidate.votos;
    }

    setState(() {
      totalVotes = total;
    });
  }

  double calculatePercentage(int votes) {
    if (totalVotes == 0) {
      return 0;
    }

    return (votes / totalVotes) * 100;
  }
}

class Candidate {
  final int candidatoId;
  final String nome;
  final String apelido;
  final String partido;
  int votos;
  final String estado;
  final String municipio;

  Candidate({
    required this.candidatoId,
    required this.nome,
    required this.apelido,
    required this.partido,
    this.votos = 0,
    required this.estado,
    required this.municipio,
  });

  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(
      candidatoId: json['id_candidato'],
      nome: json['name'] ?? '',
      apelido: json['apelido'] ?? '',
      partido: json['Partido'] ?? '',
      estado: json['estado'] ?? '',
      municipio: json['cidade'] ?? '',
    );
  }
}
