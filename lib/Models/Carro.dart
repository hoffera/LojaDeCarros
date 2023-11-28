import 'package:cloud_firestore/cloud_firestore.dart';

class Carro {
  int id;
  int id_modelo;
  String nome;
  int renavam;
  String placa;
  double valor;
  DateTime ano;

  Carro({
    required this.id,
    required this.id_modelo,
    required this.nome,
    required this.renavam,
    required this.placa,
    required this.valor,
    required this.ano,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_modelo': id_modelo,
      'nome': nome,
      'renavam': renavam,
      'placa': placa,
      'valor': valor,
      'ano': Timestamp.fromDate(ano), // Convertendo DateTime para Timestamp
    };
  }

  static Carro fromMap(Map<String, dynamic> map) {
    return Carro(
      id: map['id'],
      id_modelo: map['id_modelo'],
      nome: map['nome'],
      renavam: map['renavam'],
      placa: map['placa'],
      valor: map['valor'],
      ano: (map['ano'] as Timestamp)
          .toDate(), // Convertendo de Timestamp para DateTime
    );
  }
}
