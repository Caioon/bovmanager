import 'package:bov_manager/repositories/propriedade_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bov_manager/models/propriedade_model.dart';
import 'package:bov_manager/services/propriedade_service.dart';

class MockPropriedadeRepository extends PropriedadeRepository {
  final List<PropriedadeModel> propriedades = [];

  bool criou = false;
  bool editou = false;
  bool apagou = false;

  @override
  Stream<List<PropriedadeModel>> listarPropriedades({
    required String proprietarioId,
  }) {
    return Stream.value(
      propriedades.where((p) => p.proprietarioId == proprietarioId).toList(),
    );
  }

  @override
  Future<void> criarPropriedade({
    required String nome,
    required String proprietarioId,
  }) async {
    criou = true;
  }

  @override
  Future<void> editarPropriedade({
    required String propriedadeId,
    required String nome,
  }) async {
    editou = true;
  }

  @override
  Future<void> apagarPropriedade({required String propriedadeId}) async {
    apagou = true;
  }

  @override
  Future<PropriedadeModel?> buscarPorId({required String propriedadeId}) async {
    try {
      return propriedades.firstWhere((p) => p.id == propriedadeId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> salvarCentro({
    required String propriedadeId,
    required double lat,
    required double lng,
  }) async {}
}

void main() {
  group('PropriedadeService', () {
    late MockPropriedadeRepository repository;
    late PropriedadeService service;

    final propriedade = PropriedadeModel(
      id: 'propriedade123',
      nome: 'Fazenda Teste',
      proprietarioId: 'usuario123',
      dataCadastro: DateTime(2026),
      centroLat: -20.0,
      centroLng: -54.0,
    );

    setUp(() {
      repository = MockPropriedadeRepository();
      service = PropriedadeService(repository as dynamic);
    });

    test('listar() deve retornar propriedades do proprietário', () async {
      repository.propriedades.add(propriedade);

      final result = await service.listar('usuario123').first;

      expect(result.length, 1);
      expect(result.first.id, 'propriedade123');
      expect(result.first.nome, 'Fazenda Teste');
    });

    test('criar() deve chamar criação no repositório', () async {
      await service.criar(nome: 'Nova Fazenda', proprietarioId: 'usuario123');

      expect(repository.criou, true);
    });

    test('editar() deve chamar edição no repositório', () async {
      await service.editar(
        propriedadeId: 'propriedade123',
        nome: 'Fazenda Editada',
      );

      expect(repository.editou, true);
    });

    test('apagar() deve chamar remoção no repositório', () async {
      await service.apagar(propriedadeId: 'propriedade123');

      expect(repository.apagou, true);
    });

    test('buscarPorId() deve retornar propriedade encontrada', () async {
      repository.propriedades.add(propriedade);

      final result = await service.buscarPorId(propriedadeId: 'propriedade123');

      expect(result, isNotNull);
      expect(result!.id, 'propriedade123');
      expect(result.nome, 'Fazenda Teste');
    });

    test('buscarPorId() sem propriedade deve retornar null', () async {
      final result = await service.buscarPorId(propriedadeId: 'inexistente');

      expect(result, null);
    });
  });
}
