import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class DashboardScreen extends StatefulWidget {
  final String accessToken;

  DashboardScreen({required this.accessToken, Key? key}) : super(key: key);

  @override
  _PageOneState createState() => _PageOneState();
}

class _PageOneState extends State<DashboardScreen> {
  List<Candidate> candidates = [];
  List<Pesquisador> pesquisadores = [];
  Candidate? selectedCandidate;
  Pesquisador? selectedPesquisador;
  String filterType = 'Todos';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchCandidates();
    fetchPesquisadores();
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

  Future<void> fetchPesquisadores() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.0.10:3000/Pesquisadores'),
        headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<Pesquisador> fetchedPesquisadores =
            data.map((e) => Pesquisador.fromJson(e)).toList();

        setState(() {
          pesquisadores = fetchedPesquisadores;
        });
      } else {
        showSnackbar(
            "Erro ao buscar pesquisadores. Código: ${response.statusCode}",
            success: false);
      }
    } catch (error) {
      showSnackbar("Erro ao buscar pesquisadores. Detalhes: $error",
          success: false);
    }
  }

  void showSnackbar(String message, {bool success = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
        backgroundColor:
            success ? const Color.fromARGB(255, 59, 73, 60) : Colors.red,
      ),
    );
  }

  List<dynamic> getFilteredItems() {
    if (filterType == 'Candidatos') {
      return candidates.where((candidate) {
        return candidate.nome.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    } else if (filterType == 'Pesquisadores') {
      return pesquisadores.where((pesquisador) {
        return pesquisador.nome.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    } else {
    
      List<dynamic> allItems = [];
      allItems.addAll(candidates);
      allItems.addAll(pesquisadores);
      return allItems.where((item) {
        return item.nome.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }
  }

  Future<void> deleteCandidate(int candidateId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://10.0.0.10:3000/Candidatos/$candidateId'),
        headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
        },
      );

      if (response.statusCode == 200) {
        showSnackbar('Candidato deletado com sucesso');
        fetchCandidates();
      } else {
        showSnackbar('Erro ao deletar candidato. Código: ${response.statusCode}', success: false);
      }
    } catch (error) {
      showSnackbar('Erro ao deletar candidato. Detalhes: $error', success: false);
    }
  }

  Future<void> updateCandidate(int candidateId, Candidate updatedCandidate) async {
  try {
    final response = await http.put(
      Uri.parse('http://10.0.0.10:3000/Candidatos/$candidateId'),
      headers: {
        'Authorization': 'Bearer ${widget.accessToken}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        
        'name': updatedCandidate.nome,
        'apelido': updatedCandidate.apelido,
        'Partido': updatedCandidate.partido,
       
      }),
    );

    if (response.statusCode == 200) {
      showSnackbar('Candidato atualizado com sucesso');
      fetchCandidates();
    } else {
      showSnackbar('Erro ao atualizar candidato. Código: ${response.statusCode}', success: false);
    }
  } catch (error) {
    showSnackbar('Erro ao atualizar candidato. Detalhes: $error', success: false);
  }
}

  Future<void> deletePesquisador(int pesquisadorId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://10.0.0.10:3000/Pesquisadores/$pesquisadorId'),
        headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
        },
      );

      if (response.statusCode == 200) {
        showSnackbar('Pesquisador deletado com sucesso');
        fetchPesquisadores();
      } else {
        showSnackbar('Erro ao deletar pesquisador. Código: ${response.statusCode}', success: false);
      }
    } catch (error) {
      showSnackbar('Erro ao deletar pesquisador. Detalhes: $error', success: false);
    }
  }

  Future<void> updatePesquisador(int pesquisadorId, Pesquisador updatedPesquisador) async {
  try {
    final response = await http.put(
      Uri.parse('http://10.0.0.10:3000/Pesquisadores/$pesquisadorId'),
      headers: {
        'Authorization': 'Bearer ${widget.accessToken}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        
        'name': updatedPesquisador.nome,
        'email': updatedPesquisador.email,
        'cpf': updatedPesquisador.cpf,
        
      }),
    );

    if (response.statusCode == 200) {
      showSnackbar('Pesquisador atualizado com sucesso');
      fetchPesquisadores();
    } else {
      showSnackbar('Erro ao atualizar pesquisador. Código: ${response.statusCode}', success: false);
    }
  } catch (error) {
    showSnackbar('Erro ao atualizar pesquisador. Detalhes: $error', success: false);
  }
}

  @override
  Widget build(BuildContext context) {
    List<dynamic> filteredItems = getFilteredItems();

    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Candidatos e Pesquisadores"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DropdownButton<String>(
                  value: filterType,
                  items: ['Todos', 'Candidatos', 'Pesquisadores']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      filterType = value!;
                    });
                  },
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(labelText: "Pesquisar por nome"),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];

                  if (item is Candidate) {
                    return buildCandidateListItem(item);
                  } else if (item is Pesquisador) {
                    return buildPesquisadorListItem(item);
                  } else {
                    // Caso inesperado
                    return Container();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCandidateListItem(Candidate candidate) {
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
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              
              _editCandidate(candidate);
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
             
              deleteCandidate(candidate.candidatoId);
            },
          ),
        ],
      ),
      onTap: () {
        setState(() {
          selectedCandidate = candidate;
        });
        _showCandidateDetails(context);
      },
    ),
  );
}

