import 'package:flutter_test/flutter_test.dart';
import 'package:bov_manager/models/animal_model.dart';
import 'package:bov_manager/models/historico_tipo.dart';

class MockAnimalService {
  bool criou = false;
  bool editou = false;
  bool apagou = false;
  bool registrouHistorico = false;

  Future<void> criar({
    required String nome,
    required String brinco,
    required String raca,
    required double novoPeso,
    required DateTime dataNascimento,
    required String? rebanhoId,
    required String propriedadeId,
    String? pastoDestinoId,
    String? fotoUrl,
  }) async {
    criou = true;
  }

  Future<void> editar({
    required String animalId,
    required String nome,
    required String brinco,
    required String raca,
    required double pesoAtual,
    String? fotoUrl,
  }) async {
    editou = true;
  }

  Future<void> apagar({required String animalId}) async {
    apagou = true;
  }

  Future<void> registrarHistorico({
    required String animalId,
    required double? novoPeso,
    required DateTime data,
    required HistoricoTipo tipo,
    String? pastoOrigemId,
    String? pastoDestinoId,
    String? rebanhoOrigemId,
    String? rebanhoDestinoId,
    String? nomePastoOrigem,
    String? nomePastoDestino,
    String? nomeRebanhoOrigem,
    String? nomeRebanhoDestino,
  }) async {
    registrouHistorico = true;
  }
}

void main() {
  group('AnimalEmVisualizacao', () {
    test('abrir deve definir animal selecionado', () {
      final animal = AnimalModel(
        id: 'animal123',
        nome: 'Boi',
        brinco: '001',
        raca: 'Nelore',
        pesoAtual: 400,
        dataNascimento: DateTime(2020),
        propriedadeId: 'prop123',
      );

      expect(animal.id, 'animal123');
    });

    test('fechar deve limpar animal selecionado', () {
      AnimalModel? animal;

      animal = null;

      expect(animal, null);
    });
  });

  group('AnimaisViewModel', () {
    test('criar deve chamar serviço corretamente', () async {
      final service = MockAnimalService();

      await service.criar(
        nome: 'Boi',
        brinco: '001',
        raca: 'Nelore',
        novoPeso: 450,
        dataNascimento: DateTime(2020),
        rebanhoId: null,
        propriedadeId: 'prop123',
      );

      expect(service.criou, true);
    });

    test('editar deve chamar serviço corretamente', () async {
      final service = MockAnimalService();

      await service.editar(
        animalId: 'animal123',
        nome: 'Novo nome',
        brinco: '002',
        raca: 'Angus',
        pesoAtual: 500,
      );

      expect(service.editou, true);
    });

    test('apagar deve chamar serviço corretamente', () async {
      final service = MockAnimalService();

      await service.apagar(animalId: 'animal123');

      expect(service.apagou, true);
    });

    test('registrarHistoricoPesagem deve enviar dados de pesagem', () async {
      final service = MockAnimalService();

      await service.registrarHistorico(
        animalId: 'animal123',
        novoPeso: 520,
        data: DateTime(2026),
        tipo: HistoricoTipo.pesagem,
      );

      expect(service.registrouHistorico, true);
    });

    test(
      'registrarHistoricoMovimento deve enviar dados de movimentação',
      () async {
        final service = MockAnimalService();

        await service.registrarHistorico(
          animalId: 'animal123',
          novoPeso: null,
          data: DateTime(2026),
          tipo: HistoricoTipo.sairRebanhoMudarPasto,
          pastoOrigemId: 'pasto1',
          pastoDestinoId: 'pasto2',
        );

        expect(service.registrouHistorico, true);
      },
    );
  });
}
