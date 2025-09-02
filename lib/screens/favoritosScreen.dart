import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favoritosProvider.dart';
import 'detalhesScreen.dart';


class FavoritosScreen extends StatelessWidget {
  const FavoritosScreen({super.key});

  final Color vermelhoTema = const Color(0xFFB71C1C);


  //visual
  @override
  Widget build(BuildContext context) {
    final favoritosProvider = Provider.of<FavoritosProvider>(context);
    final favoritos = favoritosProvider.favoritos;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: vermelhoTema,
        title: const Text(
          'Meus Favoritos',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 25,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: favoritos.isEmpty
          ? const Center(
        child: Text(
          'Nenhum Pokémon favoritado.',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: favoritos.length,
        itemBuilder: (context, index) {
          final pokemon = favoritos[index];
          final estaFavorito = favoritosProvider.isFavorito(pokemon);

          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              leading: Image.network(
                pokemon.urlImagem,
                height: 50,
                width: 50,
                fit: BoxFit.cover,
              ),
              title: Text(
                pokemon.nome.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: IconButton(
                icon: Icon(
                  estaFavorito ? Icons.favorite : Icons.favorite_border,
                  color: const Color(0xFFFF0000),
                ),
                onPressed: () {
                  favoritosProvider.favoritar(pokemon);
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetalhesScreen(pokemon: pokemon),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
