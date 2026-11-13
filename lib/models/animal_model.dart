class AnimalModel {
  final String id;
  final String nome;
  final String brinco;
  final String raca;
  final double pesoAtual;
  final DateTime dataNascimento;
  final String propriedadeId;
  final String? fotoUrl;

  AnimalModel({
    required this.id,
    required this.nome,
    required this.brinco,
    required this.raca,
    required this.pesoAtual,
    required this.dataNascimento,
    required this.propriedadeId,
    this.fotoUrl,
  });

  factory AnimalModel.fromMap(Map<String, dynamic> map, String docId) {
    return AnimalModel(
      id: docId,
      nome: map['nome'] ?? '',
      brinco: map['brinco'] ?? '',
      raca: map['raca'] ?? '',
      pesoAtual: (map['pesoAtual'] ?? 0).toDouble(),
      dataNascimento: DateTime.parse(map['dataNascimento']),
      propriedadeId: map['propriedadeId'] ?? '',
      fotoUrl: map['fotoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'brinco': brinco,
      'raca': raca,
      'pesoAtual': pesoAtual,
      'dataNascimento': dataNascimento.toIso8601String(),
      'propriedadeId': propriedadeId,
      'fotoUrl': fotoUrl,
    };
  }
}
