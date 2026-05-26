import 'package:bov_manager/core/theme/app_colors.dart';
import 'package:bov_manager/core/widgets/bov_widgets.dart';
import 'package:bov_manager/models/historico_animal_model.dart';
import 'package:bov_manager/services/pasto_service.dart';
import 'package:bov_manager/viewmodels/animal_viewmodel.dart';
import 'package:bov_manager/viewmodels/historico_animal_viewmodel.dart';
import 'package:bov_manager/viewmodels/pasto_viewmodel.dart';
import 'package:bov_manager/viewmodels/propriedade_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class HistoricoAnimalScreen extends ConsumerWidget {
  const HistoricoAnimalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animal = ref.watch(animalEmVisualizacaoProvider);
    final historicoState = ref.watch(historicoAnimalListaProvider);

    final titulo = animal != null
        ? 'Histórico — ${animal.nome.isNotEmpty ? animal.nome : '#${animal.brinco}'}'
        : 'Histórico';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  BovBackButton(),
                  Expanded(
                    child: Center(
                      child: Text(
                        titulo,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 36),
                ],
              ),
            ),

            // ── Corpo ─────────────────────────────────────────────────────
            Expanded(
              child: historicoState.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                ),
                error: (e, _) => Center(
                  child: Text(
                    e.toString(),
                    style: const TextStyle(
                      color: AppColors.red,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                ),
                data: (historico) {
                  if (animal == null || historico.isEmpty) {
                    return const _EmptyState();
                  }

                  // 'entrada' é incluída nas pesagens para servir de base
                  // na comparação de ganho de peso.
                  // A lista já vem ordenada por data desc (mais recente primeiro).
                  final pesagens = historico
                      .where((h) => h.tipo == 'pesagem' || h.tipo == 'entrada')
                      .toList();

                  final movimentacoes = historico
                      .where(
                        (h) => h.tipo == 'movimentacao' || h.tipo == 'entrada',
                      )
                      .toList();

                  final outros = historico
                      .where(
                        (h) =>
                            h.tipo != 'pesagem' &&
                            h.tipo != 'movimentacao' &&
                            h.tipo != 'entrada',
                      )
                      .toList();

                  // Carrega o mapa de pastos uma única vez para a seção de
                  // movimentações — só executa se houver movimentações com IDs.
                  final propriedadeId =
                      ref.read(propriedadeEmVisualizacaoProvider)?.id ?? '';

                  return _HistoricoBody(
                    pesagens: pesagens,
                    movimentacoes: movimentacoes,
                    outros: outros,
                    propriedadeId: propriedadeId,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// CORPO PRINCIPAL — separa o FutureBuilder do resto do build
// =============================================================================

class _HistoricoBody extends ConsumerStatefulWidget {
  const _HistoricoBody({
    required this.pesagens,
    required this.movimentacoes,
    required this.outros,
    required this.propriedadeId,
  });

  final List<HistoricoAnimalModel> pesagens;
  final List<HistoricoAnimalModel> movimentacoes;
  final List<HistoricoAnimalModel> outros;
  final String propriedadeId;

  @override
  ConsumerState<_HistoricoBody> createState() => _HistoricoBodyState();
}

class _HistoricoBodyState extends ConsumerState<_HistoricoBody> {
  late Future<Map<String, String>> _pastoNomesFuture;

  @override
  void initState() {
    super.initState();
    _pastoNomesFuture = _carregarNomesPastos();
  }

  /// Busca os pastos da propriedade e retorna um mapa {pastoId → nome}.
  /// Se não há movimentações ou a propriedade é inválida, retorna vazio.
  Future<Map<String, String>> _carregarNomesPastos() async {
    if (widget.movimentacoes.isEmpty || widget.propriedadeId.isEmpty) {
      return {};
    }
    try {
      final pastos = await ref.read(pastosListaProvider.future);
      return {for (final p in pastos) p.id: p.nome};
    } catch (_) {
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Peso atual ──────────────────────────────────────────────────
          if (widget.pesagens.isNotEmpty) ...[
            const _SectionTitle(title: 'EVOLUÇÃO DE PESO'),
            _PesoCard(pesagens: widget.pesagens),
            const SizedBox(height: 4),
          ],

          // ── Movimentações ────────────────────────────────────────────────
          if (widget.movimentacoes.isNotEmpty) ...[
            const _SectionTitle(title: 'MOVIMENTAÇÕES'),
            FutureBuilder<Map<String, String>>(
              future: _pastoNomesFuture,
              builder: (context, snapshot) {
                // Usa o mapa quando disponível; enquanto carrega usa os IDs
                // como fallback para não bloquear a UI.
                final nomes = snapshot.data ?? {};

                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: widget.movimentacoes
                        .asMap()
                        .entries
                        .map(
                          (e) => _MovimentacaoItem(
                            historico: e.value,
                            isFirst: e.key == 0,
                            isLast: e.key == widget.movimentacoes.length - 1,
                            pastoNomes: nomes,
                          ),
                        )
                        .toList(),
                  ),
                );
              },
            ),
          ],

          // ── Outros eventos ───────────────────────────────────────────────
          if (widget.outros.isNotEmpty) ...[
            const _SectionTitle(title: 'OUTROS EVENTOS'),
            Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: widget.outros
                    .asMap()
                    .entries
                    .map(
                      (e) => _EventoItem(
                        historico: e.value,
                        isFirst: e.key == 0,
                        isLast: e.key == widget.outros.length - 1,
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// =============================================================================
// CARD DE PESO
// =============================================================================

class _PesoCard extends StatelessWidget {
  const _PesoCard({required this.pesagens});

  final List<HistoricoAnimalModel> pesagens;

  @override
  Widget build(BuildContext context) {
    // Lista vem desc: first = mais recente, last = mais antigo (entrada)
    final pesoMaisRecente = pesagens.first.valor;
    final pesoInicial = pesagens.last.valor;
    final ganho = pesoMaisRecente - pesoInicial;
    final ganhoStr = ganho >= 0
        ? '+${ganho.toStringAsFixed(0)}'
        : ganho.toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${pesoMaisRecente.toStringAsFixed(0)} kg',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                  const Text(
                    'Peso atual',
                    style: TextStyle(
                      color: AppColors.text4,
                      fontSize: 11,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$ganhoStr kg',
                    style: TextStyle(
                      color: ganho >= 0 ? AppColors.accent : AppColors.red,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                  const Text(
                    'desde o início',
                    style: TextStyle(
                      color: AppColors.text4,
                      fontSize: 11,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _GraficoPeso(pesagens: pesagens),
        ],
      ),
    );
  }
}

class _GraficoPeso extends StatelessWidget {
  const _GraficoPeso({required this.pesagens});

  final List<HistoricoAnimalModel> pesagens;

  @override
  Widget build(BuildContext context) {
    // Lista vem desc; inverte para exibir cronologicamente (esq → dir)
    // e limita a 6 pontos para não sobrecarregar o gráfico
    final pontos = pesagens.reversed.take(6).toList();
    final maxPeso = pontos.map((p) => p.valor).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 80,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: pontos.asMap().entries.map((entry) {
          final isLast = entry.key == pontos.length - 1;
          final altura = maxPeso > 0 ? entry.value.valor / maxPeso : 0.0;
          final mes = DateFormat('MMM').format(entry.value.data);

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: altura.clamp(0.1, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isLast
                                ? AppColors.accent
                                : AppColors.accentBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mes,
                    style: TextStyle(
                      color: isLast ? AppColors.accent : AppColors.text4,
                      fontSize: 10,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// =============================================================================
// ITEM DE MOVIMENTAÇÃO
// =============================================================================

class _MovimentacaoItem extends StatelessWidget {
  const _MovimentacaoItem({
    required this.historico,
    required this.isFirst,
    required this.isLast,
    required this.pastoNomes,
  });

  final HistoricoAnimalModel historico;
  final bool isFirst;
  final bool isLast;

  /// Mapa {pastoId → nomePasto} — pode estar vazio enquanto carrega.
  final Map<String, String> pastoNomes;

  /// Resolve o nome do pasto pelo id; usa o próprio id como fallback.
  String _nomePasto(String? id) {
    if (id == null) return '—';
    return pastoNomes[id] ?? id;
  }

  @override
  Widget build(BuildContext context) {
    final isEntrada = historico.pastoOrigemId == null;
    final nomeOrigem = _nomePasto(historico.pastoOrigemId);
    final nomeDestino = _nomePasto(historico.pastoDestinoId);
    final data = DateFormat('dd MMM yyyy').format(historico.data);

    return Container(
      padding: EdgeInsets.fromLTRB(16, isFirst ? 14 : 10, 16, isLast ? 14 : 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isEntrada ? Icons.login_rounded : Icons.arrow_forward_rounded,
              color: AppColors.text4,
              size: 14,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEntrada
                      ? 'Entrada — $nomeDestino'
                      : '$nomeOrigem → $nomeDestino',
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'DM Sans',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data,
                  style: const TextStyle(
                    color: AppColors.text4,
                    fontSize: 12,
                    fontFamily: 'DM Sans',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// ITEM DE EVENTO GENÉRICO
// =============================================================================

class _EventoItem extends StatelessWidget {
  const _EventoItem({
    required this.historico,
    required this.isFirst,
    required this.isLast,
  });

  final HistoricoAnimalModel historico;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final data = DateFormat('dd MMM yyyy').format(historico.data);

    return Container(
      padding: EdgeInsets.fromLTRB(16, isFirst ? 14 : 10, 16, isLast ? 14 : 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.event_note_rounded,
              color: AppColors.text4,
              size: 14,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  historico.tipo,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'DM Sans',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data,
                  style: const TextStyle(
                    color: AppColors.text4,
                    fontSize: 12,
                    fontFamily: 'DM Sans',
                  ),
                ),
              ],
            ),
          ),
          Text(
            historico.valor.toStringAsFixed(1),
            style: const TextStyle(
              color: AppColors.text2,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              fontFamily: 'DM Sans',
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// WIDGETS AUXILIARES
// =============================================================================

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.text4,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
          fontFamily: 'DM Sans',
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_rounded, color: AppColors.text4, size: 48),
            SizedBox(height: 16),
            Text(
              'Nenhum histórico',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'DM Sans',
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Os registros de pesagem e\nmovimentação aparecerão aqui.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.text4,
                fontSize: 13,
                fontFamily: 'DM Sans',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
