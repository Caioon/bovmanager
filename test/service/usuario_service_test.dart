import 'package:bov_manager/repositories/usuario_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bov_manager/models/usuario_model.dart';
import 'package:bov_manager/services/usuario_service.dart';

class MockUsuarioRepository extends UsuarioRepository {
  MockUsuarioRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : super(firestore: firestore, auth: auth);

  bool criou = false;
  bool logou = false;
  bool deslogou = false;
  bool verificouSenha = false;
  bool atualizouNome = false;
  bool atualizouEmail = false;
  bool atualizouCpf = false;
  bool atualizouSenha = false;

  @override
  Future<UsuarioModel> criarUsuario({
    required String nome,
    required String email,
    required String cpf,
    required String senha,
  }) async {
    criou = true;

    return UsuarioModel(id: 'usuario123', nome: nome, email: email, cpf: cpf);
  }

  @override
  Future<void> login({required String email, required String senha}) async {
    logou = true;
  }

  @override
  Future<void> logout() async {
    deslogou = true;
  }

  @override
  Future<void> verificarSenha(String senha) async {
    verificouSenha = true;
  }

  @override
  Future<void> atualizarNome(String novoNome) async {
    atualizouNome = true;
  }

  @override
  Future<void> atualizarEmail(String senhaAtual, String novoEmail) async {
    atualizouEmail = true;
  }

  @override
  Future<void> atualizarCpf(String novoCpf) async {
    atualizouCpf = true;
  }

  @override
  Future<void> atualizarSenha(String senhaAtual, String novaSenha) async {
    atualizouSenha = true;
  }
}

void main() {
  group('UsuarioService', () {
    late MockUsuarioRepository repository;
    late UsuarioService service;

    setUp(() {
      repository = MockUsuarioRepository(
        firestore: FakeFirebaseFirestore(),
        auth: MockFirebaseAuth(),
      );

      service = UsuarioService(repository as dynamic);
    });

    test('criarUsuario() deve criar usuário corretamente', () async {
      final usuario = await service.criarUsuario(
        nome: 'João',
        email: 'joao@email.com',
        cpf: '12345678900',
        senha: '123456',
      );

      expect(repository.criou, true);
      expect(usuario.id, 'usuario123');
      expect(usuario.nome, 'João');
      expect(usuario.email, 'joao@email.com');
      expect(usuario.cpf, '12345678900');
    });

    test('login() deve chamar autenticação do repositório', () async {
      await service.login(email: 'teste@email.com', senha: '123456');

      expect(repository.logou, true);
    });

    test('logout() deve chamar logout do repositório', () async {
      await service.logout();

      expect(repository.deslogou, true);
    });

    test('verificarSenha() deve validar senha pelo repositório', () async {
      await service.verificarSenha('123456');

      expect(repository.verificouSenha, true);
    });

    test('atualizarNome() deve atualizar nome', () async {
      await service.atualizarNome('Novo Nome');

      expect(repository.atualizouNome, true);
    });

    test('atualizarEmail() deve atualizar email', () async {
      await service.atualizarEmail('senhaAtual', 'novo@email.com');

      expect(repository.atualizouEmail, true);
    });

    test('atualizarCpf() deve atualizar CPF', () async {
      await service.atualizarCpf('99999999999');

      expect(repository.atualizouCpf, true);
    });

    test('atualizarSenha() deve atualizar senha', () async {
      await service.atualizarSenha('senhaAtual', 'novaSenha');

      expect(repository.atualizouSenha, true);
    });
  });
}
