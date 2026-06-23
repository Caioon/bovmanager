import 'package:bov_manager/repositories/poligono_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bov_manager/models/poligono_model.dart';
import 'package:bov_manager/services/poligono_service.dart';

class MockPoligonoRepository extends PoligonoRepository {
  MockPoligonoRepository(super.firestore);

  final List<PoligonoModel> poligonos = [];

  bool salvou = false;
  bool apagou = false;

  @override
  Future<List<PoligonoModel>> listar(String propriedadeId) async {
    return poligonos.where((p) => p.propriedadeId == propriedadeId).toList();
  }

  @override
  Future<PoligonoModel?> buscarPorPasto({
    required String propriedadeId,
    required String pastoId,
  }) async {
    try {
      return poligonos.firstWhere(
        (p) => p.propriedadeId == propriedadeId && p.pastoId == pastoId,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<List<PoligonoModel>> listarStream(String propriedadeId) {
    return Stream.value(
      poligonos.where((p) => p.propriedadeId == propriedadeId).toList(),
    );
  }

  @override
  Future<void> salvar(PoligonoModel poligono) async {
    salvou = true;
    poligonos.add(poligono);
  }

  @override
  Future<void> apagar({
    required String propriedadeId,
    required String pastoId,
  }) async {
    apagou = true;
  }
}

void main() {
  group('PoligonoService', () {
    late MockPoligonoRepository repository;
    late PoligonoService service;

    final pontos = [
      const LatLngPoint(lat: -20.0, lng: -54.0),
      const LatLngPoint(lat: -20.1, lng: -54.1),
      const LatLngPoint(lat: -20.2, lng: -54.2),
    ];

    final poligono = PoligonoModel(
      id: 'poligono123',
      propriedadeId: 'prop123',
      pastoId: 'pasto123',
      pontos: pontos,
    );

    setUp(() {
      repository = MockPoligonoRepository(FakeFirebaseFirestore());
      service = PoligonoService(repository as dynamic);
    });

    test('listar() deve retornar polígonos da propriedade', () async {
      repository.poligonos.add(poligono);

      final result = await service.listar('prop123');

      expect(result.length, 1);
      expect(result.first.id, 'poligono123');
    });

    test('buscarPorPasto() deve retornar polígono encontrado', () async {
      repository.poligonos.add(poligono);

      final result = await service.buscarPorPasto(
        propriedadeId: 'prop123',
        pastoId: 'pasto123',
      );

      expect(result, isNotNull);
      expect(result!.pastoId, 'pasto123');
    });

    test('buscarPorPasto() sem resultado deve retornar null', () async {
      final result = await service.buscarPorPasto(
        propriedadeId: 'prop123',
        pastoId: 'pasto123',
      );

      expect(result, null);
    });

    test('listarStream() deve retornar stream de polígonos', () async {
      repository.poligonos.add(poligono);

      final result = await service.listarStream('prop123').first;

      expect(result.length, 1);
      expect(result.first.propriedadeId, 'prop123');
    });

    test('salvar() deve salvar polígono com pontos suficientes', () async {
      await service.salvar(
        propriedadeId: 'prop123',
        pastoId: 'pasto123',
        pontos: pontos,
      );

      expect(repository.salvou, true);
    });

    test('salvar() deve impedir polígono com menos de 3 pontos', () {
      expect(
        () => service.salvar(
          propriedadeId: 'prop123',
          pastoId: 'pasto123',
          pontos: [const LatLngPoint(lat: -20, lng: -54)],
        ),
        throwsException,
      );
    });

    test('apagar() deve chamar remoção no repositório', () async {
      await service.apagar(propriedadeId: 'prop123', pastoId: 'pasto123');

      expect(repository.apagou, true);
    });
  });
}
