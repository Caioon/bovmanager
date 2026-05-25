import 'package:bov_manager/models/usuario_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'usuario_repository.g.dart';

// Novo provider — fonte da verdade do usuário autenticado
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
    // Cria usuário no Firebase Auth
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: senha,
    );

    final uid = credential.user!.uid;

    // Cria model
    final usuario = UsuarioModel(id: uid, nome: nome, email: email, cpf: cpf);

    // Salva dados adicionais no Firestore
    await _firestore.collection('usuarios').doc(uid).set(usuario.toMap());

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
  // WATCHER QUE REAGE AO ESTADO DO USUARIO (LOGIN, LOGOUT)
  // =========================
  Stream<UsuarioModel?> observarUsuarioAutenticado() {
    //authStateChanges é uma stream.
    //asyncMap faz uma operação sobre os itens que é retornado por essa stream ao longo do tempo
    //signInWithEmail retorna um JWT que é salvo localmente (contem uid do usuario)
    //authStateChanges detecta isso, busca os dados do usuario com uid no firestore online e retorna
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return await _buscarPorId(firebaseUser.uid);
    });
  }

  // Método privado reutilizável
  //_buscarPorId faz uma busca no próprio servidor da firestore usando o uid
  Future<UsuarioModel?> _buscarPorId(String uid) async {
    final doc = await _firestore.collection('usuarios').doc(uid).get();
    if (!doc.exists) return null;
    return UsuarioModel.fromMap(doc.data()!, doc.id);
  }
}
