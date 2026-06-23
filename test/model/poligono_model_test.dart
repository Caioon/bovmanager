import 'package:flutter_test/flutter_test.dart';
import 'package:bov_manager/models/poligono_model.dart';

void main() {
  group('PoligonoModel', () {
    final pontos = [
      const LatLngPoint(lat: -20.123, lng: -54.456),
      const LatLngPoint(lat: -20.789, lng: -54.987),
    ];

    final poligono = PoligonoModel(
      id: 'poligono123',
      propriedadeId: 'propriedade123',
      pastoId: 'pasto123',
      pontos: pontos,
    );

    test('LatLngPoint.toMap() deve converter coordenadas corretamente', () {
      final map = pontos.first.toMap();

      expect(map['lat'], -20.123);
      expect(map['lng'], -54.456);
    });

    test('LatLngPoint.fromMap() deve criar ponto corretamente', () {
      final map = {
        'lat': -20.123,
        'lng': -54.456,
      };

      final result = LatLngPoint.fromMap(map);

      expect(result.lat, -20.123);
      expect(result.lng, -54.456);
    });

    test('toMap() deve converter todos os campos corretamente', () {
      final map = poligono.toMap();

      expect(map['propriedadeId'], 'propriedade123');
      expect(map['pastoId'], 'pasto123');
      expect(map['pontos'], [
        {
          'lat': -20.123,
          'lng': -54.456,
        },
        {
          'lat': -20.789,
          'lng': -54.987,
        },
      ]);
    });

    test('PoligonoModel.fromMap() deve criar objeto corretamente', () {
      final map = {
        'propriedadeId': 'propriedade123',
        'pastoId': 'pasto123',
        'pontos': [
          {
            'lat': -20.123,
            'lng': -54.456,
          },
          {
            'lat': -20.789,
            'lng': -54.987,
          },
        ],
      };

      final result = PoligonoModel.fromMap(map, 'poligono123');

      expect(result.id, 'poligono123');
      expect(result.propriedadeId, 'propriedade123');
      expect(result.pastoId, 'pasto123');
      expect(result.pontos.length, 2);
      expect(result.pontos[0].lat, -20.123);
      expect(result.pontos[0].lng, -54.456);
      expect(result.pontos[1].lat, -20.789);
      expect(result.pontos[1].lng, -54.987);
    });

    test('Round-trip toMap() → fromMap() deve manter todos os valores', () {
      final map = poligono.toMap();

      final result = PoligonoModel.fromMap(
        map,
        poligono.id,
      );

      expect(result.id, poligono.id);
      expect(result.propriedadeId, poligono.propriedadeId);
      expect(result.pastoId, poligono.pastoId);
      expect(result.pontos.length, poligono.pontos.length);

      for (var i = 0; i < poligono.pontos.length; i++) {
        expect(result.pontos[i].lat, poligono.pontos[i].lat);
        expect(result.pontos[i].lng, poligono.pontos[i].lng);
      }
    });

    test('fromMap() com pontos ausentes deve retornar lista vazia', () {
      final map = {
        'propriedadeId': 'propriedade123',
        'pastoId': 'pasto123',
      };

      final result = PoligonoModel.fromMap(map, 'poligono123');

      expect(result.id, 'poligono123');
      expect(result.propriedadeId, 'propriedade123');
      expect(result.pastoId, 'pasto123');
      expect(result.pontos, isEmpty);
    });
  });
}
