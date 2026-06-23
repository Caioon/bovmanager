import 'package:flutter_test/flutter_test.dart';
import 'package:bov_manager/models/usuario_model.dart';

void main() {
  group('UsuarioModel', () {
    final usuario = UsuarioModel(
      id: 'usuario123',
      nome: 'João Silva',
      email: 'joao@email.com',
      cpf: '12345678900',
    );

    test('toMap() deve converter todos os campos corretamente', () {
      final map = usuario.toMap();

      expect(map['nome'], 'João Silva');
      expect(map['email'], 'joao@email.com');
      expect(map['cpf'], '12345678900');
    });

    test('UsuarioModel.fromMap() deve criar objeto corretamente', () {
      final map = {
        'nome': 'João Silva',
        'email': 'joao@email.com',
        'cpf': '12345678900',
      };

      final result = UsuarioModel.fromMap(map, 'usuario123');

      expect(result.id, 'usuario123');
      expect(result.nome, 'João Silva');
      expect(result.email, 'joao@email.com');
      expect(result.cpf, '12345678900');
    });

    test('Round-trip toMap() → fromMap() deve manter todos os valores', () {
      final map = usuario.toMap();

      final result = UsuarioModel.fromMap(
        map,
        usuario.id,
      );

      expect(result.id, usuario.id);
      expect(result.nome, usuario.nome);
      expect(result.email, usuario.email);
      expect(result.cpf, usuario.cpf);
    });

    test('fromMap() com campos ausentes deve usar valores padrão', () {
      final map = <String, dynamic>{};

      final result = UsuarioModel.fromMap(map, 'usuario123');

      expect(result.id, 'usuario123');
      expect(result.nome, '');
      expect(result.email, '');
      expect(result.cpf, '');
    });

    test('copyWith() deve atualizar somente os campos informados', () {
      final result = usuario.copyWith(
        nome: 'Maria Silva',
        email: 'maria@email.com',
      );

      expect(result.id, usuario.id);
      expect(result.nome, 'Maria Silva');
      expect(result.email, 'maria@email.com');
      expect(result.cpf, usuario.cpf);
    });

    test('copyWith() sem parâmetros deve manter todos os valores', () {
      final result = usuario.copyWith();

      expect(result.id, usuario.id);
      expect(result.nome, usuario.nome);
      expect(result.email, usuario.email);
      expect(result.cpf, usuario.cpf);
    });
  });
}
