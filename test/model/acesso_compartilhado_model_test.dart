import 'package:bov_manager/models/acesso_compartilhado_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AcessoCompartilhadoModel', () {
    final dataConvite = DateTime(2026, 1, 10, 12, 30);

    final acesso = AcessoCompartilhadoModel(
      id: 'acesso123',
      propriedadeId: 'prop123',
      usuarioId: 'user123',
      papel: 'funcionario',
      dataConvite: dataConvite,
    );

    test('toMap() deve converter todos os campos corretamente', () {
      final map = acesso.toMap();

      expect(map['propriedadeId'], 'prop123');
      expect(map['usuarioId'], 'user123');
      expect(map['papel'], 'funcionario');
      expect(map['dataConvite'], dataConvite.toIso8601String());
    });

    test('AcessoCompartilhadoModel.fromMap() deve criar objeto corretamente', () {
      final map = {
        'propriedadeId': 'prop123',
        'usuarioId': 'user123',
        'papel': 'funcionario',
        'dataConvite': dataConvite.toIso8601String(),
      };

      final result = AcessoCompartilhadoModel.fromMap(map, 'acesso123');

      expect(result.id, 'acesso123');
      expect(result.propriedadeId, 'prop123');
      expect(result.usuarioId, 'user123');
      expect(result.papel, 'funcionario');
      expect(result.dataConvite, dataConvite);
    });

    test('Round-trip toMap() → fromMap() deve manter todos os valores', () {
      final map = acesso.toMap();

      final result = AcessoCompartilhadoModel.fromMap(
        map,
        acesso.id,
      );

      expect(result.id, acesso.id);
      expect(result.propriedadeId, acesso.propriedadeId);
      expect(result.usuarioId, acesso.usuarioId);
      expect(result.papel, acesso.papel);
      expect(result.dataConvite, acesso.dataConvite);
    });

    test('fromMap() com campos opcionais ausentes deve usar valores padrão', () {
      final map = {
        'dataConvite': dataConvite.toIso8601String(),
      };

      final result = AcessoCompartilhadoModel.fromMap(map, 'acesso123');

      expect(result.id, 'acesso123');
      expect(result.propriedadeId, '');
      expect(result.usuarioId, '');
      expect(result.papel, '');
      expect(result.dataConvite, dataConvite);
    });
  });
}
