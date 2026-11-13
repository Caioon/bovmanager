import 'dart:math' as math;

import 'package:bov_manager/core/theme/app_colors.dart';
import 'package:bov_manager/core/widgets/bov_widgets.dart';
import 'package:bov_manager/models/animal_model.dart';
import 'package:bov_manager/models/historico_animal_model.dart';
import 'package:bov_manager/models/pasto_model.dart';
import 'package:bov_manager/models/poligono_model.dart';
import 'package:bov_manager/models/propriedade_model.dart';
import 'package:bov_manager/models/rebanho_model.dart';
import 'package:bov_manager/models/tarefa_model.dart';
import 'package:bov_manager/repositories/historico_animal_repository.dart';
import 'package:bov_manager/repositories/poligono_repository.dart';
import 'package:bov_manager/repositories/tarefa_repository.dart';
import 'package:bov_manager/repositories/usuario_repository.dart';
import 'package:bov_manager/services/animal_service.dart';
import 'package:bov_manager/services/pasto_service.dart';
import 'package:bov_manager/services/rebanho_service.dart';
import 'package:bov_manager/services/tarefa_service.dart';
import 'package:bov_manager/viewmodels/animal_viewmodel.dart';
import 'package:bov_manager/viewmodels/pasto_viewmodel.dart';
import 'package:bov_manager/viewmodels/propriedade_viewmodel.dart';
import 'package:bov_manager/viewmodels/rebanho_viewmodel.dart';
import 'package:bov_manager/viewmodels/tarefa_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// =============================================================================
// TELA RAIZ
// =============================================================================

class TesteDelecaoScreen extends ConsumerStatefulWidget {
  const TesteDelecaoScreen({super.key});

  @override
  ConsumerState<TesteDelecaoScreen> createState() => _TesteDelecaoScreenState();
}

