import 'package:bov_manager/core/navigation/app_coordinator.dart';
import 'package:bov_manager/core/theme/app_colors.dart';
import 'package:bov_manager/core/widgets/bov_widgets.dart';
import 'package:bov_manager/models/pasto_model.dart';
import 'package:bov_manager/models/rebanho_model.dart';
import 'package:bov_manager/services/rebanho_service.dart';
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
  /// Monta o mapa {pastoId → nomePasto} a partir do estado atual do provider.
  /// Como é derivado de um `watch`, atualiza sozinho quando um pasto é criado.
  Map<String, String> _nomesPastos(AsyncValue<List<PastoModel>> pastosAsync) {
    return {for (final p in pastosAsync.value ?? <PastoModel>[]) p.id: p.nome};
  }

  String _nomeDoPasto(
    AsyncValue<List<PastoModel>> pastosAsync,
    String pastoId,
  ) {
    final nome = _nomesPastos(pastosAsync)[pastoId];
    if (nome != null) return nome;
    if (pastosAsync.isLoading && !pastosAsync.hasValue) return 'Carregando...';
    return 'Pasto não encontrado ou apagado';
  }

  @override
  Widget build(BuildContext context) {
    final rebanhoListaState = ref.watch(rebanhoListaProvider);
    final pastosAsync = ref.watch(pastosListaPropEmVisualizacaoProvider);

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
                    onTap: () {
                      final propriedadeId =
                          ref.read(propriedadeEmVisualizacaoProvider)?.id ?? '';
                      AppCoordinator.goToNovoRebanho(
                        context,
                        propriedadeId: propriedadeId,
                      );
                    },
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
              child: rebanhoListaState.when(
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
                                  nomePasto: _nomeDoPasto(
                                    pastosAsync,
                                    e.value.pastoId,
                                  ),
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
                        Consumer(
                          builder: (ctx, sheetRef, _) {
                            final nome = _nomeDoPasto(
                              sheetRef.watch(
                                pastosListaPropEmVisualizacaoProvider,
                              ),
                              rebanho.pastoId,
                            );
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

  Future<void> _showConfirmarApagar(
    BuildContext context,
    WidgetRef ref,
    RebanhoModel rebanho,
  ) async {
    final propriedadeId =
        ref.read(propriedadeEmVisualizacaoProvider)?.id ?? '';

    final bloqueio = await ref
        .read(rebanhoServiceProvider)
        .podeApagarRebanho(
          rebanhoId: rebanho.id,
          propriedadeId: propriedadeId,
        );

    if (!context.mounted) return;

    if (bloqueio != null) {
      showBovErrorSnackBar(context, bloqueio);
      return;
    }

    await showBovConfirmDialog(
      context: context,
      icon: Icons.delete_outline_rounded,
      titulo: 'Apagar rebanho?',
      descricao:
          'Esta ação é irreversível. O rebanho será apagado permanentemente.',
      textoConfirmar: 'Apagar',
      destrutivo: true,
      onConfirmar: () async {
        await ref
            .read(rebanhoViewModelProvider.notifier)
            .apagarRebanho(rebanhoId: rebanho.id);
        if (context.mounted) {
          showBovErrorSnackBar(context, 'Rebanho apagado.');
        }
      },
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
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// EMPTY STATE
// =============================================================================

class _EmptyState extends ConsumerWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            onPressed: () {
              final propriedadeId =
                  ref.read(propriedadeEmVisualizacaoProvider)?.id ?? '';
              AppCoordinator.goToNovoRebanho(
                context,
                propriedadeId: propriedadeId,
              );
            },
          ),
        ],
      ),
    );
  }
}
