import 'package:flutter/material.dart';
import '../models/pokemon.dart';


class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;
  final bool isFavorito;
  final VoidCallback? onFavoritar;

  const PokemonCard({
    super.key,
    required this.pokemon,
    this.isFavorito = false,
    this.onFavoritar,
  });

  //visual
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(pokemon.nome),
        trailing: IconButton(
          icon: Icon(
            isFavorito ? Icons.favorite : Icons.favorite_border,
            color: isFavorito ? Colors.red : null,
          ),
          onPressed: onFavoritar,
        ),
      ),
    );
  }
}
