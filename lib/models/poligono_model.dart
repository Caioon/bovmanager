// Ponto geográfico simples — evita dependência do flutter_map na camada de modelo
class LatLngPoint {
  final double lat;
  final double lng;

  const LatLngPoint({required this.lat, required this.lng});

  factory LatLngPoint.fromMap(Map<String, dynamic> map) {
    return LatLngPoint(
      lat: (map['lat'] as num).toDouble(),
      lng: (map['lng'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {'lat': lat, 'lng': lng};
}

// =============================================================================
// MODELO DO POLÍGONO
// =============================================================================

class PoligonoModel {
  final String id;
  final String propriedadeId;
  final String pastoId;
  final List<LatLngPoint> pontos;

  PoligonoModel({
    required this.id,
    required this.propriedadeId,
    required this.pastoId,
    required this.pontos,
  });

  factory PoligonoModel.fromMap(Map<String, dynamic> map, String docId) {
    final pontosRaw = map['pontos'] as List<dynamic>? ?? [];
    return PoligonoModel(
      id: docId,
      propriedadeId: map['propriedadeId'] ?? '',
      pastoId: map['pastoId'] ?? '',
      pontos: pontosRaw
          .map((p) => LatLngPoint.fromMap(Map<String, dynamic>.from(p)))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'propriedadeId': propriedadeId,
      'pastoId': pastoId,
      'pontos': pontos.map((p) => p.toMap()).toList(),
    };
  }
}
