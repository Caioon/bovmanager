import 'package:bov_manager/repositories/usuario_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'firebase_test_setup.dart';

Future<void> _clearAuthEmulator() async {
  await http.delete(
    Uri.parse('http://10.0.2.2:9099/emulator/v1/projects/bovmanager/accounts'),
  );
}

void main() {
  late UsuarioRepository repository;

  // Credenciais base reutilizadas nos grupos que precisam de sessão ativa.
  const email = 'joao@teste.com';
  const senha = 'senha123';
  const nome = 'João Silva';
  const cpf = '123.456.789-00';

  Future<void> _criarELogar({
    String e = email,
    String s = senha,
    String n = nome,
    String c = cpf,
  }) async {
    await repository.criarUsuario(nome: n, email: e, cpf: c, senha: s);
    await repository.login(email: e, senha: s);
  }

  Future<Map<String, dynamic>> _getFirestoreData(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .get();
    return doc.data()!;
  }

  setUpAll(() async {
    await setupFirebaseEmulator();
    repository = UsuarioRepository(
      firestore: FirebaseFirestore.instance,
      auth: FirebaseAuth.instance,
    );
  });

  setUp(() async {
    await FirebaseAuth.instance.signOut();
    await clearFirestoreEmulator();
    await _clearAuthEmulator();
  });

  // ---------------------------------------------------------------------------
  // criarUsuario
  // ---------------------------------------------------------------------------
  group('criarUsuario', () {
    test('cria documento no Firestore com os dados corretos', () async {
      final usuario = await repository.criarUsuario(
        nome: nome,
        email: email,
        cpf: cpf,
        senha: senha,
      );

      final data = await _getFirestoreData(usuario.id);
      expect(data['nome'], nome);
      expect(data['email'], email);
      expect(data['cpf'], cpf);
    });

    test('retorna UsuarioModel com o uid gerado pelo Auth', () async {
      final usuario = await repository.criarUsuario(
        nome: nome,
        email: email,
        cpf: cpf,
        senha: senha,
      );

      expect(usuario.id, isNotEmpty);
      expect(usuario.nome, nome);
      expect(usuario.email, email);
    });

    test('faz logout automaticamente após criar o usuário', () async {
      await repository.criarUsuario(
        nome: nome,
        email: email,
        cpf: cpf,
        senha: senha,
      );

      expect(FirebaseAuth.instance.currentUser, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // login
  // ---------------------------------------------------------------------------
  group('login', () {
    test('autentica o usuário com sucesso', () async {
      await repository.criarUsuario(
        nome: nome,
        email: email,
        cpf: cpf,
        senha: senha,
      );

      await repository.login(email: email, senha: senha);

      expect(FirebaseAuth.instance.currentUser, isNotNull);
      expect(FirebaseAuth.instance.currentUser?.email, email);
    });

    test('lança exceção com credenciais inválidas', () async {
      await expectLater(
        repository.login(email: 'inexistente@teste.com', senha: 'errada'),
        throwsA(isA<FirebaseAuthException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // logout
  // ---------------------------------------------------------------------------
  group('logout', () {
    test('encerra a sessão do usuário autenticado', () async {
      await _criarELogar();
      expect(FirebaseAuth.instance.currentUser, isNotNull);

      await repository.logout();

      expect(FirebaseAuth.instance.currentUser, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // verificarSenha
  // ---------------------------------------------------------------------------
  group('verificarSenha', () {
    test('não lança exceção com a senha correta', () async {
      await _criarELogar();

      await expectLater(repository.verificarSenha(senha), completes);
    });

    test('lança exceção com senha incorreta', () async {
      await _criarELogar();

      await expectLater(
        repository.verificarSenha('senha-errada'),
        throwsA(
          predicate<Exception>((e) => e.toString().contains('Senha incorreta')),
        ),
      );
    });

    test('lança exceção quando não há usuário autenticado', () async {
      await expectLater(
        repository.verificarSenha(senha),
        throwsA(
          predicate<Exception>((e) => e.toString().contains('não autenticado')),
        ),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // atualizarNome
  // ---------------------------------------------------------------------------
  group('atualizarNome', () {
    test('persiste o novo nome no Firestore', () async {
      await _criarELogar();
      final uid = FirebaseAuth.instance.currentUser!.uid;

      await repository.atualizarNome('Maria Souza');

      final data = await _getFirestoreData(uid);
      expect(data['nome'], 'Maria Souza');
    });

    test('não altera outros campos ao mudar o nome', () async {
      await _criarELogar();
      final uid = FirebaseAuth.instance.currentUser!.uid;

      await repository.atualizarNome('Maria Souza');

      final data = await _getFirestoreData(uid);
      expect(data['email'], email);
      expect(data['cpf'], cpf);
    });

    test('lança exceção quando não há usuário autenticado', () async {
      await expectLater(
        repository.atualizarNome('Nome Qualquer'),
        throwsA(
          predicate<Exception>((e) => e.toString().contains('não autenticado')),
        ),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // atualizarCpf
  // ---------------------------------------------------------------------------
  group('atualizarCpf', () {
    test('persiste o novo CPF no Firestore', () async {
      await _criarELogar();
      final uid = FirebaseAuth.instance.currentUser!.uid;

      await repository.atualizarCpf('987.654.321-00');

      final data = await _getFirestoreData(uid);
      expect(data['cpf'], '987.654.321-00');
    });

    test('não altera outros campos ao mudar o CPF', () async {
      await _criarELogar();
      final uid = FirebaseAuth.instance.currentUser!.uid;

      await repository.atualizarCpf('987.654.321-00');

      final data = await _getFirestoreData(uid);
      expect(data['nome'], nome);
      expect(data['email'], email);
    });

    test('lança exceção quando não há usuário autenticado', () async {
      await expectLater(
        repository.atualizarCpf('987.654.321-00'),
        throwsA(
          predicate<Exception>((e) => e.toString().contains('não autenticado')),
        ),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // atualizarSenha
  // ---------------------------------------------------------------------------
  group('atualizarSenha', () {
    test('nova senha permite login após a troca', () async {
      await _criarELogar();

      await repository.atualizarSenha(senha, 'novaSenha456');
      await repository.logout();

      await expectLater(
        repository.login(email: email, senha: 'novaSenha456'),
        completes,
      );
    });

    test('senha antiga é rejeitada após a troca', () async {
      await _criarELogar();

      await repository.atualizarSenha(senha, 'novaSenha456');
      await repository.logout();

      await expectLater(
        repository.login(email: email, senha: senha),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    test('lança exceção quando a senha atual está incorreta', () async {
      await _criarELogar();

      await expectLater(
        repository.atualizarSenha('senha-errada', 'novaSenha456'),
        throwsA(
          predicate<Exception>(
            (e) => e.toString().contains('Senha atual incorreta'),
          ),
        ),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // atualizarEmail
  // ---------------------------------------------------------------------------
  group('atualizarEmail', () {
    test('lança exceção quando o novo email já existe no Firestore', () async {
      // Cria uma segunda conta com o email que será conflitante.
      await repository.criarUsuario(
        nome: 'Outro',
        email: 'outro@teste.com',
        cpf: '000.000.000-00',
        senha: 'senha456',
      );

      await _criarELogar();

      await expectLater(
        repository.atualizarEmail(senha, 'outro@teste.com'),
        throwsA(
          predicate<Exception>(
            (e) => e.toString().contains('já está cadastrado'),
          ),
        ),
      );
    });

    test('envia solicitação de verificação sem lançar exceção', () async {
      await _criarELogar();

      // O emulador aceita verifyBeforeUpdateEmail sem enviar e-mail real.
      // A troca em si só se concretiza após o clique no link de verificação,
      // o que está fora do escopo de testes de integração.
      await expectLater(
        repository.atualizarEmail(senha, 'joao.novo@teste.com'),
        completes,
      );
    });
  });
}
