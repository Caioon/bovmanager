import 'package:bov_manager/models/animal_model.dart';
import 'package:bov_manager/models/pasto_model.dart';
import 'package:bov_manager/models/propriedade_model.dart';
import 'package:bov_manager/models/rebanho_model.dart';
import 'package:bov_manager/models/tarefa_model.dart';

/// Fotografia dos dados de uma propriedade no instante da geração.
/// Não grava cópias no Firebase nem altera os registros existentes.
class RelatorioDados {
  const RelatorioDados({
    required this.propriedade,
    required this.pastos,
    required this.rebanhos,
    required this.animais,
    required this.tarefas,
    required this.geradoEm,
  });

  final PropriedadeModel propriedade;
  final List<PastoModel> pastos;
  final List<RebanhoModel> rebanhos;
  final List<AnimalModel> animais;
  final List<TarefaModel> tarefas;
  final DateTime geradoEm;

  int get totalPastos => pastos.length;
  int get totalRebanhos => rebanhos.length;
  int get totalAnimais => animais.length;
  int get totalTarefas => tarefas.length;
  int get tarefasConcluidas =>
      tarefas.where((t) => t.status == StatusTarefa.concluida).length;
  int get tarefasPendentes => totalTarefas - tarefasConcluidas;
  double? get pesoMedio => animais.isEmpty
      ? null
      : animais.fold<double>(0, (soma, a) => soma + a.pesoAtual) /
          animais.length;

  String nomePasto(String id) {
    for (final pasto in pastos) {
      if (pasto.id == id) return pasto.nome;
    }
    return 'Não informado';
  }
}
