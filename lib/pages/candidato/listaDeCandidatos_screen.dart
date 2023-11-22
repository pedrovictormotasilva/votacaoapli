import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PageOne extends StatefulWidget {
  final String accessToken;

  PageOne({required this.accessToken, Key? key}) : super(key: key);

  @override
  _PageOneState createState() => _PageOneState();
}

class _PageOneState extends State<PageOne> {
  List<Candidate> candidates = [];
  String? selectedState;
  String? selectedMunicipio;
  String? cep;
  Candidate? selectedCandidate;
  String? votanteNome;
  int? votanteIdade;
  String? votanteLocalidade;

  Map<String, List<String>> brazilianMunicipios = {};

  @override
  void initState() {
    super.initState();
    fetchCandidates();
    fetchBrazilianStatesAndMunicipios();
  }

  Future<void> fetchCandidates() async {
    final response = await http.get(
      Uri.parse('http://10.0.0.10:3000/Candidatos'),
      headers: {
        'Authorization': 'Bearer ${widget.accessToken}',
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
    bool success = await registerVote(candidate.candidatoId);
    showSnackbar(
        success ? 'Voto registrado com sucesso' : 'Erro ao registrar voto');
  }

  Future<bool> registerVote(int candidateId) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.0.10:3000/Votar'),
        headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'candidatoId': candidateId,
          'nome': votanteNome,
          'Idade': votanteIdade,
          'Localidade': votanteLocalidade,
        }),
      );

      if (response.statusCode == 201) {
        print('Voto registrado com sucesso');
        return true;
      } else {
        print('Erro ao registrar voto');
        return false;
      }
    } catch (error) {
      print('Erro ao registrar voto: $error');
      return false;
    }
  }

  void showSnackbar(String message, {bool success = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
        backgroundColor: success ? const Color.fromARGB(255, 59, 73, 60) : Colors.red,
      ),
    );
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
          final List<dynamic> municipiosData = json.decode(stateResponse.body);
          final municipios =
              municipiosData.map((m) => m['nome']).cast<String>().toList();
          brazilianMunicipios[state] = municipios;
        }
      }
    }
  }

  Future<void> fetchAddressDetails(String? cep) async {
    if (cep != null && cep.isNotEmpty) {
      final response = await http.get(
        Uri.parse('https://viacep.com.br/ws/$cep/json/'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        setState(() {
          selectedState = data['uf'];
          selectedMunicipio = data['localidade'];
        });
      } else {
        print('Erro ao obter detalhes do endereço');
      }
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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(labelText: "CEP"),
                    onChanged: (value) {
                      setState(() {
                        cep = value;
                      });
                    },
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    fetchAddressDetails(cep);
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
                  Text("Partido: ${selectedCandidate!.partido}"),
                  SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(labelText: 'Nome do Eleitor'),
                    onChanged: (value) {
                      votanteNome = value;
                    },
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Idade do Eleitor'),
                    onChanged: (value) {
                      votanteIdade = int.tryParse(value);
                    },
                  ),
                  TextField(
                    decoration:
                        InputDecoration(labelText: 'Localidade do Eleitor'),
                    onChanged: (value) {
                      votanteLocalidade = value;
                    },
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (votanteNome != null &&
                          votanteIdade != null &&
                          votanteLocalidade != null) {
                        voteCandidate(selectedCandidate!);
                        Navigator.of(context).pop();
                      } else {
                        showSnackbar(
                            'Preencha todas as informações do Eleitor');
                      }
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
  final int candidatoId;
  final String nome;
  final String apelido;
  final String estado;
  final String municipio;
  final String partido;

  Candidate({
    required this.candidatoId,
    required this.nome,
    required this.apelido,
    required this.estado,
    required this.municipio,
    required this.partido,
  });

  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(
      candidatoId: json['id_candidato'] ?? 0,
      partido: json['Partido'] ?? '',
      nome: json['name'] ?? '',
      apelido: json['apelido'] ?? '',
      estado: json['estado'] ?? '',
      municipio: json['cidade'] ?? '',
    );
  }
}