Widget buildPesquisadorListItem(Pesquisador pesquisador) {
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
                pesquisador.nome,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "E-mail: ${pesquisador.email}",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
              Text(
                "CPF: ${pesquisador.cpf}",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
             
              _editPesquisador(pesquisador);
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              // Chame a função de exclusão aqui
              _deletePesquisador(pesquisador.pesquisadorId);
            },
          ),
        ],
      ),
      onTap: () {
        setState(() {
          selectedPesquisador = pesquisador;
        });
        _showPesquisadorDetails(context);
      },
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

void _editCandidate(Candidate candidate) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Editar Candidato"),
        content: Text("Implemente a lógica de edição para candidato aqui."),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              // Implemente a lógica de edição aqui
              // Exemplo: Navigator.push(context, MaterialPageRoute(builder: (context) => EditCandidateScreen(candidate: candidate)));
              Navigator.of(context).pop();
            },
            child: Text("Salvar"),
          ),
        ],
      );
    },
  );
}

void editCandidate(Candidate candidate) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      TextEditingController nomeController = TextEditingController(text: candidate.nome);
      TextEditingController apelidoController = TextEditingController(text: candidate.apelido);
      TextEditingController partidoController = TextEditingController(text: candidate.partido);

      return AlertDialog(
        title: Text("Editar Candidato"),
        content: Column(
          children: [
            TextField(
              controller: nomeController,
              decoration: InputDecoration(labelText: "Nome"),
            ),
            TextField(
              controller: apelidoController,
              decoration: InputDecoration(labelText: "Apelido"),
            ),
            TextField(
              controller: partidoController,
              decoration: InputDecoration(labelText: "Partido"),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Cancelar"),
          ),
          TextButton(
            onPressed: () async {
              // Implemente a lógica de edição aqui
              Candidate updatedCandidate = Candidate(
                candidatoId: candidate.candidatoId,
                nome: nomeController.text,
                apelido: apelidoController.text,
                estado: candidate.estado,
                municipio: candidate.municipio,
                partido: partidoController.text,
              );
              await updateCandidate(candidate.candidatoId, updatedCandidate);

              Navigator.of(context).pop();
            },
            child: Text("Salvar"),
          ),
        ],
      );
    },
  );
}

void _editPesquisador(Pesquisador pesquisador) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      TextEditingController nomeController = TextEditingController(text: pesquisador.nome);
      TextEditingController emailController = TextEditingController(text: pesquisador.email);
      TextEditingController cpfController = TextEditingController(text: pesquisador.cpf);

      return AlertDialog(
        title: Text("Editar Pesquisador"),
        content: Column(
          children: [
            TextField(
              controller: nomeController,
              decoration: InputDecoration(labelText: "Nome"),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "E-mail"),
            ),
            TextField(
              controller: cpfController,
              decoration: InputDecoration(labelText: "CPF"),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Cancelar"),
          ),
          TextButton(
            onPressed: () async {
              // Implemente a lógica de edição aqui
              Pesquisador updatedPesquisador = Pesquisador(
                pesquisadorId: pesquisador.pesquisadorId,
                nome: nomeController.text,
                email: emailController.text,
                cpf: cpfController.text,
              );
              await updatePesquisador(pesquisador.pesquisadorId, updatedPesquisador);

              Navigator.of(context).pop();
            },
            child: Text("Salvar"),
          ),
        ],
      );
    },
  );
}

void _deletePesquisador(int pesquisadorId) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Confirmar Exclusão"),
        content: Text("Tem certeza que deseja excluir este pesquisador?"),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              // Implemente a lógica de exclusão aqui
              // Exemplo: _showDeleteConfirmationDialog(pesquisadorId);
              Navigator.of(context).pop();
            },
            child: Text(
              "Excluir",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      );
    },
  );
}

  

  void _showPesquisadorDetails(BuildContext context) {
    if (selectedPesquisador != null) {
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
                    selectedPesquisador!.nome,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "E-mail: ${selectedPesquisador!.email}",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    "CPF: ${selectedPesquisador!.cpf}",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  Text("ID do Pesquisador: ${selectedPesquisador!.pesquisadorId}"),
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

class Pesquisador {
  final int pesquisadorId;
  final String nome;
  final String email;
  final String cpf;

  Pesquisador({
    required this.pesquisadorId,
    required this.nome,
    required this.email,
    required this.cpf,
  });

  factory Pesquisador.fromJson(Map<String, dynamic> json) {
    return Pesquisador(
      pesquisadorId: json['id_Pesquisador'] ?? 0,
      nome: json['name'] ?? '',
      email: json['email'] ?? '',
      cpf: json['cpf'] ?? '',
    );
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

