import 'package:flutter_test/flutter_test.dart';
import 'package:bov_manager/models/notificacao_model.dart';

void main() {
  group('NotificacaoModel', () {
    final dataEnvio = DateTime(2026, 1, 10, 12, 30);

    final notificacao = NotificacaoModel(
      id: 'notificacao123',
      tarefaId: 'tarefa123',
      usuarioId: 'usuario123',
      mensagem: 'Tarefa pendente',
      enviada: true,
      dataEnvio: dataEnvio,
    );

    test('toMap() deve converter todos os campos corretamente', () {
      final map = notificacao.toMap();

      expect(map['tarefaId'], 'tarefa123');
      expect(map['usuarioId'], 'usuario123');
      expect(map['mensagem'], 'Tarefa pendente');
      expect(map['enviada'], true);
      expect(map['dataEnvio'], dataEnvio.toIso8601String());
    });

    test('NotificacaoModel.fromMap() deve criar objeto corretamente', () {
      final map = {
        'tarefaId': 'tarefa123',
        'usuarioId': 'usuario123',
        'mensagem': 'Tarefa pendente',
        'enviada': true,
        'dataEnvio': dataEnvio.toIso8601String(),
      };

      final result = NotificacaoModel.fromMap(map, 'notificacao123');

      expect(result.id, 'notificacao123');
      expect(result.tarefaId, 'tarefa123');
      expect(result.usuarioId, 'usuario123');
      expect(result.mensagem, 'Tarefa pendente');
      expect(result.enviada, true);
      expect(result.dataEnvio, dataEnvio);
    });

    test('Round-trip toMap() → fromMap() deve manter todos os valores', () {
      final map = notificacao.toMap();

      final result = NotificacaoModel.fromMap(
        map,
        notificacao.id,
      );

      expect(result.id, notificacao.id);
      expect(result.tarefaId, notificacao.tarefaId);
      expect(result.usuarioId, notificacao.usuarioId);
      expect(result.mensagem, notificacao.mensagem);
      expect(result.enviada, notificacao.enviada);
      expect(result.dataEnvio, notificacao.dataEnvio);
    });

    test('fromMap() com campos opcionais ausentes deve usar valores padrão', () {
      final map = {
        'dataEnvio': dataEnvio.toIso8601String(),
      };

      final result = NotificacaoModel.fromMap(map, 'notificacao123');

      expect(result.id, 'notificacao123');
      expect(result.tarefaId, '');
      expect(result.usuarioId, '');
      expect(result.mensagem, '');
      expect(result.enviada, false);
      expect(result.dataEnvio, dataEnvio);
    });
  });
}
