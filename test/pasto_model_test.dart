import 'package:bov_manager/models/pasto_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'model_factories.dart';

void main() {
  group('PastoModel', () {
    test('toMap serializa todos os campos', () {
      final pasto = makePasto(
        nome: 'Pasto Norte',
        propriedadeId: 'prop-1',
        area: 10.0,
        descricao: 'Descrição do pasto',
        limiteAnimais: 50,
      );

      final map = pasto.toMap();

      expect(map['nome'], 'Pasto Norte');
      expect(map['propriedadeId'], 'prop-1');
      expect(map['area'], 10.0);
      expect(map['descricao'], 'Descrição do pasto');
      expect(map['limiteAnimais'], 50);
    });

    test('fromMap desserializa corretamente', () {
      final map = {
        'nome': 'Pasto Norte',
        'propriedadeId': 'prop-1',
        'area': 10.0,
        'descricao': 'Descrição do pasto',
        'limiteAnimais': 50,
      };

      final pasto = PastoModel.fromMap(map, 'pasto-1');

      expect(pasto.id, 'pasto-1');
      expect(pasto.nome, 'Pasto Norte');
      expect(pasto.propriedadeId, 'prop-1');
      expect(pasto.area, 10.0);
      expect(pasto.descricao, 'Descrição do pasto');
      expect(pasto.limiteAnimais, 50);
    });

    test('round-trip toMap → fromMap preserva todos os campos', () {
      final original = makePasto(limiteAnimais: 30);

      final map = original.toMap();
      final restaurado = PastoModel.fromMap(map, original.id);

      expect(restaurado.id, original.id);
      expect(restaurado.nome, original.nome);
      expect(restaurado.propriedadeId, original.propriedadeId);
      expect(restaurado.area, original.area);
      expect(restaurado.descricao, original.descricao);
      expect(restaurado.limiteAnimais, original.limiteAnimais);
    });
  });
}
