import 'package:bov_manager/models/tarefa_model.dart';
import 'package:flutter_test/flutter_test.dart';

import 'model_factories.dart';

void main() {
  group('TarefaModel', () {
    group('fromMap / toMap', () {
      test('toMap serializa todos os campos corretamente', () {
        final tarefa = makeTarefa(
          id: 'tarefa-1',
          titulo: 'Vacinação',
          descricao: 'Vacinar o rebanho',
          dataExecucao: DateTime(2024, 8, 15),
          status: StatusTarefa.pendente,
          propriedadeId: 'prop-1',
          usuarioId: 'user-1',
          horaExecucaoMinutos: 90,
        );

        final map = tarefa.toMap();

        expect(map['titulo'], 'Vacinação');
        expect(map['descricao'], 'Vacinar o rebanho');
        expect(map['dataExecucao'], DateTime(2024, 8, 15).toIso8601String());
        expect(map['status'], 'pendente');
        expect(map['propriedadeId'], 'prop-1');
        expect(map['usuarioId'], 'user-1');
        expect(map['horaExecucaoMinutos'], 90);
      });

      test('fromMap desserializa corretamente', () {
        final map = {
          'titulo': 'Vacinação',
          'descricao': 'Vacinar o rebanho',
          'dataExecucao': DateTime(2024, 8, 15).toIso8601String(),
          'status': 'pendente',
          'propriedadeId': 'prop-1',
          'usuarioId': 'user-1',
          'horaExecucaoMinutos': 90,
        };

        final tarefa = TarefaModel.fromMap(map, 'tarefa-1');

        expect(tarefa.id, 'tarefa-1');
        expect(tarefa.titulo, 'Vacinação');
        expect(tarefa.descricao, 'Vacinar o rebanho');
        expect(tarefa.dataExecucao, DateTime(2024, 8, 15));
        expect(tarefa.status, StatusTarefa.pendente);
        expect(tarefa.propriedadeId, 'prop-1');
        expect(tarefa.usuarioId, 'user-1');
        expect(tarefa.horaExecucaoMinutos, 90);
      });

      test('fromMap com horaExecucaoMinutos ausente retorna campo null', () {
        final map = {
          'titulo': 'Vacinação',
          'descricao': '',
          'dataExecucao': DateTime(2024, 8, 15).toIso8601String(),
          'status': 'pendente',
          'propriedadeId': 'prop-1',
          'usuarioId': 'user-1',
        };

        final tarefa = TarefaModel.fromMap(map, 'tarefa-1');

        expect(tarefa.horaExecucaoMinutos, isNull);
      });
    });

    group('copyWith', () {
      test('copyWith sem argumentos retorna cópia com campos idênticos', () {
        final original = makeTarefa();
        final copia = original.copyWith();

        expect(copia.id, original.id);
        expect(copia.titulo, original.titulo);
        expect(copia.descricao, original.descricao);
        expect(copia.dataExecucao, original.dataExecucao);
        expect(copia.status, original.status);
        expect(copia.propriedadeId, original.propriedadeId);
        expect(copia.usuarioId, original.usuarioId);
        expect(copia.horaExecucaoMinutos, original.horaExecucaoMinutos);
      });

      test('copyWith altera apenas os campos informados', () {
        final original = makeTarefa();
        final copia = original.copyWith(titulo: 'Novo Título');

        expect(copia.titulo, 'Novo Título');
        expect(copia.id, original.id);
        expect(copia.descricao, original.descricao);
        expect(copia.dataExecucao, original.dataExecucao);
        expect(copia.status, original.status);
        expect(copia.propriedadeId, original.propriedadeId);
        expect(copia.usuarioId, original.usuarioId);
        expect(copia.horaExecucaoMinutos, original.horaExecucaoMinutos);
      });

      test('copyWith com clearHora: true zera horaExecucaoMinutos', () {
        final tarefa = makeTarefa(horaExecucaoMinutos: 120);
        final copia = tarefa.copyWith(clearHora: true);

        expect(copia.horaExecucaoMinutos, isNull);
      });

      test('copyWith com clearHora: false preserva horaExecucaoMinutos', () {
        final tarefa = makeTarefa(horaExecucaoMinutos: 60);
        final copia = tarefa.copyWith(clearHora: false);

        expect(copia.horaExecucaoMinutos, 60);
      });
    });

    group('getter dataHoraExecucao', () {
      test('retorna null quando horaExecucaoMinutos é null', () {
        final tarefa = makeTarefa(horaExecucaoMinutos: null);

        expect(tarefa.dataHoraExecucao, isNull);
      });

      test('retorna DateTime correto para horaExecucaoMinutos: 90', () {
        final tarefa = makeTarefa(
          dataExecucao: DateTime(2024, 8, 15),
          horaExecucaoMinutos: 90,
        );

        final resultado = tarefa.dataHoraExecucao!;

        expect(resultado.year, 2024);
        expect(resultado.month, 8);
        expect(resultado.day, 15);
        expect(resultado.hour, 1);
        expect(resultado.minute, 30);
      });

      test('horaExecucaoMinutos: 0 retorna meia-noite do dia da tarefa', () {
        final tarefa = makeTarefa(
          dataExecucao: DateTime(2024, 8, 15),
          horaExecucaoMinutos: 0,
        );

        final resultado = tarefa.dataHoraExecucao!;

        expect(resultado.hour, 0);
        expect(resultado.minute, 0);
      });
    });
  });
}
