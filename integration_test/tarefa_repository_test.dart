import 'package:bov_manager/models/tarefa_model.dart';
import 'package:bov_manager/repositories/tarefa_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'firebase_test_setup.dart';

void main() {
  late TarefaRepository repository;

  const propriedadeId = 'prop-test';

  TarefaModel _makeTarefa({int? horaExecucaoMinutos}) => TarefaModel(
    id: '',
    titulo: 'Vacinar gado',
    descricao: 'Dose anual de febre aftosa',
    dataExecucao: DateTime(2024, 6, 15),
    status: StatusTarefa.pendente,
    propriedadeId: propriedadeId,
    usuarioId: 'user-1',
    horaExecucaoMinutos: horaExecucaoMinutos,
  );

  Future<String> _criarEObterID([TarefaModel? tarefa]) =>
      repository.criar(tarefa ?? _makeTarefa());

  Future<Map<String, dynamic>> _getData(String tarefaId) async {
    final doc = await FirebaseFirestore.instance
        .collection('propriedades')
        .doc(propriedadeId)
        .collection('tarefas')
        .doc(tarefaId)
        .get();
    return doc.data()!;
  }

  setUpAll(() async {
    await setupFirebaseEmulator();
    repository = TarefaRepository(firestore: FirebaseFirestore.instance);
  });

  setUp(() async {
    await clearFirestoreEmulator();
  });

  // ---------------------------------------------------------------------------
  // criar
  // ---------------------------------------------------------------------------
  group('criar', () {
    test('persiste todos os campos e retorna o ID gerado', () async {
      final id = await _criarEObterID(_makeTarefa(horaExecucaoMinutos: 480));

      expect(id, isNotEmpty);

      final data = await _getData(id);
      expect(data['titulo'], 'Vacinar gado');
      expect(data['descricao'], 'Dose anual de febre aftosa');
      expect(data['dataExecucao'], '2024-06-15T00:00:00.000');
      expect(data['status'], 'pendente');
      expect(data['propriedadeId'], propriedadeId);
      expect(data['usuarioId'], 'user-1');
      expect(data['horaExecucaoMinutos'], 480);
    });

    test(
      'persiste horaExecucaoMinutos como null quando não informado',
      () async {
        final id = await _criarEObterID();

        final data = await _getData(id);
        expect(data['horaExecucaoMinutos'], isNull);
      },
    );

    test('retorna IDs distintos para tarefas diferentes', () async {
      final id1 = await _criarEObterID();
      final id2 = await _criarEObterID();

      expect(id1, isNot(id2));
    });
  });

  // ---------------------------------------------------------------------------
  // atualizarStatus
  // ---------------------------------------------------------------------------
  group('atualizarStatus', () {
    test('altera status para concluida', () async {
      final id = await _criarEObterID();

      await repository.atualizarStatus(
        propriedadeId: propriedadeId,
        tarefaId: id,
        status: StatusTarefa.concluida,
      );

      expect((await _getData(id))['status'], 'concluida');
    });

    test('não altera outros campos ao mudar o status', () async {
      final id = await _criarEObterID();

      await repository.atualizarStatus(
        propriedadeId: propriedadeId,
        tarefaId: id,
        status: StatusTarefa.concluida,
      );

      final data = await _getData(id);
      expect(data['titulo'], 'Vacinar gado');
      expect(data['dataExecucao'], '2024-06-15T00:00:00.000');
    });
  });

  // ---------------------------------------------------------------------------
  // atualizarData
  // ---------------------------------------------------------------------------
  group('atualizarData', () {
    test('atualiza dataExecucao e horaExecucaoMinutos', () async {
      final id = await _criarEObterID();

      await repository.atualizarData(
        propriedadeId: propriedadeId,
        tarefaId: id,
        novaData: DateTime(2024, 9, 20),
        horaExecucaoMinutos: 720,
      );

      final data = await _getData(id);
      expect(data['dataExecucao'], '2024-09-20T00:00:00.000');
      expect(data['horaExecucaoMinutos'], 720);
    });

    test('grava null em horaExecucaoMinutos quando clearHora é true', () async {
      final id = await _criarEObterID(_makeTarefa(horaExecucaoMinutos: 480));

      await repository.atualizarData(
        propriedadeId: propriedadeId,
        tarefaId: id,
        novaData: DateTime(2024, 9, 20),
        clearHora: true,
      );

      final data = await _getData(id);
      expect(data.containsKey('horaExecucaoMinutos'), isTrue);
      expect(data['horaExecucaoMinutos'], isNull);
    });

    test('não altera campos fora do escopo (titulo, status)', () async {
      final id = await _criarEObterID();

      await repository.atualizarData(
        propriedadeId: propriedadeId,
        tarefaId: id,
        novaData: DateTime(2024, 9, 20),
      );

      final data = await _getData(id);
      expect(data['titulo'], 'Vacinar gado');
      expect(data['status'], 'pendente');
    });
  });

  // ---------------------------------------------------------------------------
  // atualizar
  // ---------------------------------------------------------------------------
  group('atualizar', () {
    test('persiste todos os campos editáveis', () async {
      final id = await _criarEObterID();

      await repository.atualizar(
        propriedadeId: propriedadeId,
        tarefaId: id,
        titulo: 'Vermifugar',
        descricao: 'Tratamento trimestral',
        dataExecucao: DateTime(2024, 8, 10),
        horaExecucaoMinutos: 600,
      );

      final data = await _getData(id);
      expect(data['titulo'], 'Vermifugar');
      expect(data['descricao'], 'Tratamento trimestral');
      expect(data['dataExecucao'], '2024-08-10T00:00:00.000');
      expect(data['horaExecucaoMinutos'], 600);
    });

    test('grava null em horaExecucaoMinutos quando clearHora é true', () async {
      final id = await _criarEObterID(_makeTarefa(horaExecucaoMinutos: 480));

      await repository.atualizar(
        propriedadeId: propriedadeId,
        tarefaId: id,
        titulo: 'Vermifugar',
        descricao: 'Tratamento trimestral',
        dataExecucao: DateTime(2024, 8, 10),
        clearHora: true,
      );

      final data = await _getData(id);
      expect(data.containsKey('horaExecucaoMinutos'), isTrue);
      expect(data['horaExecucaoMinutos'], isNull);
    });

    test('não altera campos fora do escopo (status, usuarioId)', () async {
      final id = await _criarEObterID();

      await repository.atualizar(
        propriedadeId: propriedadeId,
        tarefaId: id,
        titulo: 'Vermifugar',
        descricao: 'Tratamento trimestral',
        dataExecucao: DateTime(2024, 8, 10),
      );

      final data = await _getData(id);
      expect(data['status'], 'pendente');
      expect(data['usuarioId'], 'user-1');
    });
  });

  // ---------------------------------------------------------------------------
  // apagar
  // ---------------------------------------------------------------------------
  group('apagar', () {
    test('remove o documento do Firestore', () async {
      final id = await _criarEObterID();

      await repository.apagar(propriedadeId: propriedadeId, tarefaId: id);

      final doc = await FirebaseFirestore.instance
          .collection('propriedades')
          .doc(propriedadeId)
          .collection('tarefas')
          .doc(id)
          .get();

      expect(doc.exists, isFalse);
    });

    test('apaga apenas a tarefa alvo quando existem múltiplas', () async {
      final alvo = await _criarEObterID();
      final outra = await _criarEObterID();

      await repository.apagar(propriedadeId: propriedadeId, tarefaId: alvo);

      final docAlvo = await FirebaseFirestore.instance
          .collection('propriedades')
          .doc(propriedadeId)
          .collection('tarefas')
          .doc(alvo)
          .get();

      final docOutra = await FirebaseFirestore.instance
          .collection('propriedades')
          .doc(propriedadeId)
          .collection('tarefas')
          .doc(outra)
          .get();

      expect(docAlvo.exists, isFalse);
      expect(docOutra.exists, isTrue);
    });
  });
}
