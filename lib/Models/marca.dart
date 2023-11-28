class Marca {
  int id;
  String nome;

  Marca({required this.id, required this.nome});

  factory Marca.fromMap(Map<String, dynamic> map) {
    return Marca(
      id: map['id'] as int,
      nome: map['nome'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
    };
  }
}
