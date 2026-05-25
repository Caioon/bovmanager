import 'package:bov_manager/models/animal_model.dart';
import 'package:bov_manager/models/historico_animal_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'animal_repository.g.dart';

// =============================================================================
// PROVIDER
// =============================================================================

@riverpod
AnimalRepository animalRepository(Ref ref) {
  return AnimalRepositoryImpl(FirebaseFirestore.instance);
}

// =============================================================================
// INTERFACE
// =============================================================================

abstract class AnimalRepository {
  Stream<List<AnimalModel>> listarPorPropriedade({
    required String propriedadeId,
  });

  Future<void> criarAnimal({
    required String nome,
    required String brinco,
    required String raca,
    required double pesoAtual,
    required DateTime dataNascimento,
    required String rebanhoId,
    required String propriedadeId,
    String? pastoDestinoId,
    String? fotoUrl,
  });

  Future<void> editarAnimal({
    required String animalId,
    required String nome,
    required String brinco,
    required String raca,
    required double pesoAtual,
    String? fotoUrl,
  });

  Future<void> apagarAnimal({required String animalId});

  /// Atualiza pesoAtual do animal e grava histórico de pesagem atomicamente.
  Future<void> registrarPesagem({
    required String animalId,
    required double novoPeso,
    required DateTime data,
  });

  /// Grava histórico de movimentação. O pastoAtual fica no rebanho, não no animal.
  Future<void> registrarMovimentacao({
    required String animalId,
    required String pastoOrigemId,
    required String pastoDestinoId,
    required DateTime data,
  });

  Stream<List<HistoricoAnimalModel>> listarHistorico({
    required String animalId,
  });

  Future<void> adicionarHistorico({
    required String animalId,
    required String tipo,
    required double valor,
    String? pastoOrigemId,
    String? pastoDestinoId,
  });
}

// =============================================================================
// IMPLEMENTAÇÃO FIRESTORE
// =============================================================================

class AnimalRepositoryImpl implements AnimalRepository {
  const AnimalRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('animais');

  CollectionReference<Map<String, dynamic>> _historicoCol(String animalId) =>
      _col.doc(animalId).collection('historico');

  @override
  Stream<List<AnimalModel>> listarPorPropriedade({
    required String propriedadeId,
  }) {
    // AVISO: where + orderBy obriga a indexar os campos buscados via site do firestore ou arquivo de config
    return _col
        .where('propriedadeId', isEqualTo: propriedadeId)
        .orderBy('dataNascimento', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => AnimalModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  @override
  Future<void> criarAnimal({
    required String nome,
    required String brinco,
    required String raca,
    required double pesoAtual,
    required DateTime dataNascimento,
    required String rebanhoId,
    required String propriedadeId,
    String? pastoDestinoId,
    String? fotoUrl,
  }) async {
    // Cria o animal e captura o doc gerado para usar o id no histórico
    final docRef = await _col.add({
      'nome': nome,
      'brinco': brinco,
      'raca': raca,
      'pesoAtual': pesoAtual,
      'dataNascimento': dataNascimento.toIso8601String(),
      'rebanhoId': rebanhoId,
      'propriedadeId': propriedadeId,
      'fotoUrl': fotoUrl,
    });

    // Registra histórico inicial de entrada
    // pastoOrigemId é null pois o animal está sendo cadastrado agora
    await _historicoCol(docRef.id).add({
      'animalId': docRef.id,
      'tipo': 'entrada',
      'valor': pesoAtual,
      'pastoOrigemId': null,
      'pastoDestinoId': pastoDestinoId,
      'data': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> editarAnimal({
    required String animalId,
    required String nome,
    required String brinco,
    required String raca,
    required double pesoAtual,
    String? fotoUrl,
  }) async {
    await _col.doc(animalId).update({
      'nome': nome,
      'brinco': brinco,
      'raca': raca,
      'pesoAtual': pesoAtual,
      'fotoUrl': fotoUrl,
    });
  }

  @override
  Future<void> apagarAnimal({required String animalId}) async {
    // Firestore não deleta subcoleções automaticamente ao deletar o documento pai.
    // É preciso buscar e deletar todos os docs do histórico manualmente antes.
    final historicoDocs = await _historicoCol(animalId).get();

    final batch = _firestore.batch();

    for (final doc in historicoDocs.docs) {
      batch.delete(doc.reference);
    }

    batch.delete(_col.doc(animalId));

    await batch.commit();
  }

  @override
  Future<void> registrarPesagem({
    required String animalId,
    required double novoPeso,
    required DateTime data,
  }) async {
    // Batch garante que atualização do animal e criação do histórico são atômicas
    final batch = _firestore.batch();

    batch.update(_col.doc(animalId), {'pesoAtual': novoPeso});

    final historicoRef = _historicoCol(animalId).doc();
    batch.set(historicoRef, {
      'animalId': animalId,
      'tipo': 'pesagem',
      'valor': novoPeso,
      'pastoOrigemId': null,
      'pastoDestinoId': null,
      'data': data.toIso8601String(),
    });

    await batch.commit();
  }

  @override
  Future<void> registrarMovimentacao({
    required String animalId,
    required String pastoOrigemId,
    required String pastoDestinoId,
    required DateTime data,
  }) async {
    await _historicoCol(animalId).add({
      'animalId': animalId,
      'tipo': 'movimentacao',
      'valor': 0,
      'pastoOrigemId': pastoOrigemId,
      'pastoDestinoId': pastoDestinoId,
      'data': data.toIso8601String(),
    });
  }

  @override
  Stream<List<HistoricoAnimalModel>> listarHistorico({
    required String animalId,
  }) {
    return _historicoCol(animalId)
        .orderBy('data', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => HistoricoAnimalModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  @override
  Future<void> adicionarHistorico({
    required String animalId,
    required String tipo,
    required double valor,
    String? pastoOrigemId,
    String? pastoDestinoId,
  }) async {
    await _historicoCol(animalId).add({
      'animalId': animalId,
      'tipo': tipo,
      'valor': valor,
      'pastoOrigemId': pastoOrigemId,
      'pastoDestinoId': pastoDestinoId,
      'data': DateTime.now().toIso8601String(),
    });
  }
}
