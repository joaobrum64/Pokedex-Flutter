class Pokemon {
  final int id;
  final String nome;
  final String urlImagem;

  Pokemon({
    required this.id,
    required this.nome,
    required this.urlImagem,
  });

  //gera pokemon a partir da api
  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final id = int.parse(json['url'].split('/')[6]);
    final nome = json['name'];
    final urlImagem =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';
    return Pokemon(id: id, nome: nome, urlImagem: urlImagem);
  }
}