class _TesteDelecaoScreenState extends ConsumerState<TesteDelecaoScreen> {
  @override
  void initState() {
    super.initState();
    // Sincroniza propriedadeEmVisualizacaoProvider com o valor já selecionado
    // em propriedadeSelecionadaProvider ao entrar na tela, sem depender do
    // onChanged do dropdown (que só dispara se o usuário trocar manualmente).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final selecionada = ref.read(propriedadeSelecionadaProvider).value;
      if (selecionada != null) {
        ref.read(propriedadeEmVisualizacaoProvider.notifier).abrir(selecionada);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final propriedadesAsync = ref.watch(propriedadesListaProvider);
    final propriedadeSelecionada = ref
        .watch(propriedadeSelecionadaProvider)
        .value;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.text,
                      size: 20,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Text(
                    'Tela de Testes',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
            ),

            // ── Seletor de propriedade ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PROPRIEDADE ATIVA',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                      color: AppColors.text4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  propriedadesAsync.when(
                    loading: () => const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.accent,
                      ),
                    ),
                    error: (e, _) => Text(
                      'Erro ao carregar propriedades: $e',
                      style: const TextStyle(
                        color: AppColors.red,
                        fontFamily: 'DM Sans',
                        fontSize: 13,
                      ),
                    ),
                    data: (lista) {
                      if (lista.isEmpty) {
                        return const Text(
                          'Nenhuma propriedade encontrada.',
                          style: TextStyle(
                            color: AppColors.text4,
                            fontFamily: 'DM Sans',
                            fontSize: 13,
                          ),
                        );
                      }
                      final valorAtual = lista
                          .where((p) => p.id == propriedadeSelecionada?.id)
                          .firstOrNull;

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<PropriedadeModel>(
                            value: valorAtual,
                            isExpanded: true,
                            dropdownColor: AppColors.card,
                            style: const TextStyle(
                              color: AppColors.text,
                              fontFamily: 'DM Sans',
                              fontSize: 15,
                            ),
                            hint: const Text(
                              'Selecione uma propriedade',
                              style: TextStyle(
                                color: AppColors.text4,
                                fontFamily: 'DM Sans',
                                fontSize: 15,
                              ),
                            ),
                            items: lista
                                .map(
                                  (p) => DropdownMenuItem(
                                    value: p,
                                    child: Text(p.nome),
                                  ),
                                )
                                .toList(),
                            onChanged: (p) {
                              if (p == null) return;
                              ref
                                  .read(propriedadeSelecionadaProvider.notifier)
                                  .selecionar(p);
                              ref
                                  .read(
                                    propriedadeEmVisualizacaoProvider.notifier,
                                  )
                                  .abrir(p);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            const Divider(color: AppColors.border, height: 1),

            // ── Seções ───────────────────────────────────────────────────────
            Expanded(
              child: propriedadeSelecionada == null
                  ? const Center(
                      child: Text(
                        'Selecione uma propriedade para continuar.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.text4,
                          fontFamily: 'DM Sans',
                          fontSize: 14,
                        ),
                      ),
                    )
                  : ListView(
                      children: [
                        _SectionRebanhos(propriedade: propriedadeSelecionada),
                        const Divider(color: AppColors.border, height: 1),
                        _SectionPastos(propriedade: propriedadeSelecionada),
                        const Divider(color: AppColors.border, height: 1),
                        _SectionAnimais(propriedade: propriedadeSelecionada),
                        const Divider(color: AppColors.border, height: 1),
                        _SectionTarefas(propriedade: propriedadeSelecionada),
                        const SizedBox(height: 24),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// SHARED — Section Header
// =============================================================================

class _SectionHeader extends StatelessWidget {
  final String titulo;
  final bool expanded;
  final VoidCallback onToggle;

  /// Widget opcional exibido à direita do título (ex: spinner ou botão +).
  final Widget? trailing;

  const _SectionHeader({
    required this.titulo,
    required this.expanded,
    required this.onToggle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 4, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              titulo.toUpperCase(),
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: AppColors.text4,
              ),
            ),
          ),
          ?trailing,
          IconButton(
            icon: Icon(
              expanded ? Icons.expand_less : Icons.expand_more,
              color: AppColors.text4,
              size: 20,
            ),
            onPressed: onToggle,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SECTION: REBANHOS
// =============================================================================

class _SectionRebanhos extends ConsumerStatefulWidget {
  final PropriedadeModel propriedade;
  const _SectionRebanhos({required this.propriedade});

  @override
  ConsumerState<_SectionRebanhos> createState() => _SectionRebanhosState();
}

class _SectionRebanhosState extends ConsumerState<_SectionRebanhos> {
  bool _expanded = true;
  bool _isLoading = false;

  /// Cache de futures de contagem de animais por rebanhoId.
  /// Invalidado após +25 ou exclusão para forçar recálculo.
  final Map<String, Future<int>> _countCache = {};

  PropriedadeModel get _prop => widget.propriedade;

  // ── Feedback helpers ──────────────────────────────────────────────────────

  Future<bool> _confirm(String title, String body) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.text,
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          body,
          style: const TextStyle(color: AppColors.text4, fontFamily: 'DM Sans'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.text4, fontFamily: 'DM Sans'),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Confirmar',
              style: TextStyle(
                color: AppColors.red,
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    return result == true;
  }

  // ── Contagem de animais no rebanho ────────────────────────────────────────
  //
  // Para cada animal da propriedade, busca a última movimentação e verifica
  // se rebanhoDestinoId aponta para este rebanho.

  Future<int> _computeCountNoRebanho(String rebanhoId) async {
    final animais = await ref
        .read(animalServiceProvider)
        .listar(_prop.id)
        .first;
    final historicoRepo = ref.read(historicoAnimalRepositoryProvider);
    int count = 0;
    for (final animal in animais) {
      final ultima = await historicoRepo.buscarUltimaMovimentacao(
        animalId: animal.id,
      );
      if (ultima?.rebanhoDestinoId == rebanhoId) count++;
    }
    return count;
  }

  Future<int> _getCountFuture(String rebanhoId) => _countCache.putIfAbsent(
    rebanhoId,
    () => _computeCountNoRebanho(rebanhoId),
  );

  void _invalidateCount(String rebanhoId) => _countCache.remove(rebanhoId);

  // ── Criar rebanho ─────────────────────────────────────────────────────────

  Future<void> _criarRebanho(
    List<RebanhoModel> rebanhos,
    List<PastoModel> pastos,
  ) async {
    if (pastos.isEmpty) {
      showBovErrorSnackBar(
        context,
        'Crie um pasto antes de adicionar um rebanho.',
      );
      return;
    }

    // Modal de seleção de pasto
    final PastoModel? pastoEscolhido = await showDialog<PastoModel>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          'Escolher Pasto',
          style: TextStyle(
            color: AppColors.text,
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: pastos.length,
            itemBuilder: (_, i) {
              final p = pastos[i];
              return ListTile(
                title: Text(
                  p.nome,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontFamily: 'DM Sans',
                  ),
                ),
                onTap: () => Navigator.of(ctx).pop(p),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.text4, fontFamily: 'DM Sans'),
            ),
          ),
        ],
      ),
    );

    if (pastoEscolhido == null || !mounted) return;

    // Nome automático baseado no índice atual da lista
    final nome = 'rebanho_${rebanhos.length + 1}';

    setState(() => _isLoading = true);
    try {
      await ref
          .read(rebanhoServiceProvider)
          .criar(
            nome: nome,
            pastoId: pastoEscolhido.id,
            propriedadeId: _prop.id,
          );
      if (!mounted) return;
      showBovSuccessSnackBar(context, 'Rebanho "$nome" criado.');
    } catch (e) {
      if (!mounted) return;
      showBovErrorSnackBar(context, 'Erro ao criar rebanho: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Apagar rebanho ────────────────────────────────────────────────────────

  Future<void> _apagarRebanho(RebanhoModel rebanho) async {
    // 1. Verificar bloqueio
    setState(() => _isLoading = true);
    String? bloqueio;
    try {
      bloqueio = await ref
          .read(rebanhoServiceProvider)
          .podeApagarRebanho(rebanhoId: rebanho.id, propriedadeId: _prop.id);
    } catch (e) {
      if (!mounted) return;
      showBovErrorSnackBar(context, 'Erro ao verificar rebanho: $e');
      if (mounted) setState(() => _isLoading = false);
      return;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }

    if (!mounted) return;

    // 2. Bloqueado → snackbar e encerra
    if (bloqueio != null) {
      showBovErrorSnackBar(context, bloqueio);
      return;
    }

    // 3. Confirmação
    final confirmado = await _confirm(
      'Apagar Rebanho',
      'Esta ação é irreversível. O rebanho será apagado permanentemente.',
    );
    if (!confirmado || !mounted) return;

    // 4. Apagar
    setState(() => _isLoading = true);
    try {
      await ref
          .read(rebanhoServiceProvider)
          .apagarRebanho(rebanhoId: rebanho.id, propriedadeId: _prop.id);
      _invalidateCount(rebanho.id);
      if (!mounted) return;
      showBovSuccessSnackBar(context, 'Rebanho "${rebanho.nome}" apagado.');
    } catch (e) {
      if (!mounted) return;
      showBovErrorSnackBar(context, 'Erro ao apagar rebanho: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── +25 animais no rebanho ────────────────────────────────────────────────

  Future<void> _adicionarAnimaisNoRebanho(
    RebanhoModel rebanho,
    PastoModel pasto,
    int totalAnimaisAtual,
  ) async {
    setState(() => _isLoading = true);
    try {
      final service = ref.read(animalServiceProvider);
      for (int i = 0; i < 25; i++) {
        final idx = totalAnimaisAtual + i + 1;
        await service.criar(
          nome: 'animal_$idx',
          brinco: 'brinco_$idx',
          raca: 'Genérica',
          novoPeso: 450.0,
          dataNascimento: DateTime(2020, 1, 1),
          rebanhoDestinoId: rebanho.id,
          nomeRebanhoDestino: rebanho.nome,
          propriedadeId: _prop.id,
          pastoDestinoId: pasto.id,
          nomePastoDestino: pasto.nome,
        );
      }
      _invalidateCount(rebanho.id);
      if (!mounted) return;
      showBovSuccessSnackBar(
        context,
        '25 animais adicionados a "${rebanho.nome}".',
      );
    } catch (e) {
      if (!mounted) return;
      showBovErrorSnackBar(context, 'Erro ao adicionar animais: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final rebanhosAsync = ref.watch(rebanhoListaProvider);
    final pastosAsync = ref.watch(pastosSelecionadosProvider);
    final animaisAsync = ref.watch(animaisListaPropEmVisProvider);

    final pastos = pastosAsync.asData?.value ?? [];
    final animais = animaisAsync.asData?.value ?? <AnimalModel>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          titulo: 'Rebanhos',
          expanded: _expanded,
          onToggle: () => setState(() => _expanded = !_expanded),
          trailing: _isLoading
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.accent,
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(
                    Icons.add,
                    color: AppColors.accent,
                    size: 22,
                  ),
                  onPressed: () => rebanhosAsync.whenData(
                    (rebanhos) => _criarRebanho(rebanhos, pastos),
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
        ),

        if (_expanded) ...[
          rebanhosAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.accent,
                  strokeWidth: 2,
                ),
              ),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Erro: $e',
                style: const TextStyle(
                  color: AppColors.red,
                  fontFamily: 'DM Sans',
                ),
              ),
            ),
            data: (rebanhos) {
              if (rebanhos.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    'Nenhum rebanho. Toque em + para criar.',
                    style: TextStyle(
                      color: AppColors.text4,
                      fontFamily: 'DM Sans',
                      fontSize: 13,
                    ),
                  ),
                );
              }
              return Column(
                children: [
                  ...rebanhos.map((rebanho) {
                    final pasto = pastos
                        .where((p) => p.id == rebanho.pastoId)
                        .firstOrNull;
                    return _RebanhoItem(
                      rebanho: rebanho,
                      pastoNome: pasto?.nome ?? 'Pasto não encontrado',
                      countFuture: _getCountFuture(rebanho.id),
                      onAdicionar: (_isLoading || pasto == null)
                          ? null
                          : () => _adicionarAnimaisNoRebanho(
                              rebanho,
                              pasto,
                              animais.length,
                            ),
                      onApagar: _isLoading
                          ? null
                          : () => _apagarRebanho(rebanho),
                    );
                  }),
                  const SizedBox(height: 8),
                ],
              );
            },
          ),
        ],
      ],
    );
  }
}

// ── Item de Rebanho ──────────────────────────────────────────────────────────

class _RebanhoItem extends StatelessWidget {
  final RebanhoModel rebanho;
  final String pastoNome;
  final Future<int> countFuture;
  final VoidCallback? onAdicionar;
  final VoidCallback? onApagar;

  const _RebanhoItem({
    required this.rebanho,
    required this.pastoNome,
    required this.countFuture,
    this.onAdicionar,
    this.onApagar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.fromLTRB(14, 10, 4, 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rebanho.nome,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Pasto: $pastoNome',
                  style: const TextStyle(
                    color: AppColors.text4,
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                  ),
                ),
                FutureBuilder<int>(
                  future: countFuture,
                  builder: (_, snap) {
                    final label =
                        snap.connectionState == ConnectionState.waiting
                        ? '...'
                        : '${snap.data ?? 0}';
                    return Text(
                      'Animais: $label',
                      style: const TextStyle(
                        color: AppColors.text4,
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Ação +25
          TextButton(
            onPressed: onAdicionar,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              '+25',
              style: TextStyle(
                color: onAdicionar != null ? AppColors.accent : AppColors.text4,
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),

          // Ação apagar
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: onApagar != null ? AppColors.red : AppColors.text4,
              size: 20,
            ),
            onPressed: onApagar,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SECTION: PASTOS
// =============================================================================

class _SectionPastos extends ConsumerStatefulWidget {
  final PropriedadeModel propriedade;
  const _SectionPastos({required this.propriedade});

  @override
  ConsumerState<_SectionPastos> createState() => _SectionPastosState();
}

class _SectionPastosState extends ConsumerState<_SectionPastos> {
  bool _expanded = false;
  bool _isLoading = false;

  /// Cache de futures de contagem de animais por pastoId.
  final Map<String, Future<int>> _countCache = {};

  PropriedadeModel get _prop => widget.propriedade;

  // ── Feedback helpers (mesmo padrão da Section Rebanhos) ───────────────────

  Future<bool> _confirm(String title, String body) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.text,
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          body,
          style: const TextStyle(color: AppColors.text4, fontFamily: 'DM Sans'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.text4, fontFamily: 'DM Sans'),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Confirmar',
              style: TextStyle(
                color: AppColors.red,
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    return result == true;
  }

  // ── Contagem de animais no pasto ──────────────────────────────────────────

  Future<int> _getCountFuture(String pastoId) => _countCache.putIfAbsent(
    pastoId,
    () => ref
        .read(animalServiceProvider)
        .contarAnimaisPorPasto(propriedadeId: _prop.id, pastoId: pastoId),
  );

  void _invalidateCount(String pastoId) => _countCache.remove(pastoId);

  // ── Geometria do polígono ─────────────────────────────────────────────────
  //
  // Gera um quadrado de ~250m de lado, deslocado ~300m em longitude por
  // índice do pasto, para não sobrepor pastos já criados. Não precisa ser
  // preciso — só precisa ficar visível e não colidir no mapa.

  List<LatLngPoint> _gerarQuadrado({
    required double centroLat,
    required double centroLng,
    required int indice,
  }) {
    const ladoMetros = 250.0;
    const offsetGrausLng = 0.003; // ≈ 300m por pasto

    final lngBase = centroLng + (offsetGrausLng * indice);

    // Conversão aproximada de metros para graus
    final metrosParaGrauLat = ladoMetros / 111320.0;
    final metrosParaGrauLng =
        ladoMetros / (111320.0 * math.cos(centroLat * math.pi / 180));

    final meioLat = metrosParaGrauLat / 2;
    final meioLng = metrosParaGrauLng / 2;

    return [
      LatLngPoint(lat: centroLat - meioLat, lng: lngBase - meioLng),
      LatLngPoint(lat: centroLat - meioLat, lng: lngBase + meioLng),
      LatLngPoint(lat: centroLat + meioLat, lng: lngBase + meioLng),
      LatLngPoint(lat: centroLat + meioLat, lng: lngBase - meioLng),
    ];
  }

  // ── Criar pasto ───────────────────────────────────────────────────────────

  Future<void> _criarPasto(List<PastoModel> pastosAtuais) async {
    if (!_prop.temCentroDefinido) {
      showBovErrorSnackBar(
        context,
        'Defina o centro do mapa da propriedade antes de criar um pasto.',
      );
      return;
    }

    final nome = 'pasto_${pastosAtuais.length + 1}';

    setState(() => _isLoading = true);
    try {
      final pastoService = ref.read(pastoServiceProvider);
      final poligonoRepo = ref.read(poligonoRepositoryProvider);

      await pastoService.criar(
        nome: nome,
        propriedadeId: _prop.id,
        area: 100.0,
        descricao: 'Pasto de teste',
        limiteAnimais: 50,
      );

      // PastoService.criar não retorna o ID — buscamos a lista atualizada
      // e localizamos o pasto recém-criado pelo nome (único nesta sequência).
      final pastosAtualizados = await pastoService.listar(_prop.id);
      final pastoCriado = pastosAtualizados
          .where((p) => p.nome == nome)
          .firstOrNull;

      if (pastoCriado == null) {
        if (!mounted) return;
        showBovErrorSnackBar(
          context,
          'Pasto criado, mas não foi possível localizá-lo para criar o polígono.',
        );
        return;
      }

      // Evita duplicata, embora não deva ocorrer para pasto recém-criado
      final existente = await poligonoRepo.buscarPorPasto(
        propriedadeId: _prop.id,
        pastoId: pastoCriado.id,
      );

      if (existente == null) {
        final pontos = _gerarQuadrado(
          centroLat: _prop.centroLat!,
          centroLng: _prop.centroLng!,
          indice: pastosAtuais.length,
        );

        await poligonoRepo.salvar(
          PoligonoModel(
            id: '',
            propriedadeId: _prop.id,
            pastoId: pastoCriado.id,
            pontos: pontos,
          ),
        );
      }

      if (!mounted) return;
      showBovSuccessSnackBar(context, 'Pasto "$nome" criado.');
    } catch (e) {
      if (!mounted) return;
      showBovErrorSnackBar(context, 'Erro ao criar pasto: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Apagar pasto ──────────────────────────────────────────────────────────

  Future<void> _apagarPasto(PastoModel pasto) async {
    setState(() => _isLoading = true);
    String? bloqueio;
    bool possuiPoligono = false;
    try {
      final service = ref.read(pastoServiceProvider);
      bloqueio = await service.verificarBloqueioExclusao(
        propriedadeId: _prop.id,
        pastoId: pasto.id,
      );
      if (bloqueio == null) {
        possuiPoligono = await service.possuiPoligono(
          propriedadeId: _prop.id,
          pastoId: pasto.id,
        );
      }
    } catch (e) {
      if (!mounted) return;
      showBovErrorSnackBar(context, 'Erro ao verificar pasto: $e');
      if (mounted) setState(() => _isLoading = false);
      return;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }

    if (!mounted) return;

    if (bloqueio != null) {
      showBovErrorSnackBar(context, bloqueio);
      return;
    }

    final mensagem = possuiPoligono
        ? 'Esta ação é irreversível. O pasto e seu polígono no mapa serão apagados permanentemente.'
        : 'Esta ação é irreversível. O pasto será apagado permanentemente.';

    final confirmado = await _confirm('Apagar Pasto', mensagem);
    if (!confirmado || !mounted) return;

    setState(() => _isLoading = true);
    try {
      await ref
          .read(pastoServiceProvider)
          .apagar(propriedadeId: _prop.id, pastoId: pasto.id);
      _invalidateCount(pasto.id);
      if (!mounted) return;
      showBovSuccessSnackBar(context, 'Pasto "${pasto.nome}" apagado.');
    } catch (e) {
      if (!mounted) return;
      showBovErrorSnackBar(context, 'Erro ao apagar pasto: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── +25 animais avulsos no pasto ──────────────────────────────────────────

  Future<void> _adicionarAnimaisAvulsos(
    PastoModel pasto,
    int totalAnimaisAtual,
  ) async {
    setState(() => _isLoading = true);
    try {
      final service = ref.read(animalServiceProvider);
      for (int i = 0; i < 25; i++) {
        final idx = totalAnimaisAtual + i + 1;
        await service.criar(
          nome: 'animal_$idx',
          brinco: 'brinco_$idx',
          raca: 'Genérica',
          novoPeso: 450.0,
          dataNascimento: DateTime(2020, 1, 1),
          rebanhoDestinoId: null,
          nomeRebanhoDestino: null,
          propriedadeId: _prop.id,
          pastoDestinoId: pasto.id,
          nomePastoDestino: pasto.nome,
        );
      }
      _invalidateCount(pasto.id);
      if (!mounted) return;
      showBovSuccessSnackBar(
        context,
        '25 animais avulsos adicionados a "${pasto.nome}".',
      );
    } catch (e) {
      if (!mounted) return;
      showBovErrorSnackBar(context, 'Erro ao adicionar animais: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final pastosAsync = ref.watch(pastosSelecionadosProvider);
    final animaisAsync = ref.watch(animaisListaPropEmVisProvider);
    final animais = animaisAsync.asData?.value ?? <AnimalModel>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          titulo: 'Pastos',
          expanded: _expanded,
          onToggle: () => setState(() => _expanded = !_expanded),
          trailing: _isLoading
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.accent,
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(
                    Icons.add,
                    color: AppColors.accent,
                    size: 22,
                  ),
                  onPressed: () => pastosAsync.whenData(_criarPasto),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
        ),

        if (_expanded) ...[
          pastosAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.accent,
                  strokeWidth: 2,
                ),
              ),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Erro: $e',
                style: const TextStyle(
                  color: AppColors.red,
                  fontFamily: 'DM Sans',
                ),
              ),
            ),
            data: (pastos) {
              if (pastos.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    'Nenhum pasto. Toque em + para criar.',
                    style: TextStyle(
                      color: AppColors.text4,
                      fontFamily: 'DM Sans',
                      fontSize: 13,
                    ),
                  ),
                );
              }
              return Column(
                children: [
                  ...pastos.map(
                    (pasto) => _PastoItem(
                      pasto: pasto,
                      countFuture: _getCountFuture(pasto.id),
                      onAdicionar: _isLoading
                          ? null
                          : () =>
                                _adicionarAnimaisAvulsos(pasto, animais.length),
                      onApagar: _isLoading ? null : () => _apagarPasto(pasto),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            },
          ),
        ],
      ],
    );
  }
}

// ── Item de Pasto ─────────────────────────────────────────────────────────────

class _PastoItem extends StatelessWidget {
  final PastoModel pasto;
  final Future<int> countFuture;
  final VoidCallback? onAdicionar;
  final VoidCallback? onApagar;

  const _PastoItem({
    required this.pasto,
    required this.countFuture,
    this.onAdicionar,
    this.onApagar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.fromLTRB(14, 10, 4, 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pasto.nome,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Limite: ${pasto.limiteAnimais ?? '-'}',
                  style: const TextStyle(
                    color: AppColors.text4,
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                  ),
                ),
                FutureBuilder<int>(
                  future: countFuture,
                  builder: (_, snap) {
                    final label =
                        snap.connectionState == ConnectionState.waiting
                        ? '...'
                        : '${snap.data ?? 0}';
                    return Text(
                      'Animais: $label',
                      style: const TextStyle(
                        color: AppColors.text4,
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          TextButton(
            onPressed: onAdicionar,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              '+25',
              style: TextStyle(
                color: onAdicionar != null ? AppColors.accent : AppColors.text4,
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),

          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: onApagar != null ? AppColors.red : AppColors.text4,
              size: 20,
            ),
            onPressed: onApagar,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SECTION: ANIMAIS
// =============================================================================

/// Roxo claro para animais sem rebanho (apenas no pasto).
/// `app_colors.dart` não possui constante de roxo — usamos um tom escuro
/// consistente com o estilo de `AppColors.accentBg` (mesmo padrão de
/// luminosidade, só trocando o matiz para roxo).
const Color _kSemRebanhoBg = Color(0xFF2A1F45);

class _SectionAnimais extends ConsumerStatefulWidget {
  final PropriedadeModel propriedade;
  const _SectionAnimais({required this.propriedade});

  @override
  ConsumerState<_SectionAnimais> createState() => _SectionAnimaisState();
}

class _SectionAnimaisState extends ConsumerState<_SectionAnimais> {
  bool _expanded = true;
  bool _isLoading = false;

  /// Cache do último histórico de movimentação por animalId.
  /// Limpo por completo após "apagar todos".
  final Map<String, Future<HistoricoAnimalModel?>> _historicoCache = {};

  // ── Feedback helpers (mesmo padrão das outras sections) ────────────────────

  Future<bool> _confirm(String title, String body) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.text,
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          body,
          style: const TextStyle(color: AppColors.text4, fontFamily: 'DM Sans'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.text4, fontFamily: 'DM Sans'),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Confirmar',
              style: TextStyle(
                color: AppColors.red,
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    return result == true;
  }

  // ── Último histórico de movimentação (define a cor do item) ────────────────

  Future<HistoricoAnimalModel?> _getHistoricoFuture(String animalId) =>
      _historicoCache.putIfAbsent(
        animalId,
        () => ref
            .read(historicoAnimalRepositoryProvider)
            .buscarUltimaMovimentacao(animalId: animalId),
      );

  void _clearHistoricoCache() => _historicoCache.clear();

  // ── Apagar todos os animais da propriedade ──────────────────────────────────

  Future<void> _apagarTodos(List<AnimalModel> animais) async {
    if (animais.isEmpty) {
      showBovErrorSnackBar(context, 'Não há animais para apagar.');
      return;
    }

    final confirmado = await _confirm(
      'Apagar Todos os Animais',
      'Esta ação é irreversível. Todos os ${animais.length} animais desta '
          'propriedade serão apagados permanentemente.',
    );
    if (!confirmado || !mounted) return;

    setState(() => _isLoading = true);
    try {
      final service = ref.read(animalServiceProvider);
      for (final animal in animais) {
        await service.apagar(animalId: animal.id);
      }
      _clearHistoricoCache();
      if (!mounted) return;
      showBovSuccessSnackBar(context, '${animais.length} animais apagados.');
    } catch (e) {
      if (!mounted) return;
      showBovErrorSnackBar(context, 'Erro ao apagar animais: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final animaisAsync = ref.watch(animaisListaPropEmVisProvider);
    final animais = animaisAsync.asData?.value ?? <AnimalModel>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          titulo: 'Animais',
          expanded: _expanded,
          onToggle: () => setState(() => _expanded = !_expanded),
          trailing: _isLoading
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.accent,
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(
                    Icons.delete_sweep_outlined,
                    color: AppColors.red,
                    size: 22,
                  ),
                  onPressed: () => _apagarTodos(animais),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
        ),

        if (_expanded) ...[
          animaisAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.accent,
                  strokeWidth: 2,
                ),
              ),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Erro: $e',
                style: const TextStyle(
                  color: AppColors.red,
                  fontFamily: 'DM Sans',
                ),
              ),
            ),
            data: (lista) {
              if (lista.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    'Nenhum animal nesta propriedade.',
                    style: TextStyle(
                      color: AppColors.text4,
                      fontFamily: 'DM Sans',
                      fontSize: 13,
                    ),
                  ),
                );
              }
              return Column(
                children: [
                  ...lista.map(
                    (animal) => _AnimalItem(
                      animal: animal,
                      historicoFuture: _getHistoricoFuture(animal.id),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            },
          ),
        ],
      ],
    );
  }
}

// ── Item de Animal ───────────────────────────────────────────────────────────

class _AnimalItem extends StatelessWidget {
  final AnimalModel animal;
  final Future<HistoricoAnimalModel?> historicoFuture;

  const _AnimalItem({required this.animal, required this.historicoFuture});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<HistoricoAnimalModel?>(
      future: historicoFuture,
      builder: (_, snap) {
        final carregando = snap.connectionState == ConnectionState.waiting;
        final temRebanho = snap.data?.rebanhoDestinoId != null;

        final corFundo = carregando
            ? AppColors.card
            : (temRebanho ? AppColors.accentBg : _kSemRebanhoBg);
        final corBorda = carregando
            ? AppColors.border
            : (temRebanho ? AppColors.accent : AppColors.text4);

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: corFundo,
            borderRadius: BorderRadius.circular(10),
            // ignore: deprecated_member_use
            border: Border.all(color: corBorda.withOpacity(0.4)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  animal.nome,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              if (carregando)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.text4,
                  ),
                )
              else
                Text(
                  temRebanho ? 'Com rebanho' : 'Sem rebanho',
                  style: TextStyle(
                    color: temRebanho ? AppColors.accent : AppColors.text2,
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// =============================================================================
// SECTION: TAREFAS
// =============================================================================

class _SectionTarefas extends ConsumerStatefulWidget {
  final PropriedadeModel propriedade;
  const _SectionTarefas({required this.propriedade});

  @override
  ConsumerState<_SectionTarefas> createState() => _SectionTarefasState();
}

class _SectionTarefasState extends ConsumerState<_SectionTarefas> {
  bool _expanded = false;
  bool _isLoading = false;

  PropriedadeModel get _prop => widget.propriedade;

  // ── Feedback helpers (mesmo padrão das outras sections) ────────────────────

  Future<bool> _confirm(String title, String body) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.text,
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          body,
          style: const TextStyle(color: AppColors.text4, fontFamily: 'DM Sans'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.text4, fontFamily: 'DM Sans'),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Confirmar',
              style: TextStyle(
                color: AppColors.red,
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    return result == true;
  }

  // ── Dados de teste ─────────────────────────────────────────────────────────
  //
  // 6 categorias x 2 tarefas. [offsetDias] é relativo a hoje:
  // negativo = passado, 0 = hoje, positivo = futuro.
  // [hora] em minutos desde a meia-noite (null = sem horário).

  static const List<
    ({
      String titulo,
      String descricao,
      int offsetDias,
      int? hora,
      StatusTarefa status,
    })
  >
  _tarefasTeste = [
    // ── Atrasadas (pendentes com data passada) ──────────────────────────────
    (
      titulo: 'Vacinar bezerros contra aftosa',
      descricao: 'Aplicar a dose de reforço nos bezerros do lote 2.',
      offsetDias: -3,
      hora: 480,
      status: StatusTarefa.pendente,
    ),
    (
      titulo: 'Consertar cerca do pasto norte',
      descricao: 'Trocar os mourões quebrados perto do bebedouro.',
      offsetDias: -10,
      hora: null,
      status: StatusTarefa.pendente,
    ),

    // ── Hoje, pendentes ─────────────────────────────────────────────────────
    (
      titulo: 'Pesar animais do curral',
      descricao: 'Registrar o peso dos animais que serão vendidos.',
      offsetDias: 0,
      hora: 870,
      status: StatusTarefa.pendente,
    ),
    (
      titulo: 'Verificar bebedouros',
      descricao: 'Conferir o nível de água e limpar os bebedouros.',
      offsetDias: 0,
      hora: null,
      status: StatusTarefa.pendente,
    ),

    // ── Hoje, concluídas ────────────────────────────────────────────────────
    (
      titulo: 'Ordenhar vacas leiteiras',
      descricao: 'Ordenha da manhã finalizada sem intercorrências.',
      offsetDias: 0,
      hora: 360,
      status: StatusTarefa.concluida,
    ),
    (
      titulo: 'Fornecer sal mineral',
      descricao: 'Reposição do cocho de sal mineral do pasto 1.',
      offsetDias: 0,
      hora: null,
      status: StatusTarefa.concluida,
    ),

    // ── Futuras, pendentes ──────────────────────────────────────────────────
    (
      titulo: 'Reunião com o veterinário',
      descricao: 'Discutir o calendário sanitário do próximo semestre.',
      offsetDias: 2,
      hora: 540,
      status: StatusTarefa.pendente,
    ),
    (
      titulo: 'Comprar ração para a seca',
      descricao: 'Cotar e comprar ração para o período de estiagem.',
      offsetDias: 7,
      hora: null,
      status: StatusTarefa.pendente,
    ),

    // ── Futuras, concluídas ─────────────────────────────────────────────────
    (
      titulo: 'Agendar inseminação das matrizes',
      descricao: 'Data já confirmada com o técnico responsável.',
      offsetDias: 3,
      hora: null,
      status: StatusTarefa.concluida,
    ),
    (
      titulo: 'Pagar fornecedor de sementes',
      descricao: 'Pagamento antecipado das sementes de capim.',
      offsetDias: 15,
      hora: 600,
      status: StatusTarefa.concluida,
    ),

    // ── Passadas, concluídas ────────────────────────────────────────────────
    (
      titulo: 'Vermifugar o rebanho',
      descricao: 'Vermífugo aplicado em todos os animais do rebanho.',
      offsetDias: -5,
      hora: 420,
      status: StatusTarefa.concluida,
    ),
    (
      titulo: 'Revisar a roçadeira',
      descricao: 'Manutenção e troca das lâminas concluída.',
      offsetDias: -20,
      hora: null,
      status: StatusTarefa.concluida,
    ),
  ];

  // ── Adicionar tarefas variadas ─────────────────────────────────────────────
  //
  // Usa o repositório diretamente: TarefaService.criar sempre grava como
  // "pendente" e agenda notificação, o que não serve para tarefas concluídas
  // ou com data passada. Assim, nenhuma notificação é agendada para estas.

  Future<void> _adicionarVariadas() async {
    final usuarioId = ref.read(usuarioAtualProvider).value?.id;
    if (usuarioId == null) {
      showBovErrorSnackBar(context, 'Usuário não carregado.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(tarefaRepositoryProvider);
      final agora = DateTime.now();
      final hoje = DateTime(agora.year, agora.month, agora.day);

      for (final t in _tarefasTeste) {
        await repo.criar(
          TarefaModel(
            id: '',
            titulo: t.titulo,
            descricao: t.descricao,
            dataExecucao: hoje.add(Duration(days: t.offsetDias)),
            status: t.status,
            propriedadeId: _prop.id,
            usuarioId: usuarioId,
            horaExecucaoMinutos: t.hora,
          ),
        );
      }

      if (!mounted) return;
      showBovSuccessSnackBar(
        context,
        '${_tarefasTeste.length} tarefas de teste criadas.',
      );
    } catch (e) {
      if (!mounted) return;
      showBovErrorSnackBar(context, 'Erro ao criar tarefas: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Apagar todas as tarefas da propriedade ─────────────────────────────────

  Future<void> _apagarTodas(List<TarefaModel> tarefas) async {
    if (tarefas.isEmpty) {
      showBovErrorSnackBar(context, 'Não há tarefas para apagar.');
      return;
    }

    final confirmado = await _confirm(
      'Apagar Todas as Tarefas',
      'Esta ação é irreversível. Todas as ${tarefas.length} tarefas desta '
          'propriedade serão apagadas permanentemente.',
    );
    if (!confirmado || !mounted) return;

    setState(() => _isLoading = true);
    try {
      // Pelo service para também cancelar eventuais notificações agendadas
      final service = ref.read(tarefaServiceProvider);
      for (final tarefa in tarefas) {
        await service.apagar(propriedadeId: _prop.id, tarefaId: tarefa.id);
      }
      if (!mounted) return;
      showBovSuccessSnackBar(context, '${tarefas.length} tarefas apagadas.');
    } catch (e) {
      if (!mounted) return;
      showBovErrorSnackBar(context, 'Erro ao apagar tarefas: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final tarefasAsync = ref.watch(tarefasListaProvider);
    final tarefas = tarefasAsync.asData?.value ?? <TarefaModel>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          titulo: 'Tarefas',
          expanded: _expanded,
          onToggle: () => setState(() => _expanded = !_expanded),
          trailing: _isLoading
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.accent,
                    ),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Adicionar tarefas variadas',
                      icon: const Icon(
                        Icons.playlist_add_rounded,
                        color: AppColors.accent,
                        size: 22,
                      ),
                      onPressed: _adicionarVariadas,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Apagar todas as tarefas',
                      icon: const Icon(
                        Icons.delete_sweep_outlined,
                        color: AppColors.red,
                        size: 22,
                      ),
                      onPressed: () => _apagarTodas(tarefas),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                  ],
                ),
        ),

        if (_expanded) ...[
          tarefasAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.accent,
                  strokeWidth: 2,
                ),
              ),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Erro: $e',
                style: const TextStyle(
                  color: AppColors.red,
                  fontFamily: 'DM Sans',
                ),
              ),
            ),
            data: (lista) {
              if (lista.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    'Nenhuma tarefa. Toque em + para criar tarefas de teste.',
                    style: TextStyle(
                      color: AppColors.text4,
                      fontFamily: 'DM Sans',
                      fontSize: 13,
                    ),
                  ),
                );
              }
              return Column(
                children: [
                  ...lista.map((tarefa) => _TarefaItem(tarefa: tarefa)),
                  const SizedBox(height: 8),
                ],
              );
            },
          ),
        ],
      ],
    );
  }
}

// ── Item de Tarefa ───────────────────────────────────────────────────────────

class _TarefaItem extends StatelessWidget {
  final TarefaModel tarefa;

  const _TarefaItem({required this.tarefa});

  @override
  Widget build(BuildContext context) {
    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);
    final d = tarefa.dataExecucao;
    final dia = DateTime(d.year, d.month, d.day);

    final concluida = tarefa.status == StatusTarefa.concluida;
    final atrasada = !concluida && dia.isBefore(hoje);

    final String rotulo;
    final Color cor;
    final Color corBg;
    if (concluida) {
      rotulo = 'Concluída';
      cor = AppColors.accent;
      corBg = AppColors.accentBg;
    } else if (atrasada) {
      rotulo = 'Atrasada';
      cor = AppColors.red;
      corBg = AppColors.redBg;
    } else {
      rotulo = 'Pendente';
      cor = AppColors.text2;
      corBg = AppColors.card;
    }

    final minutos = tarefa.horaExecucaoMinutos;
    final hora = minutos == null
        ? ''
        : ' · ${(minutos ~/ 60).toString().padLeft(2, '0')}:'
              '${(minutos % 60).toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tarefa.titulo,
                  style: TextStyle(
                    color: concluida ? AppColors.text4 : AppColors.text,
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    decoration: concluida ? TextDecoration.lineThrough : null,
                    decorationColor: AppColors.text4,
                  ),
                ),
                if (tarefa.descricao.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    tarefa.descricao,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.text4,
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  '${DateFormat('dd/MM/yyyy').format(d)}$hora',
                  style: const TextStyle(
                    color: AppColors.text4,
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: corBg,
              borderRadius: BorderRadius.circular(6),
              // ignore: deprecated_member_use
              border: Border.all(color: cor.withOpacity(0.4)),
            ),
            child: Text(
              rotulo,
              style: TextStyle(
                color: cor,
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
