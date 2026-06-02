import 'package:bov_manager/models/pasto_model.dart';
import 'package:bov_manager/repositories/pasto_repository.dart';
import 'package:bov_manager/services/pasto_service.dart';
import 'package:bov_manager/viewmodels/propriedade_viewmodel.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pasto_viewmodel.g.dart';

@riverpod
Future<List<PastoModel>> pastosListaPropSelecionada(Ref ref) async {
  final propriedadeId = ref.watch(propriedadeSelecionadaProvider).value?.id;
  if (propriedadeId == null) return [];
  return ref.read(pastoServiceProvider).listar(propriedadeId);
}

//TODO: PAREI AQUI
//o claude bugou
//o problema a ser resolvido era: a tela de pastos nao atualiza ao apagar
//o problema é justamente por ser um future, e nao um stream
//ele tinha mandado o código pra corrigir e tinha falado pra remover o ref.invalidate
//perguntei se era pra apagar os 3, bugou a conversa, e agora nao tenho mais acesso ao trecho final do prompt
//tenho que tentar denovo
@riverpod
Future<List<PastoModel>> pastosListaPropEmVisualizacao(Ref ref) async {
  final propriedadeId = ref.watch(propriedadeEmVisualizacaoProvider)?.id;
  if (propriedadeId == null) return [];
  return ref.read(pastoServiceProvider).listar(propriedadeId);
}

@riverpod
Stream<List<PastoModel>> pastosSelecionados(Ref ref) {
  final propriedadeId = ref.watch(propriedadeSelecionadaProvider).value?.id;
  if (propriedadeId == null) return const Stream.empty();
  return ref.watch(pastoRepositoryProvider).listarStream(propriedadeId);
}

@Riverpod(keepAlive: true)
class PastoEmVisualizacao extends _$PastoEmVisualizacao {
  @override
  PastoModel? build() => null;

  void abrir(PastoModel pasto) => state = pasto;
  void fechar() => state = null;
}

@riverpod
class PastosViewModel extends _$PastosViewModel {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  String get _propriedadeId =>
      ref.read(propriedadeEmVisualizacaoProvider)?.id ?? '';

  PastoService get _service => ref.read(pastoServiceProvider);

  Future<void> criar({
    required String nome,
    required double area,
    required String descricao,
    int? limiteAnimais,
    String? propriedadeIdOverride,
  }) async {
    final id = propriedadeIdOverride ?? _propriedadeId;
    state = const AsyncLoading();
    try {
      await _service.criar(
        nome: nome,
        propriedadeId: id,
        area: area,
        descricao: descricao,
        limiteAnimais: limiteAnimais,
      );
      ref.invalidate(pastosListaPropEmVisualizacaoProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> editar({
    required String pastoId,
    required String nome,
    required double area,
    required String descricao,
    int? limiteAnimais,
  }) async {
    state = const AsyncLoading();
    try {
      await _service.editar(
        id: pastoId,
        nome: nome,
        propriedadeId: _propriedadeId,
        area: area,
        descricao: descricao,
        limiteAnimais: limiteAnimais,
      );
      ref.invalidate(pastosListaPropEmVisualizacaoProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> apagar({required String pastoId}) async {
    state = const AsyncLoading();
    try {
      await _service.apagar(
        propriedadeId: _propriedadeId,
        pastoId: pastoId,
      );
      ref.invalidate(pastosListaPropEmVisualizacaoProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
