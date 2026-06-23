import 'package:bov_manager/models/propriedade_model.dart';
import 'package:flutter_test/flutter_test.dart';

import 'model_factories.dart';

void main() {
  group('PropriedadeModel', () {
    test('toMap serializa todos os campos', () {
      final propriedade = makePropriedade(
        nome: 'Fazenda Teste',
        proprietarioId: 'user-1',
        dataCadastro: DateTime(2023, 6, 1),
        centroLat: -20.0,
        centroLng: -49.0,
      );

      final map = propriedade.toMap();

      expect(map['nome'], 'Fazenda Teste');
      expect(map['proprietarioId'], 'user-1');
      expect(map['dataCadastro'], DateTime(2023, 6, 1).toIso8601String());
      expect(map['centroLat'], -20.0);
      expect(map['centroLng'], -49.0);
    });

    test('fromMap desserializa corretamente', () {
      final map = {
        'nome': 'Fazenda Teste',
        'proprietarioId': 'user-1',
        'dataCadastro': DateTime(2023, 6, 1).toIso8601String(),
        'centroLat': -20.0,
        'centroLng': -49.0,
      };

      final propriedade = PropriedadeModel.fromMap(map, 'prop-1');

      expect(propriedade.id, 'prop-1');
      expect(propriedade.nome, 'Fazenda Teste');
      expect(propriedade.proprietarioId, 'user-1');
      expect(propriedade.dataCadastro, DateTime(2023, 6, 1));
      expect(propriedade.centroLat, -20.0);
      expect(propriedade.centroLng, -49.0);
    });

    test('round-trip toMap → fromMap preserva todos os campos', () {
      final original = makePropriedade();

      final map = original.toMap();
      final restaurado = PropriedadeModel.fromMap(map, original.id);

      expect(restaurado.id, original.id);
      expect(restaurado.nome, original.nome);
      expect(restaurado.proprietarioId, original.proprietarioId);
      expect(restaurado.dataCadastro, original.dataCadastro);
      expect(restaurado.centroLat, original.centroLat);
      expect(restaurado.centroLng, original.centroLng);
    });

    test(
        'fromMap sem centroLat e centroLng não lança exceção e retorna null nesses campos',
        () {
      final map = {
        'nome': 'Fazenda Teste',
        'proprietarioId': 'user-1',
        'dataCadastro': DateTime(2023, 6, 1).toIso8601String(),
      };

      final propriedade = PropriedadeModel.fromMap(map, 'prop-1');

      expect(propriedade.centroLat, isNull);
      expect(propriedade.centroLng, isNull);
    });
  });
}
