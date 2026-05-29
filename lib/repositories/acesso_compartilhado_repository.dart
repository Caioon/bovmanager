import 'package:bov_manager/models/acesso_compartilhado_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final acessoCompartilhadoRepositoryProvider =
    Provider<AcessoCompartilhadoRepository>((ref) {
      return AcessoCompartilhadoRepository();
    });

class AcessoCompartilhadoRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // =========================
  // LISTAR ACESSOS DO USUÁRIO
  // =========================
  Future<List<AcessoCompartilhadoModel>> listarPorUsuario(
    String usuarioId,
  ) async {
    final snapshot = await _firestore
        .collection('acessos_compartilhados')
        .where('usuarioId', isEqualTo: usuarioId)
        .get();

    return snapshot.docs
        .map((doc) => AcessoCompartilhadoModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // =========================
  // BUSCAR ID DO USUÁRIO PELO EMAIL
  // Retorna null se não encontrado.
  // =========================
  Future<String?> buscarUsuarioIdPorEmail(String email) async {
    final snapshot = await _firestore
        .collection('usuarios')
        .where('email', isEqualTo: email.trim().toLowerCase())
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return snapshot.docs.first.id;
  }

  // =========================
  // CRIAR ACESSO
  // Verifica duplicata antes de inserir.
  // =========================
  Future<void> criar({
    required String propriedadeId,
    required String usuarioId,
    required String papel,
  }) async {
    final query = await _firestore
        .collection('acessos_compartilhados')
        .where('usuarioId', isEqualTo: usuarioId)
        .where('propriedadeId', isEqualTo: propriedadeId)
        .limit(1)
        .get();

    // Se já existe, não cria novamente
    if (query.docs.isNotEmpty) return;

    final acesso = AcessoCompartilhadoModel(
      id: '',
      propriedadeId: propriedadeId,
      usuarioId: usuarioId,
      papel: papel,
      dataConvite: DateTime.now(),
    );

    await _firestore.collection('acessos_compartilhados').add(acesso.toMap());
  }
}
