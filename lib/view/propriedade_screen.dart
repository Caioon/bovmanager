import 'package:bov_manager/core/navigation/app_coordinator.dart';
import 'package:bov_manager/core/theme/app_colors.dart';
import 'package:bov_manager/core/widgets/bov_widgets.dart';
import 'package:bov_manager/models/propriedade_model.dart';
import 'package:bov_manager/viewmodels/propriedade_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class PropriedadesScreen extends ConsumerWidget {
  const PropriedadesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listaState = ref.watch(propriedadesListaProvider);

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
                  const Text(
                    'Propriedades',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      AppCoordinator.goToNovaPropriedade(context);
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
                data: (lista) => lista.isEmpty
                    ? _EmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                        itemCount: lista.length + 1,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          if (i == lista.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: BovSecondaryButton(
                                label: 'Adicionar Propriedade',
                                icon: Icons.add_rounded,
                                onPressed: () {
                                  AppCoordinator.goToNovaPropriedade(context);
                                },
                              ),
                            );
                          }
                          return _PropriedadeCard(
                            propriedade: lista[i],
                            // Na PropriedadesScreen, ao tocar no card:
                            onTap: () {
                              ref
                                  .read(
                                    propriedadeEmVisualizacaoProvider.notifier,
                                  )
                                  .abrir(lista[i]);
                              AppCoordinator.goToDetalhesPropriedade(context);
                            },
                          );
                        },
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
// CARD DE PROPRIEDADE
// =============================================================================

class _PropriedadeCard extends StatelessWidget {
  const _PropriedadeCard({required this.propriedade, required this.onTap});

  final PropriedadeModel propriedade;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dataCadastro = DateFormat(
      'dd/MM/yyyy',
    ).format(propriedade.dataCadastro);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.accentBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.home_work_rounded,
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
                    propriedade.nome,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Cadastrada em $dataCadastro',
                    style: const TextStyle(
                      color: AppColors.text4,
                      fontSize: 12,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.text4,
              size: 18,
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
              Icons.home_work_outlined,
              color: AppColors.accent,
              size: 34,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Nenhuma propriedade',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'DM Sans',
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Adicione sua primeira fazenda para\ncomeçar a gerenciar seu rebanho.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.text4,
              fontSize: 13,
              fontFamily: 'DM Sans',
            ),
          ),
          const SizedBox(height: 28),
          BovPrimaryButton(
            label: 'Adicionar Propriedade',
            onPressed: () {
              AppCoordinator.goToNovaPropriedade(context);
            },
          ),
        ],
      ),
    );
  }
}
