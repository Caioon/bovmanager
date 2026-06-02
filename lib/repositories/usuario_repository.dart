import 'dart:async';

import 'package:bov_manager/models/usuario_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'usuario_repository.g.dart';

@riverpod
Stream<UsuarioModel?> usuarioAtual(Ref ref) {
  final repository = ref.watch(usuarioRepositoryProvider);
  return repository.observarUsuarioAutenticado();
}

@riverpod
UsuarioRepository usuarioRepository(Ref ref) {
  return UsuarioRepository();
}

class UsuarioRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // =========================
  // CRIAR USUÁRIO
  // =========================
  Future<UsuarioModel> criarUsuario({
    required String nome,
    required String email,
    required String cpf,
    required String senha,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: senha,
    );

    final uid = credential.user!.uid;
    final usuario = UsuarioModel(id: uid, nome: nome, email: email, cpf: cpf);
    await _firestore.collection('usuarios').doc(uid).set(usuario.toMap());

    await _auth.signOut(); 

    return usuario;
  }

  // =========================
  // LOGIN
  // =========================
  Future<void> login({required String email, required String senha}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: senha);
  }

  // =========================
  // LOGOUT
  // =========================
  Future<void> logout() async {
    await _auth.signOut();
  }

  // =========================
  // STREAM EM TEMPO REAL (switchMap manual)
  //
  // authStateChanges emite sempre que o estado de auth muda (login/logout).
  // Para cada usuário logado, abrimos um listener no documento do Firestore
  // (.snapshots()), que reage em tempo real a qualquer alteração de campos.
  //
  // O problema de usar asyncExpand aqui é que ele é um concatMap: espera o
  // stream interno completar antes de processar o próximo evento externo.
  // Como .snapshots() nunca completa, o evento de logout ficaria preso na fila
  // para sempre e o AuthGate jamais redirecionaria para o login.
  //
  // A solução é o padrão switchMap: ao receber um novo evento de auth,
  // cancelamos imediatamente o listener do Firestore anterior antes de abrir
  // o próximo — garantindo que null chegue ao AuthGate no logout.
  // =========================
  Stream<UsuarioModel?> observarUsuarioAutenticado() {
    late StreamController<UsuarioModel?> controller;
    StreamSubscription? authSub;
    StreamSubscription? firestoreSub;

    controller = StreamController<UsuarioModel?>(
      onListen: () {
        authSub = _auth.authStateChanges().listen((firebaseUser) async {
          // Cancela o listener do Firestore do usuário anterior
          await firestoreSub?.cancel();
          firestoreSub = null;

          if (firebaseUser == null) {
            controller.add(null);
            return;
          }

          firestoreSub = _firestore
              .collection('usuarios')
              .doc(firebaseUser.uid)
              .snapshots()
              .asyncMap((doc) async {
                if (!doc.exists) return null;

                final usuario = UsuarioModel.fromMap(doc.data()!, doc.id);

                // Sincroniza email do Auth → Firestore após o usuário
                // confirmar o link de troca de email
                final emailAuth = firebaseUser.email;
                if (emailAuth != null && emailAuth != usuario.email) {
                  await _firestore
                      .collection('usuarios')
                      .doc(firebaseUser.uid)
                      .update({'email': emailAuth});
                  return usuario.copyWith(email: emailAuth);
                }

                return usuario;
              })
              .listen(controller.add, onError: controller.addError);
        });
      },
      onCancel: () async {
        await firestoreSub?.cancel();
        await authSub?.cancel();
      },
    );

    return controller.stream;
  }

  Future<UsuarioModel?> _buscarPorId(String uid) async {
    final doc = await _firestore.collection('usuarios').doc(uid).get();
    if (!doc.exists) return null;
    return UsuarioModel.fromMap(doc.data()!, doc.id);
  }

  // =========================
  // VERIFICAR SENHA (portão de segurança antes de editar dados)
  // =========================
  Future<void> verificarSenha(String senha) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuário não autenticado.');

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: senha,
      );
      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          throw Exception('Senha incorreta.');
        default:
          throw Exception('Erro ao verificar senha: ${e.message}');
      }
    }
  }

  // =========================
  // ATUALIZAR NOME
  // =========================
  Future<void> atualizarNome(String novoNome) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Usuário não autenticado.');

    await _firestore.collection('usuarios').doc(uid).update({'nome': novoNome});
  }

  // =========================
  // ATUALIZAR EMAIL
  // =========================
  Future<void> atualizarEmail(String senhaAtual, String novoEmail) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuário não autenticado.');

      // Verifica duplicidade no Firestore antes de prosseguir.
      // Nota: não cobre contas criadas no Auth mas não sincronizadas no Firestore.
      final existing = await _firestore
          .collection('usuarios')
          .where('email', isEqualTo: novoEmail)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        throw Exception('Este email já está cadastrado em outra conta.');
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: senhaAtual,
      );
      await user.reauthenticateWithCredential(credential);
      await user.verifyBeforeUpdateEmail(novoEmail);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('Este email já está cadastrado em outra conta.');
        case 'wrong-password':
        case 'invalid-credential':
          throw Exception('Senha incorreta.');
        case 'invalid-email':
          throw Exception('Email inválido.');
        default:
          throw Exception('Erro ao atualizar email: ${e.message}');
      }
    }
  }

  // =========================
  // ATUALIZAR CPF
  // =========================
  Future<void> atualizarCpf(String novoCpf) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Usuário não autenticado.');

    await _firestore.collection('usuarios').doc(uid).update({'cpf': novoCpf});
  }

  // =========================
  // ATUALIZAR SENHA
  // =========================
  Future<void> atualizarSenha(String senhaAtual, String novaSenha) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuário não autenticado.');

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: senhaAtual,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(novaSenha);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          throw Exception('Senha atual incorreta.');
        case 'weak-password':
          throw Exception(
            'A nova senha é muito fraca. Use pelo menos 6 caracteres.',
          );
        default:
          throw Exception('Erro ao atualizar senha: ${e.message}');
      }
    }
  }
}
