import 'package:bov_manager/models/rebanho_model.dart';
import 'package:flutter_test/flutter_test.dart';

import 'model_factories.dart';

void main() {
  group('RebanhoModel', () {
    test('toMap serializa todos os campos', () {
      final rebanho = makeRebanho(
        nome: 'Rebanho A',
        pastoId: 'pasto-1',
        propriedadeId: 'prop-1',
        dataCadastro: DateTime(2023, 6, 1),
      );

      final map = rebanho.toMap();

      expect(map['nome'], 'Rebanho A');
      expect(map['pastoId'], 'pasto-1');
      expect(map['propriedadeId'], 'prop-1');
      expect(map['dataCadastro'], DateTime(2023, 6, 1).toIso8601String());
    });

    test('fromMap desserializa corretamente', () {
      final map = {
        'nome': 'Rebanho A',
        'pastoId': 'pasto-1',
        'propriedadeId': 'prop-1',
        'dataCadastro': DateTime(2023, 6, 1).toIso8601String(),
      };

      final rebanho = RebanhoModel.fromMap(map, 'rebanho-1');

      expect(rebanho.id, 'rebanho-1');
      expect(rebanho.nome, 'Rebanho A');
      expect(rebanho.pastoId, 'pasto-1');
      expect(rebanho.propriedadeId, 'prop-1');
      expect(rebanho.dataCadastro, DateTime(2023, 6, 1));
    });

    test('round-trip toMap → fromMap preserva todos os campos', () {
      final original = makeRebanho();

      final map = original.toMap();
      final restaurado = RebanhoModel.fromMap(map, original.id);

      expect(restaurado.id, original.id);
      expect(restaurado.nome, original.nome);
      expect(restaurado.pastoId, original.pastoId);
      expect(restaurado.propriedadeId, original.propriedadeId);
      expect(restaurado.dataCadastro, original.dataCadastro);
    });
  });
}
