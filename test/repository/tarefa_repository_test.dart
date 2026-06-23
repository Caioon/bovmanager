import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:bov_manager/repositories/tarefa_repository.dart';
import 'package:bov_manager/models/tarefa_model.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late TarefaRepository repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();

    repository = TarefaRepository(
      firestore: firestore,
    );
  });

  group('TarefaRepository', () {
    final tarefa = TarefaModel(
      id: 'tarefa123',
      titulo: 'Vacinar animais',
      descricao: 'Aplicar vacina no rebanho',
      dataExecucao: DateTime(2026, 1, 15),
      horaExecucaoMinutos: 600,
      status: StatusTarefa.pendente,
      propriedadeId: 'prop123',
      usuarioId: 'user123',
    );

    test('listar() deve retornar tarefas da propriedade', () async {
      await firestore
          .collection('propriedades')
          .doc('prop123')
          .collection('tarefas')
          .doc('tarefa123')
          .set(tarefa.toMap());

      final result = await repository
          .listar('prop123')
          .first;

      expect(result.length, 1);
      expect(result.first.id, 'tarefa123');
      expect(result.first.titulo, 'Vacinar animais');
      expect(result.first.propriedadeId, 'prop123');
    });

    test('criar() deve adicionar tarefa e retornar id gerado', () async {
      final id = await repository.criar(tarefa);

      final doc = await firestore
          .collection('propriedades')
          .doc('prop123')
          .collection('tarefas')
          .doc(id)
          .get();

      expect(id, isNotEmpty);
      expect(doc.exists, true);

      expect(doc.data()?['titulo'], 'Vacinar animais');
      expect(doc.data()?['descricao'], 'Aplicar vacina no rebanho');
    });

    test('atualizarStatus() deve atualizar status da tarefa', () async {
      await firestore
          .collection('propriedades')
          .doc('prop123')
          .collection('tarefas')
          .doc('tarefa123')
          .set(tarefa.toMap());

      await repository.atualizarStatus(
        propriedadeId: 'prop123',
        tarefaId: 'tarefa123',
        status: StatusTarefa.concluida,
      );

      final doc = await firestore
          .collection('propriedades')
          .doc('prop123')
          .collection('tarefas')
          .doc('tarefa123')
          .get();

      expect(
        doc.data()?['status'],
        StatusTarefa.concluida.name,
      );
    });

    test('atualizarData() deve atualizar data e horário', () async {
      await firestore
          .collection('propriedades')
          .doc('prop123')
          .collection('tarefas')
          .doc('tarefa123')
          .set(tarefa.toMap());

      final novaData = DateTime(2026, 2, 20);

      await repository.atualizarData(
        propriedadeId: 'prop123',
        tarefaId: 'tarefa123',
        novaData: novaData,
        horaExecucaoMinutos: 720,
      );

      final doc = await firestore
          .collection('propriedades')
          .doc('prop123')
          .collection('tarefas')
          .doc('tarefa123')
          .get();

      expect(
        doc.data()?['dataExecucao'],
        novaData.toIso8601String(),
      );

      expect(
        doc.data()?['horaExecucaoMinutos'],
        720,
      );
    });

    test('atualizarData() deve remover horário quando clearHora for true', () async {
      await firestore
          .collection('propriedades')
          .doc('prop123')
          .collection('tarefas')
          .doc('tarefa123')
          .set(tarefa.toMap());

      await repository.atualizarData(
        propriedadeId: 'prop123',
        tarefaId: 'tarefa123',
        novaData: DateTime(2026, 3, 1),
        clearHora: true,
      );

      final doc = await firestore
          .collection('propriedades')
          .doc('prop123')
          .collection('tarefas')
          .doc('tarefa123')
          .get();

      expect(
        doc.data()?['horaExecucaoMinutos'],
        null,
      );
    });

    test('atualizar() deve atualizar todos os campos da tarefa', () async {
      await firestore
          .collection('propriedades')
          .doc('prop123')
          .collection('tarefas')
          .doc('tarefa123')
          .set(tarefa.toMap());

      final novaData = DateTime(2026, 4, 1);

      await repository.atualizar(
        propriedadeId: 'prop123',
        tarefaId: 'tarefa123',
        titulo: 'Nova tarefa',
        descricao: 'Nova descrição',
        dataExecucao: novaData,
        horaExecucaoMinutos: 900,
      );

      final doc = await firestore
          .collection('propriedades')
          .doc('prop123')
          .collection('tarefas')
          .doc('tarefa123')
          .get();

      expect(doc.data()?['titulo'], 'Nova tarefa');
      expect(doc.data()?['descricao'], 'Nova descrição');
      expect(doc.data()?['dataExecucao'], novaData.toIso8601String());
      expect(doc.data()?['horaExecucaoMinutos'], 900);
    });

    test('atualizar() deve remover horário quando clearHora for true', () async {
      await firestore
          .collection('propriedades')
          .doc('prop123')
          .collection('tarefas')
          .doc('tarefa123')
          .set(tarefa.toMap());

      await repository.atualizar(
        propriedadeId: 'prop123',
        tarefaId: 'tarefa123',
        titulo: 'Tarefa',
        descricao: 'Descrição',
        dataExecucao: DateTime(2026, 5, 1),
        clearHora: true,
      );

      final doc = await firestore
          .collection('propriedades')
          .doc('prop123')
          .collection('tarefas')
          .doc('tarefa123')
          .get();

      expect(
        doc.data()?['horaExecucaoMinutos'],
        null,
      );
    });

    test('apagar() deve remover tarefa', () async {
      await firestore
          .collection('propriedades')
          .doc('prop123')
          .collection('tarefas')
          .doc('tarefa123')
          .set(tarefa.toMap());

      await repository.apagar(
        propriedadeId: 'prop123',
        tarefaId: 'tarefa123',
      );

      final doc = await firestore
          .collection('propriedades')
          .doc('prop123')
          .collection('tarefas')
          .doc('tarefa123')
          .get();

      expect(doc.exists, false);
    });
  });
}
