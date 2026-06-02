import 'package:bov_manager/models/propriedade_model.dart';
import 'package:bov_manager/repositories/usuario_repository.dart';
import 'package:bov_manager/services/acesso_compartilhado_service.dart';
import 'package:bov_manager/services/propriedade_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'propriedade_viewmodel.g.dart';

// =============================================================================
// LISTA DE PROPRIEDADES (próprias + compartilhadas)
// =============================================================================
//
// Combina duas fontes:
//   1. Stream das propriedades onde o usuário é proprietário
//   2. Busca pontual das propriedades compartilhadas com o usuário via acessos
//
// Como o Stream das próprias emite a cada mudança no Firestore, usamos
// asyncMap para reagir a cada emissão e buscar as compartilhadas junto.
//
@riverpod
Stream<List<PropriedadeModel>> propriedadesLista(Ref ref) {
  final uid = ref.watch(usuarioAtualProvider.select((s) => s.value?.id));
  if (uid == null) return const Stream.empty();

  final propriedadeService = ref.read(propriedadeServiceProvider);
  final acessoService = ref.read(acessoCompartilhadoServiceProvider);

  // Parte 1: stream das propriedades próprias.
  // A cada emissão, buscamos também as compartilhadas e combinamos.
  return propriedadeService.listar(uid).asyncMap((proprias) async {
    // Parte 2: IDs das propriedades compartilhadas com este usuário
    final idsCompartilhadas = await acessoService
        .listarPropriedadeIdsCompartilhadas(uid);

    // Busca os modelos de cada propriedade compartilhada em paralelo,
    // ignorando IDs que o usuário já seja dono (evita duplicatas)
    final idsProprias = proprias.map((p) => p.id).toSet();

    final compartilhadasFutures = idsCompartilhadas
        .where((id) => !idsProprias.contains(id))
        .map((id) => propriedadeService.buscarPorId(propriedadeId: id));

    final compartilhadasResults = await Future.wait(compartilhadasFutures);

    final compartilhadas = compartilhadasResults
        .whereType<PropriedadeModel>()
        .toList();

    // Próprias primeiro, depois as compartilhadas
    return [...proprias, ...compartilhadas];
  });
}

// Propriedade ativa do app (dashboard, header, etc.)
// keepAlive necessário pois o provider assiste propriedadesListaProvider,
// que ao transitar de AsyncLoading para AsyncData destrói e recria este provider,
// zerando o stateOrNull e perdendo a propriedade selecionada.

@Riverpod(keepAlive: true)
class PropriedadeSelecionada extends _$PropriedadeSelecionada {
  PropriedadeModel? _selecionada;

  @override
  AsyncValue<PropriedadeModel?> build() {
    final listaAsync = ref.watch(propriedadesListaProvider);

    return listaAsync.when(
      data: (lista) {
        if (lista.isEmpty) return const AsyncData(null);

        if (_selecionada != null) {
          final encontrada = lista
              .where((p) => p.id == _selecionada!.id)
              .firstOrNull;
          if (encontrada != null) return AsyncData(encontrada);
        }

        _selecionada = lista.first;
        return AsyncData(lista.first);
      },
      loading: () => const AsyncLoading(),
      error: (e, st) => AsyncError(e, st),
    );
  }

  void selecionar(PropriedadeModel propriedade) {
    _selecionada = propriedade;
    state = AsyncData(propriedade);
  }

  void limpar() {
    _selecionada = null;
    state = const AsyncData(null);
  }
}

// Propriedade em visualização na tela de detalhes
@Riverpod(keepAlive: true)
class PropriedadeEmVisualizacao extends _$PropriedadeEmVisualizacao {
  @override
  PropriedadeModel? build() => null;

  void abrir(PropriedadeModel propriedade) => state = propriedade;
  void fechar() => state = null;
}

@riverpod
class PropriedadesViewModel extends _$PropriedadesViewModel {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  String get _uid => ref.read(usuarioAtualProvider).requireValue!.id;

  PropriedadeService get _service => ref.read(propriedadeServiceProvider);

  // =========================
  // CRIAR
  // =========================

  Future<void> criar({required String nome}) async {
    state = const AsyncLoading();

    try {
      await _service.criar(nome: nome, proprietarioId: _uid);

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // =========================
  // EDITAR
  // =========================

  Future<void> editar({
    required String propriedadeId,
    required String nome,
  }) async {
    state = const AsyncLoading();

    try {
      //Comita as mudanças pro banco
      await _service.editar(propriedadeId: propriedadeId, nome: nome);

      final selecionada = ref.read(propriedadeSelecionadaProvider).value;

      //Verifica se a propriedade alterada é a mesma do id passado
      //Se for, atualiza essa propriedade (que é local, ou seja: não faço uma busca no banco)
      //Atualiza passando um novo PropriedadeModel para preservar o princípio de imutabilidade do riverpod
      //No caso, o stream na linha 8 ja atualizaria automaticamente, nao preciso fazer uma busca manual no banco
      //Mas fazer a atualização local dessa forma é uma atualização mais rápida.
      if (selecionada?.id == propriedadeId) {
        ref
            .read(propriedadeSelecionadaProvider.notifier)
            .selecionar(
              PropriedadeModel(
                id: selecionada!.id,
                nome: nome,
                proprietarioId: selecionada.proprietarioId,
                dataCadastro: selecionada.dataCadastro,
              ),
            );
      }

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // =========================
  // APAGAR
  // =========================

  Future<void> apagar({required String propriedadeId}) async {
    state = const AsyncLoading();

    try {
      await _service.apagar(propriedadeId: propriedadeId);

      final selecionada = ref.read(propriedadeSelecionadaProvider).value;

      if (selecionada?.id == propriedadeId) {
        ref.read(propriedadeSelecionadaProvider.notifier).limpar();
      }

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
