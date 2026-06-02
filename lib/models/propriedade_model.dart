class PropriedadeModel {
  final String id;
  final String nome;
  final String proprietarioId;
  final DateTime dataCadastro;
  final double? centroLat;
  final double? centroLng;

  PropriedadeModel({
    required this.id,
    required this.nome,
    required this.proprietarioId,
    required this.dataCadastro,
    this.centroLat,
    this.centroLng,
  });

  // Verdadeiro se o centro do mapa já foi definido pelo usuário
  bool get temCentroDefinido => centroLat != null && centroLng != null;

  factory PropriedadeModel.fromMap(
    Map<String, dynamic> map,
    String docId,
  ) {
    return PropriedadeModel(
      id: docId,
      nome: map['nome'] ?? '',
      proprietarioId: map['proprietarioId'] ?? '',
      dataCadastro: DateTime.parse(map['dataCadastro']),
      centroLat: (map['centroLat'] as num?)?.toDouble(),
      centroLng: (map['centroLng'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'proprietarioId': proprietarioId,
      'dataCadastro': dataCadastro.toIso8601String(),
      if (centroLat != null) 'centroLat': centroLat,
      if (centroLng != null) 'centroLng': centroLng,
    };
  }
}
