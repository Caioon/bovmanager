import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:bov_manager/repositories/usuario_repository.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late UsuarioRepository repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();

    auth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'user123', email: 'teste@email.com'),
    );

    repository = UsuarioRepository(firestore: firestore, auth: auth);
  });

  group('UsuarioRepository', () {
    test(
      'criarUsuario() deve criar usuário no Firebase Auth e Firestore',
      () async {
        final usuario = await repository.criarUsuario(
          nome: 'João Silva',
          email: 'joao@email.com',
          cpf: '12345678900',
          senha: '123456',
        );

        expect(usuario.nome, 'João Silva');
        expect(usuario.email, 'joao@email.com');
        expect(usuario.cpf, '12345678900');
        expect(usuario.id, isNotEmpty);

        final doc = await firestore
            .collection('usuarios')
            .doc(usuario.id)
            .get();

        expect(doc.exists, true);
      },
    );

    test('login() deve autenticar usuário existente', () async {
      await auth.createUserWithEmailAndPassword(
        email: 'teste@email.com',
        password: '123456',
      );

      await repository.login(email: 'teste@email.com', senha: '123456');

      expect(auth.currentUser, isNotNull);
    });

    test('logout() deve remover usuário autenticado', () async {
      await auth.createUserWithEmailAndPassword(
        email: 'logout@email.com',
        password: '123456',
      );

      await repository.logout();

      expect(auth.currentUser, null);
    });

    test(
      'observarUsuarioAutenticado() deve retornar null sem usuário logado',
      () async {
        final result = await repository.observarUsuarioAutenticado().first;

        expect(result, null);
      },
    );

    test(
      'atualizarNome() deve atualizar nome do usuário autenticado',
      () async {
        await auth.createUserWithEmailAndPassword(
          email: 'nome@email.com',
          password: '123456',
        );

        await firestore.collection('usuarios').doc(auth.currentUser!.uid).set({
          'nome': 'Teste',
          'email': 'nome@email.com',
          'cpf': '12345678900',
        });

        await repository.atualizarNome('Maria');

        final doc = await firestore
            .collection('usuarios')
            .doc(auth.currentUser!.uid)
            .get();

        expect(doc['nome'], 'Maria');
      },
    );

    test('atualizarCpf() deve atualizar cpf do usuário', () async {
      await auth.createUserWithEmailAndPassword(
        email: 'cpf@email.com',
        password: '123456',
      );

      await firestore.collection('usuarios').doc(auth.currentUser!.uid).set({
        'nome': 'Teste',
        'email': 'cpf@email.com',
        'cpf': '12345678900',
      });

      await repository.atualizarCpf('98765432100');

      final doc = await firestore
          .collection('usuarios')
          .doc(auth.currentUser!.uid)
          .get();

      expect(doc['cpf'], '98765432100');
    });

    test('verificarSenha() deve aceitar senha correta', () async {
      await auth.createUserWithEmailAndPassword(
        email: 'senha@email.com',
        password: '123456',
      );

      await expectLater(repository.verificarSenha('123456'), completes);
    });

    test('verificarSenha() deve lançar erro sem usuário autenticado', () async {
      auth = MockFirebaseAuth(signedIn: false);

      repository = UsuarioRepository(firestore: firestore, auth: auth);

      await expectLater(repository.verificarSenha('654321'), throwsException);
    });

    test('atualizarSenha() deve alterar senha do usuário', () async {
      await auth.createUserWithEmailAndPassword(
        email: 'novaSenha@email.com',
        password: '123456',
      );

      await repository.atualizarSenha('123456', '654321');

      await auth.signOut();

      await auth.signInWithEmailAndPassword(
        email: 'novaSenha@email.com',
        password: '654321',
      );

      expect(auth.currentUser, isNotNull);
    });
  });
}
