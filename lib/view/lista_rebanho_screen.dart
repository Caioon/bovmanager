import 'package:bov_manager/core/navigation/app_coordinator.dart';
import 'package:bov_manager/core/theme/app_colors.dart';
import 'package:bov_manager/core/widgets/bov_widgets.dart';
import 'package:bov_manager/models/rebanho_model.dart';
import 'package:bov_manager/services/pasto_service.dart';
import 'package:bov_manager/viewmodels/pasto_viewmodel.dart';
import 'package:bov_manager/viewmodels/propriedade_viewmodel.dart';
import 'package:bov_manager/viewmodels/rebanho_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ListaRebanhoScreen extends ConsumerStatefulWidget {
  const ListaRebanhoScreen({super.key});

  @override
  ConsumerState<ListaRebanhoScreen> createState() => _ListaRebanhoScreenState();
}

class _ListaRebanhoScreenState extends ConsumerState<ListaRebanhoScreen> {
  /// Mapa {pastoId → nomePasto} carregado uma vez para montar os subtítulos.
  late Future<Map<String, String>> _pastoNomesFuture;

  @override
  void initState() {
    super.initState();
    _pastoNomesFuture = _carregarNomesPastos();
  }

  Future<Map<String, String>> _carregarNomesPastos() async {
    final propriedadeId = ref.read(propriedadeEmVisualizacaoProvider)?.id ?? '';
    if (propriedadeId.isEmpty) return {};
    try {
      final pastos = await ref.read(pastosListaProvider.future);
      return {for (final p in pastos) p.id: p.nome};
    } catch (_) {
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    final listaState = ref.watch(rebanhoListaProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      BovBackButton(),
                      const SizedBox(width: 12),
                      const Text(
                        'Rebanhos',
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => AppCoordinator.goToNovoRebanho(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: AppColors.text2,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Corpo ─────────────────────────────────────────────────────
            Expanded(
              child: listaState.when(
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
                data: (lista) {
                  if (lista.isEmpty) return const _EmptyState();

                  return FutureBuilder<Map<String, String>>(
                    future: _pastoNomesFuture,
                    builder: (context, snapshot) {
                      final pastoNomes = snapshot.data ?? {};

                      return ListView(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              children: lista
                                  .asMap()
                                  .entries
                                  .map(
                                    (e) => _RebanhoItem(
                                      rebanho: e.value,
                                      isFirst: e.key == 0,
                                      isLast: e.key == lista.length - 1,
                                      nomePasto:
                                          pastoNomes[e.value.pastoId] ??
                                          e.value.pastoId,
                                      onTap: () => _showAcoesRebanho(
                                        context,
                                        ref,
                                        e.value,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // BOTTOM SHEET DE AÇÕES
  // ===========================================================================

  void _showAcoesRebanho(
    BuildContext context,
    WidgetRef ref,
    RebanhoModel rebanho,
  ) {
    ref.read(rebanhoEmVisualizacaoProvider.notifier).abrir(rebanho);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Alça
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Cabeçalho do rebanho
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.accentBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.groups_rounded,
                      color: AppColors.accent,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rebanho.nome,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'DM Sans',
                          ),
                        ),
                        const SizedBox(height: 2),
                        FutureBuilder<Map<String, String>>(
                          future: _pastoNomesFuture,
                          builder: (ctx, snap) {
                            final nome =
                                snap.data?[rebanho.pastoId] ?? rebanho.pastoId;
                            return Text(
                              nome,
                              style: const TextStyle(
                                color: AppColors.text4,
                                fontSize: 13,
                                fontFamily: 'DM Sans',
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              BovSecondaryButton(
                label: 'Mover Rebanho',
                icon: Icons.arrow_forward_rounded,
                onPressed: () {
                  Navigator.of(context).pop();
                  AppCoordinator.goToMoverRebanho(context);
                },
              ),

              const SizedBox(height: 8),

              BovDangerButton(
                label: 'Apagar Rebanho',
                icon: Icons.delete_outline_rounded,
                onPressed: () {
                  Navigator.of(context).pop();
                  _showConfirmarApagar(context, ref, rebanho);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // DIÁLOGO DE EXCLUSÃO
  // ===========================================================================

  void _showConfirmarApagar(
    BuildContext context,
    WidgetRef ref,
    RebanhoModel rebanho,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        title: const Text(
          'Apagar rebanho?',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            fontFamily: 'DM Sans',
          ),
        ),
        content: Text(
          'Esta ação é irreversível. O rebanho "${rebanho.nome}" será apagado permanentemente.',
          style: const TextStyle(
            color: AppColors.text4,
            fontSize: 14,
            fontFamily: 'DM Sans',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.text4, fontFamily: 'DM Sans'),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref
                  .read(rebanhoViewModelProvider.notifier)
                  .apagar(rebanhoId: rebanho.id);
              if (context.mounted) {
                showBovErrorSnackBar(context, 'Rebanho apagado.');
              }
            },
            child: const Text(
              'Apagar',
              style: TextStyle(
                color: AppColors.red,
                fontWeight: FontWeight.w600,
                fontFamily: 'DM Sans',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// ITEM DA LISTA
// =============================================================================

class _RebanhoItem extends StatelessWidget {
  const _RebanhoItem({
    required this.rebanho,
    required this.nomePasto,
    required this.onTap,
    required this.isFirst,
    required this.isLast,
  });

  final RebanhoModel rebanho;
  final String nomePasto;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          16,
          isFirst ? 14 : 10,
          16,
          isLast ? 14 : 10,
        ),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            // Ícone
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.accentBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.groups_rounded,
                color: AppColors.accent,
                size: 20,
              ),
            ),

            const SizedBox(width: 12),

            // Textos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rebanho.nome,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    nomePasto,
                    style: const TextStyle(
                      color: AppColors.text4,
                      fontSize: 12,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                ],
              ),
            ),

            // Badge "Ativo"
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.accentBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Ativo',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'DM Sans',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// EMPTY STATE
// =============================================================================

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.accentBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.groups_rounded,
              color: AppColors.accent,
              size: 34,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Nenhum rebanho',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'DM Sans',
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Cadastre o primeiro rebanho desta\npropriedade para começar.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.text4,
              fontSize: 13,
              fontFamily: 'DM Sans',
            ),
          ),
          const SizedBox(height: 28),
          BovPrimaryButton(
            label: 'Criar Rebanho',
            onPressed: () => AppCoordinator.goToNovoRebanho(context),
          ),
        ],
      ),
    );
  }
}
