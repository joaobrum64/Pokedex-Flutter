import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';
import '../providers/favoritosProvider.dart';
import 'detalhesScreen.dart';
import 'favoritosScreen.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Pokemon> pokemons = [];
  String? proximaUrl = "https://pokeapi.co/api/v2/pokemon?limit=20&offset=0";
  bool carregando = false;
  bool erro = false;
  String filtroNome = "";
  Timer? _debounce;

  final Color vermelhoTema = const Color(0xFFB71C1C);

  @override
  void initState() {
    super.initState();
    fetchPokemons();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  // puxa pokemon da api para a home
  Future<void> fetchPokemons() async {
    if (proximaUrl == null || carregando) return;

    setState(() {
      carregando = true;
      erro = false;
    });

    try {
      final url = Uri.parse(proximaUrl!);
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final dados = jsonDecode(response.body);
        final List<Pokemon> proximosPokemons = [];

        for (var p in dados['results']) {
          final urlSplit = (p['url'] as String).split('/');
          final id = int.parse(urlSplit[urlSplit.length - 2]);
          String sprite = '';

          final detalheResponse =
          await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$id'));
          if (detalheResponse.statusCode == 200) {
            final detalheDados = jsonDecode(detalheResponse.body);
            sprite = detalheDados['sprites']['front_default'] ?? '';
          }

          proximosPokemons.add(Pokemon(id: id, nome: p['name'], urlImagem: sprite));
        }

        setState(() {
          pokemons.addAll(proximosPokemons);
          proximaUrl = dados['next'];
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

  // puxa pokemon da api para o search
  Future<void> buscarPokemon(String nome) async {
    setState(() {
      carregando = true;
      erro = false;
    });

    try {
      final url = Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=100000&offset=0');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final dados = jsonDecode(response.body);
        final List results = dados['results'];
        final lowerNome = nome.toLowerCase();
        final startsWith = results
            .where((p) => (p['name'] as String).toLowerCase().startsWith(lowerNome))
            .toList();
        final containsButNotStart = results
            .where((p) =>
        (p['name'] as String).toLowerCase().contains(lowerNome) &&
            !(p['name'] as String).toLowerCase().startsWith(lowerNome))
            .toList();
        final filtrados = [...startsWith, ...containsButNotStart];
        final List<Pokemon> pokemonsEncontrados = [];

        for (var p in filtrados) {
          final urlSplit = (p['url'] as String).split('/');
          final id = int.parse(urlSplit[urlSplit.length - 2]);
          String sprite = '';

          final detalheResponse =
          await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$id'));
          if (detalheResponse.statusCode == 200) {
            final detalheDados = jsonDecode(detalheResponse.body);
            sprite = detalheDados['sprites']['front_default'] ?? '';
          }

          pokemonsEncontrados.add(Pokemon(id: id, nome: p['name'], urlImagem: sprite));
        }

        setState(() {
          pokemons = pokemonsEncontrados;
          proximaUrl = null; // desativar carregar mais (não tem o que carregar)
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: vermelhoTema,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.favorite,
              size: 32,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FavoritosScreen()));
            },
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: "Buscar Pokémon...",
                hintStyle: const TextStyle(color: Colors.black54),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search, color: Colors.black),
                contentPadding:
                const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                filtroNome = value;

                // debounce para busca
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(const Duration(milliseconds: 500), () {
                  if (value.isEmpty) {
                    setState(() {
                      pokemons = [];
                      proximaUrl =
                      "https://pokeapi.co/api/v2/pokemon?limit=20&offset=0";
                    });
                    fetchPokemons();
                  } else {
                    buscarPokemon(value);
                  }
                });
              },
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: pokemons.length,
                  itemBuilder: (context, index) {
                    final pokem = pokemons[index];
                    final isFavorito = favoritosProvider.isFavorito(pokem);

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => DetalhesScreen(pokemon: pokem)));
                      },
                      child: Card(
                        elevation: 4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: pokem.urlImagem.isNotEmpty
                                  ? Image.network(
                                pokem.urlImagem,
                                height: 80,
                                width: 80,
                                fit: BoxFit.contain,
                              )
                                  : const SizedBox(height: 80, width: 80),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              pokem.nome.toUpperCase(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            IconButton(
                              icon: Icon(
                                isFavorito
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isFavorito ? const Color(0xFFFF0000) : null,
                              ),
                              onPressed: () {
                                favoritosProvider.favoritar(pokem);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (!carregando && proximaUrl != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: vermelhoTema,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: fetchPokemons,
                    child: const Text(
                      "Carregar Mais",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              if (erro)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Ocorreu um erro ao carregar os pokémons.",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
          if (carregando)
            Container(
              color: Colors.white38,
              child: Center(
                child: CircularProgressIndicator(
                  color: vermelhoTema,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
