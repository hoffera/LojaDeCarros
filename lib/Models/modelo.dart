class Modelo {
  int id;
  // ignore: non_constant_identifier_names
  int id_marca;
  String nome;

  Modelo({
    required this.id,
    // ignore: non_constant_identifier_names
    required this.id_marca,
    required this.nome,
  });

  factory Modelo.fromMap(Map<String, dynamic> json) {
    return Modelo(
      id: json['id'] as int,
      id_marca: json['id_marca'] as int,
      nome: json['nome'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_marca': id_marca,
      'nome': nome,
    };
  }
}
