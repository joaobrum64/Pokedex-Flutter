import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';
import '../providers/favoritosProvider.dart';


class DetalhesScreen extends StatefulWidget {
  final Pokemon pokemon;

  const DetalhesScreen({super.key, required this.pokemon});

  @override
  State<DetalhesScreen> createState() => _DetalhesScreenState();
}


class _DetalhesScreenState extends State<DetalhesScreen> {
  bool carregando = true;
  bool erro = false;
  int id = 0;
  String nome = '';
  String sprite = '';
  List<String> tipos = [];
  List<String> habilidades = [];

  final Color vermelhoTema = const Color(0xFFCC0000);

  //cores dos tipos de pokemon
  final Map<String, Color> coresTipos = {
    'normal': const Color(0xFFA8A77A),
    'fire': const Color(0xFFEE8130),
    'water': const Color(0xFF6390F0),
    'electric': const Color(0xFFF7D02C),
    'grass': const Color(0xFF7AC74C),
    'ice': const Color(0xFF96D9D6),
    'fighting': const Color(0xFFC22E28),
    'poison': const Color(0xFFA33EA1),
    'ground': const Color(0xFFE2BF65),
    'flying': const Color(0xFFA98FF3),
    'psychic': const Color(0xFFF95587),
    'bug': const Color(0xFFA6B91A),
    'rock': const Color(0xFFB6A136),
    'ghost': const Color(0xFF735797),
    'dragon': const Color(0xFF6F35FC),
    'dark': const Color(0xFF705746),
    'steel': const Color(0xFFB7B7CE),
    'fairy': const Color(0xFFD685AD),
  };

  @override
  void initState() {
    super.initState();
    fetchDetalhes();
  }

  //puxa detalhes do pokemon da api
  Future<void> fetchDetalhes() async {
    setState(() {
      carregando = true;
      erro = false;
    });

    final url = Uri.parse('https://pokeapi.co/api/v2/pokemon/${widget.pokemon.id}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final dados = jsonDecode(response.body);
        setState(() {
          id = dados['id'];
          nome = dados['name'];
          sprite = dados['sprites']['front_default'] ?? widget.pokemon.urlImagem;
          tipos = (dados['types'] as List).map((t) => t['type']['name'] as String).toList();
          habilidades =
              (dados['abilities'] as List).map((h) => h['ability']['name'] as String).toList();
          carregando = false;
        });
      } else {
        setState(() {
          erro = true;
          carregando = false;
        });
      }
    } catch (e) {
      setState(() {
        erro = true;
        carregando = false;
      });
    }
  }


  //visual
  @override
  Widget build(BuildContext context) {
    final favoritosProvider = Provider.of<FavoritosProvider>(context);
    final estaFavorito = favoritosProvider.isFavorito(widget.pokemon);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: vermelhoTema,
        iconTheme: const IconThemeData(color: Colors.white), // ← botão voltar preto
        title: Text(
          widget.pokemon.nome[0].toUpperCase() + widget.pokemon.nome.substring(1),
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 25, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: carregando
            ? const CircularProgressIndicator()
            : erro
            ? const Text("Erro ao carregar detalhes",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))
            : Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Image.network(
                sprite,
                height: 220,
                width: 220,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '#$id - ${nome[0].toUpperCase()}${nome.substring(1)}',
                    style: const TextStyle(
                        fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: Icon(
                      estaFavorito
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: const Color(0xFFFF0000),
                      size: 34,
                    ),
                    onPressed: () {
                      favoritosProvider.favoritar(widget.pokemon);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: tipos
                    .map(
                      (tipo) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: coresTipos[tipo] ?? Colors.grey,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      tipo[0].toUpperCase() + tipo.substring(1),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ),
                )
                    .toList(),
              ),
              const SizedBox(height: 20),
              const Text(
                'Habilidades',
                style: TextStyle(
                    fontSize: 25, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: habilidades.length,
                  itemBuilder: (context, index) {
                    final h = habilidades[index];
                    return ListTile(
                      title: Text(
                        h[0].toUpperCase() + h.substring(1),
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
