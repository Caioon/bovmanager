class PastoModel {
  final String id;
  final String nome;
  final String propriedadeId;
  final double area;
  final String descricao;
  final int? limiteAnimais;

  PastoModel({
    required this.id,
    required this.nome,
    required this.propriedadeId,
    required this.area,
    required this.descricao,
    this.limiteAnimais,
  });

  factory PastoModel.fromMap(
    Map<String, dynamic> map,
    String docId,
  ) {
    return PastoModel(
      id: docId,
      nome: map['nome'] ?? '',
      propriedadeId: map['propriedadeId'] ?? '',
      area: (map['area'] ?? 0).toDouble(),
      descricao: map['descricao'] ?? '',
      limiteAnimais: map['limiteAnimais'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'propriedadeId': propriedadeId,
      'area': area,
      'descricao': descricao,
      if (limiteAnimais != null) 'limiteAnimais': limiteAnimais,
    };
  }
}
