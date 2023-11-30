import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DashboardScreen extends StatefulWidget {
  final String accessToken;

  DashboardScreen({required this.accessToken, Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String selectedType = 'Todos';
  TextEditingController searchController = TextEditingController();
  bool isLoading = true; 
  List<Candidate> candidates = [];
  List<Pesquisador> researchers = [];

  @override
  void initState() {
    super.initState();
    fetchCandidates();
    fetchResearchers();
  }

  Future<void> fetchCandidates() async {
    try {
      final response = await http.get(
        Uri.parse('https://api-sistema-de-votacao.vercel.app/Candidatos'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<Candidate> fetchedCandidates =
            data.map((e) => Candidate.fromJson(e)).toList();
        setState(() {
          candidates = fetchedCandidates;
        });
      } else {
        print('Erro ao buscar candidatos. Código: ${response.statusCode}');
      }
    } catch (error) {
      print('Erro ao buscar candidatos. Detalhes: $error');
    }
  }

  Future<void> fetchResearchers() async {
    try {
      final response = await http.get(
        Uri.parse('https://api-sistema-de-votacao.vercel.app/Pesquisadores'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<Pesquisador> fetchedResearchers =
            data.map((e) => Pesquisador.fromJson(e)).toList();
        setState(() {
          researchers = fetchedResearchers;
        });
      } else {
        print('Erro ao buscar pesquisadores. Código: ${response.statusCode}');
      }
    } catch (error) {
      print('Erro ao buscar pesquisadores. Detalhes: $error');
    }
  }

  Future<void> updateCandidate(
      int candidateId, Candidate updatedCandidate) async {
    try {
      final response = await http.put(
        Uri.parse(
            'https://api-sistema-de-votacao.vercel.app/Candidatos/$candidateId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updatedCandidate.toJson()),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Candidato atualizado com sucesso'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        fetchCandidates();
      } else {
        print('Erro ao atualizar candidato. Código: ${response.statusCode}');
      }
    } catch (error) {
      print('Erro durante a requisição. Detalhes: $error');
    }
  }

  Future<void> deleteCandidate(int candidateId) async {
    try {
      final response = await http.delete(
        Uri.parse(
            'https://api-sistema-de-votacao.vercel.app/Candidatos/$candidateId'),
      );

      if (response.statusCode == 200) {
        fetchCandidates();
      }
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Candidato deletado com sucesso'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        print('Erro ao deletar candidato. Código: ${response.statusCode}');
      }
    } catch (error) {
      print('Erro durante a requisição. Detalhes: $error');
    }
  }

  Future<void> updateResearcher(
      int pesquisadorId, Pesquisador updatedResearcher) async {
    try {
      final response = await http.put(
        Uri.parse(
            'https://api-sistema-de-votacao.vercel.app/Pesquisador/$pesquisadorId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updatedResearcher.toJson()),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pesquisador atualizado com sucesso'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        fetchResearchers();
      } else {
        print('Erro ao atualizar pesquisador. Código: ${response.statusCode}');
      }
    } catch (error) {
      print('Erro durante a requisição. Detalhes: $error');
    }
  }

  Future<void> deleteResearcher(int pesquisadorId) async {
    try {
      final response = await http.delete(
        Uri.parse(
            'https://api-sistema-de-votacao.vercel.app/Pesquisador/$pesquisadorId'),
      );

      if (response.statusCode == 200) {
        fetchResearchers();
      }
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pesquisador deletado com sucesso'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        print('Erro ao deletar pesquisador. Código: ${response.statusCode}');
      }
    } catch (error) {
      print('Erro durante a requisição. Detalhes: $error');
    }
  }

  List<Widget> buildList() {
    List<Widget> items = [];

    if (selectedType == 'Candidatos' || selectedType == 'Todos') {
      items.addAll(candidates
          .where((candidate) => candidate.nome
              .toLowerCase()
              .contains(searchController.text.toLowerCase()))
          .map((candidate) => CandidateListItem(
                candidate: candidate,
                onEdit: () {
                  _editCandidate(candidate);
                },
                onDelete: () {
                  deleteCandidate(candidate.candidatoId);
                },
              )));
    }

    if (selectedType == 'Pesquisadores' || selectedType == 'Todos') {
      items.addAll(researchers
          .where((researcher) => researcher.nome
              .toLowerCase()
              .contains(searchController.text.toLowerCase()))
          .map((researcher) => ResearcherListItem(
                researcher: researcher,
                onEdit: () {
                  _editResearcher(researcher);
                },
                onDelete: () {
                  deleteResearcher(researcher.pesquisadorId);
                },
              )));
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              DropdownButton<String>(
                value: selectedType,
                onChanged: (value) {
                  setState(() {
                    selectedType = value!;
                  });
                },
                items: ['Todos', 'Candidatos', 'Pesquisadores']
                    .map<DropdownMenuItem<String>>(
                      (String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ),
                    )
                    .toList(),
              ),
              Expanded(
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: 'Pesquisar',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
            ],
          ),
          Text(
            selectedType == 'Candidatos'
                ? 'Candidatos'
                : (selectedType == 'Pesquisadores' ? 'Pesquisadores' : 'Todos'),
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          Expanded(
            child: ListView(
              children: buildList(),
            ),
          ),
        ],
      ),
    );
  }

  void _editCandidate(Candidate candidate) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditCandidateDialog(
          candidate: candidate,
          onUpdate: (updatedCandidate) async {
            await updateCandidate(candidate.candidatoId, updatedCandidate);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _editResearcher(Pesquisador researcher) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditResearcherDialog(
          researcher: researcher,
          onUpdate: (updatedResearcher) async {
            await updateResearcher(researcher.pesquisadorId, updatedResearcher);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}

class ResearcherListItem extends StatelessWidget {
  final Pesquisador researcher;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ResearcherListItem({
    required this.researcher,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(researcher.nome),
      subtitle: Text(researcher.email),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: onEdit,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class EditResearcherDialog extends StatelessWidget {
  final Pesquisador researcher;
  final Function(Pesquisador) onUpdate;

  const EditResearcherDialog({
    required this.researcher,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    TextEditingController nomeController =
        TextEditingController(text: researcher.nome);
    TextEditingController emailController =
        TextEditingController(text: researcher.email);
    TextEditingController estadoController =
        TextEditingController(text: researcher.estado);
    TextEditingController cidadeController =
        TextEditingController(text: researcher.cidade);
    TextEditingController senhaController = TextEditingController();

    return AlertDialog(
      title: Text('Editar Pesquisador'),
      content: Column(
        children: [
          TextField(
            controller: nomeController,
            decoration: InputDecoration(labelText: 'Nome'),
          ),
          TextField(
            controller: emailController,
            decoration: InputDecoration(labelText: 'Email'),
          ),
          TextField(
            controller: estadoController,
            decoration: InputDecoration(labelText: 'Estado'),
          ),
          TextField(
            controller: cidadeController,
            decoration: InputDecoration(labelText: 'Cidade'),
          ),
          TextField(
            controller: senhaController,
            obscureText: true,
            decoration: InputDecoration(labelText: 'Nova Senha'),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            Pesquisador updatedResearcher = Pesquisador(
              pesquisadorId: researcher.pesquisadorId,
              nome: nomeController.text,
              email: emailController.text,
              estado: estadoController.text,
              cidade: cidadeController.text,
              cpf: researcher.cpf,
              senha: senhaController.text, // Usar a nova senha se fornecida
            );

            onUpdate(updatedResearcher);
          },
          child: Text('Salvar'),
        ),
      ],
    );
  }
}

class Pesquisador {
  final int pesquisadorId;
  final String nome;
  final String email;
  final String estado;
  final String cidade;
  final String cpf;
  final String senha;

  Pesquisador(
      {required this.pesquisadorId,
      required this.nome,
      required this.email,
      required this.estado,
      required this.cidade,
      required this.cpf,
      required this.senha});

  factory Pesquisador.fromJson(Map<String, dynamic> json) {
    return Pesquisador(
      pesquisadorId: json['id_Pesquisador'] ?? 0,
      nome: json['name'] ?? '',
      email: json['email'] ?? '',
      estado: json['estado'] ?? '',
      cidade: json['cidade'] ?? '',
      cpf: json['cpf'] ?? '',
      senha: json['senha'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_Pesquisador': pesquisadorId,
      'name': nome,
      'email': email,
      'estado': estado,
      'cidade': cidade,
      'cpf': cpf,
      'senha': senha
    };
  }
}

class Candidate {
  final int candidatoId;
  final String nome;
  final String apelido;
  final String estado;
  final String cidade;
  final String partido;

  Candidate({
    required this.candidatoId,
    required this.nome,
    required this.apelido,
    required this.estado,
    required this.cidade,
    required this.partido,
  });

  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(
      candidatoId: json['id_candidato'] ?? 0,
      partido: json['Partido'] ?? '',
      nome: json['name'] ?? '',
      apelido: json['apelido'] ?? '',
      estado: json['estado'] ?? '',
      cidade: json['cidade'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_candidato': candidatoId,
      'Partido': partido,
      'name': nome,
      'apelido': apelido,
      'estado': estado,
      'cidade': cidade,
    };
  }
}

class CandidateListItem extends StatelessWidget {
  final Candidate candidate;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CandidateListItem({
    required this.candidate,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(candidate.nome),
      subtitle: Text(candidate.apelido),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: onEdit,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class EditCandidateDialog extends StatelessWidget {
  final Candidate candidate;
  final Function(Candidate) onUpdate;

  const EditCandidateDialog({
    required this.candidate,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    TextEditingController nomeController =
        TextEditingController(text: candidate.nome);
    TextEditingController apelidoController =
        TextEditingController(text: candidate.apelido);
    TextEditingController estadoController =
        TextEditingController(text: candidate.estado);
    TextEditingController cidadeController =
        TextEditingController(text: candidate.cidade);
    TextEditingController partidoController =
        TextEditingController(text: candidate.partido);

    return AlertDialog(
      title: Text('Editar Candidato'),
      content: Column(
        children: [
          TextField(
            controller: nomeController,
            decoration: InputDecoration(labelText: 'Nome'),
          ),
          TextField(
            controller: apelidoController,
            decoration: InputDecoration(labelText: 'Apelido'),
          ),
          TextField(
            controller: partidoController,
            decoration: InputDecoration(labelText: 'Partido'),
          ),
          TextField(
            controller: estadoController,
            decoration: InputDecoration(labelText: 'Estado'),
          ),
          TextField(
            controller: cidadeController,
            decoration: InputDecoration(labelText: 'Cidade'),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            Candidate updatedCandidate = Candidate(
              candidatoId: candidate.candidatoId,
              nome: nomeController.text,
              apelido: apelidoController.text,
              estado: estadoController.text,
              cidade: cidadeController.text,
              partido: candidate.partido,
            );

            onUpdate(updatedCandidate);
          },
          child: Text('Salvar'),
        ),
      ],
    );
  }
}
