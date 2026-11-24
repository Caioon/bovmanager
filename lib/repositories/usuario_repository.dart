import 'dart:async';

import 'package:bov_manager/models/usuario_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

/// Chave local com o novo email solicitado (aguardando confirmação do link).
/// Usada para avisar e preencher o login caso a sessão seja encerrada após a
/// confirmação, já que o Firebase não informa o email pendente.
const _kEmailPendente = 'email_pendente';

class UsuarioRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  UsuarioRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

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

    // Login com o email que estava pendente: a troca foi concluída
    final pendente = await obterEmailPendente();
    if (pendente != null &&
        pendente.toLowerCase() == email.trim().toLowerCase()) {
      await _limparEmailPendente();
    }
  }

  // =========================
  // LOGOUT
  // =========================
  Future<void> logout() async {
    // Logout manual: descarta o email pendente para que o login não exiba o
    // aviso de "email alterado" (que só faz sentido em logout forçado).
    await _limparEmailPendente();
    await _auth.signOut();
  }

  // =========================
  // STREAM EM TEMPO REAL (switchMap manual)
  //
  // userChanges emite no login/logout E sempre que o usuário do Firebase muda
  // (email, token, reload()). Diferente de authStateChanges, que só emite em
  // login/logout e por isso não detectava a troca de email.
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
        authSub = _auth.userChanges().listen((firebaseUser) async {
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
                // confirmar o link de troca de email.
                // Usa o currentUser (sempre atual), não o firebaseUser
                // capturado no closure, que pode estar desatualizado.
                final emailAuth = _auth.currentUser?.email;
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

  // =========================
  // RECARREGAR USUÁRIO
  //
  // Busca o estado atual no servidor. Se o email mudou (link confirmado fora
  // do app), o userChanges() emite e a UI atualiza. Se o token foi revogado,
  // faz signOut e o AuthGate redireciona para o login.
  // =========================
  Future<void> recarregarUsuario() async {
    try {
      await _auth.currentUser?.reload();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-token-expired' || e.code == 'user-not-found') {
        await _auth.signOut();
      }
      // Demais erros (ex.: network-request-failed, sem internet) são
      // ignorados: tentaremos de novo na próxima abertura/retomada do app.
    }
  }

  // =========================
  // EMAIL PENDENTE (armazenamento local)
  // =========================
  Future<void> _salvarEmailPendente(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kEmailPendente, email);
  }

  Future<void> _limparEmailPendente() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kEmailPendente);
  }

  Future<String?> obterEmailPendente() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kEmailPendente);
  }

  // ignore: unused_element
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
      await _salvarEmailPendente(novoEmail);
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
