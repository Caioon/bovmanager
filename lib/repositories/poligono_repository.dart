import 'package:bov_manager/models/poligono_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final poligonoRepositoryProvider = Provider<PoligonoRepository>((ref) {
  return PoligonoRepository(FirebaseFirestore.instance);
});

class PoligonoRepository {
  PoligonoRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _col(String propriedadeId) =>
      _firestore
          .collection('propriedades')
          .doc(propriedadeId)
          .collection('poligonos');


  Stream<List<PoligonoModel>> listarStream(String propriedadeId) {
    return _col(propriedadeId).snapshots().map(
      (snap) => snap.docs
          .map((doc) => PoligonoModel.fromMap(doc.data(), doc.id))
          .toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // Listar todos os polígonos da propriedade (para exibir no mapa)
  // ---------------------------------------------------------------------------
  Future<List<PoligonoModel>> listar(String propriedadeId) async {
    final snap = await _col(propriedadeId).get();
    return snap.docs
        .map((doc) => PoligonoModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Buscar polígono de um pasto específico (pode ser null se não desenhado)
  // ---------------------------------------------------------------------------
  Future<PoligonoModel?> buscarPorPasto({
    required String propriedadeId,
    required String pastoId,
  }) async {
    final snap = await _col(
      propriedadeId,
    ).where('pastoId', isEqualTo: pastoId).limit(1).get();
    if (snap.docs.isEmpty) return null;
    return PoligonoModel.fromMap(snap.docs.first.data(), snap.docs.first.id);
  }

  // ---------------------------------------------------------------------------
  // Salvar — cria ou substitui o polígono do pasto
  // ---------------------------------------------------------------------------
  Future<void> salvar(PoligonoModel poligono) async {
    // Verifica se já existe um polígono para esse pasto
    final existente = await buscarPorPasto(
      propriedadeId: poligono.propriedadeId,
      pastoId: poligono.pastoId,
    );

    if (existente != null) {
      // Atualiza o existente
      await _col(
        poligono.propriedadeId,
      ).doc(existente.id).update(poligono.toMap());
    } else {
      // Cria novo
      await _col(poligono.propriedadeId).add(poligono.toMap());
    }
  }

  // ---------------------------------------------------------------------------
  // Apagar polígono de um pasto
  // ---------------------------------------------------------------------------
  Future<void> apagar({
    required String propriedadeId,
    required String pastoId,
  }) async {
    final existente = await buscarPorPasto(
      propriedadeId: propriedadeId,
      pastoId: pastoId,
    );
    if (existente == null) return;
    await _col(propriedadeId).doc(existente.id).delete();
  }
}
