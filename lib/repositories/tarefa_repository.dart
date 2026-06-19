import 'package:bov_manager/models/tarefa_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tarefa_repository.g.dart';

@riverpod
TarefaRepository tarefaRepository(Ref ref) {
  return TarefaRepository(firestore: FirebaseFirestore.instance);
}

class TarefaRepository {
  TarefaRepository({required this.firestore});

  final FirebaseFirestore firestore;

  CollectionReference<Map<String, dynamic>> _col(String propriedadeId) =>
      firestore
          .collection('propriedades')
          .doc(propriedadeId)
          .collection('tarefas');

  Stream<List<TarefaModel>> listar(String propriedadeId) {
    return _col(propriedadeId)
        .orderBy('dataExecucao')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => TarefaModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Cria a tarefa no Firestore e retorna o ID gerado pelo banco.
  Future<String> criar(TarefaModel tarefa) async {
    final ref = await _col(tarefa.propriedadeId).add(tarefa.toMap());
    return ref.id;
  }

  Future<void> atualizarStatus({
    required String propriedadeId,
    required String tarefaId,
    required StatusTarefa status,
  }) async {
    await _col(propriedadeId).doc(tarefaId).update({'status': status.name});
  }

  Future<void> atualizarData({
    required String propriedadeId,
    required String tarefaId,
    required DateTime novaData,
    int? horaExecucaoMinutos,
    bool clearHora = false,
  }) async {
    await _col(propriedadeId).doc(tarefaId).update({
      'dataExecucao': novaData.toIso8601String(),
      // Salva null explicitamente quando o usuário remove o horário
      'horaExecucaoMinutos': clearHora ? null : horaExecucaoMinutos,
    });
  }

  Future<void> atualizar({
    required String propriedadeId,
    required String tarefaId,
    required String titulo,
    required String descricao,
    required DateTime dataExecucao,
    int? horaExecucaoMinutos,
    bool clearHora = false,
  }) async {
    await _col(propriedadeId).doc(tarefaId).update({
      'titulo': titulo,
      'descricao': descricao,
      'dataExecucao': dataExecucao.toIso8601String(),
      // Salva null explicitamente quando o usuário remove o horário
      'horaExecucaoMinutos': clearHora ? null : horaExecucaoMinutos,
    });
  }

  Future<void> apagar({
    required String propriedadeId,
    required String tarefaId,
  }) async {
    await _col(propriedadeId).doc(tarefaId).delete();
  }
}
