import 'package:flutter/material.dart';
import '../models/pokemon.dart';

class FavoritosProvider extends ChangeNotifier {
  final List<Pokemon> _favoritos = [];
  List<Pokemon> get favoritos => List.unmodifiable(_favoritos);


  //adicionar pokemon aos favoritos
  void favoritar(Pokemon pokemon) {
    if (isFavorito(pokemon)) {
      _favoritos.removeWhere((p) => p.id == pokemon.id);
    } else {
      _favoritos.add(pokemon);
    }
    notifyListeners();
  }

  //checar se o pokemon está favoritado
  bool isFavorito(Pokemon pokemon) {
    return _favoritos.any((p) => p.id == pokemon.id);
  }
}
