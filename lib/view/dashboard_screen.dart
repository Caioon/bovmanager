import 'package:bov_manager/core/navigation/app_coordinator.dart';
import 'package:bov_manager/core/theme/app_colors.dart';
import 'package:bov_manager/core/widgets/bov_widgets.dart';
import 'package:bov_manager/repositories/usuario_repository.dart';
import 'package:bov_manager/viewmodels/animal_viewmodel.dart';
import 'package:bov_manager/viewmodels/pasto_viewmodel.dart';
import 'package:bov_manager/viewmodels/propriedade_viewmodel.dart';
import 'package:bov_manager/viewmodels/rebanho_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuarioAsync = ref.watch(usuarioAtualProvider);

    return usuarioAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) =>
          Scaffold(body: Center(child: Text('Erro ao carregar usuário:\n$e'))),
      data: (usuario) {
        if (usuario == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final propriedadeAsync = ref.watch(propriedadeSelecionadaProvider);

        return propriedadeAsync.when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (e, _) => Scaffold(body: Center(child: Text(e.toString()))),
          data: (propriedade) {
            if (propriedade == null) {
              return Scaffold(
                backgroundColor: AppColors.background,
                body: SafeArea(child: _EmptyState()),
              );
            }

            // Lê os dados reais dos providers existentes
            final animaisAsync = ref.watch(animaisListaProvider);

            final pastosAsync = ref.watch(pastosSelecionadosProvider);
            final rebanhoAsync = ref.watch(rebanhosSelecionadosProvider);

            final totalAnimais = animaisAsync.value?.length ?? 0;
            final totalPastos = pastosAsync.value?.length ?? 0;
            final totalRebanhos = rebanhoAsync.value?.length ?? 0;

            final String nomeUsuario = usuario.nome;
            final String nomeFazenda = propriedade.nome;

            return Scaffold(
              backgroundColor: AppColors.background,
              body: SafeArea(
                child: Column(
                  children: [
                    // ── Header ────────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Olá, $nomeUsuario 👋',
                                style: const TextStyle(
                                  color: AppColors.text4,
                                  fontSize: 12,
                                  fontFamily: 'DM Sans',
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                nomeFazenda,
                                style: const TextStyle(
                                  color: AppColors.text,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'DM Sans',
                                ),
                              ),
                            ],
                          ),
                          // Botão de notificações
                          GestureDetector(
                            onTap: () {
                              // TODO: AppCoordinator.goToNotificacoes(context);
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
                                Icons.notifications_outlined,
                                color: AppColors.text2,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Corpo ─────────────────────────────────────────────
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                        child: _DashboardContent(
                          totalAnimais: totalAnimais,
                          totalRebanhos: totalRebanhos,
                          totalPastos: totalPastos,
                          isLoadingAnimais: animaisAsync.isLoading,
                          isLoadingPastos: pastosAsync.isLoading,
                          isLoadingRebanhos: rebanhoAsync.isLoading,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// =============================================================================
// CONTEÚDO PRINCIPAL (quando há propriedade selecionada)
// =============================================================================

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.totalAnimais,
    required this.totalRebanhos,
    required this.totalPastos,
    required this.isLoadingAnimais,
    required this.isLoadingPastos,
    required this.isLoadingRebanhos,
  });

  final int totalAnimais;
  final int totalRebanhos;
  final int totalPastos;
  final bool isLoadingAnimais;
  final bool isLoadingPastos;
  final bool isLoadingRebanhos;

  // Alertas ficam zerados até o módulo de alertas ser implementado
  static const int totalAlertas = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Métricas ──────────────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: Icons.pets_rounded,
                value: totalAnimais.toString(),
                label: 'Animais',
                iconBgColor: AppColors.accentBg,
                iconColor: AppColors.accent,
                isLoading: isLoadingAnimais,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                icon: Icons.list_alt_rounded,
                value: totalRebanhos.toString(),
                label: 'Rebanhos',
                iconBgColor: AppColors.accentBg,
                iconColor: AppColors.accent,
                isLoading: isLoadingRebanhos,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: Icons.grass_rounded,
                value: totalPastos.toString(),
                label: 'Pastos',
                iconBgColor: AppColors.accentBg,
                iconColor: AppColors.accent,
                isLoading: isLoadingPastos,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                icon: Icons.warning_amber_rounded,
                value: totalAlertas.toString(),
                label: 'Alertas',
                iconBgColor: AppColors.redBg,
                iconColor: AppColors.red,
                valueColor: totalAlertas > 0 ? AppColors.red : null,
              ),
            ),
          ],
        ),

        // ── Tarefas do dia ────────────────────────────────────────────────
        const _SectionTitle(title: 'TAREFAS DO DIA'),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: const Center(
            child: Text(
              'Nenhuma tarefa para hoje',
              style: TextStyle(
                color: AppColors.text4,
                fontSize: 13,
                fontFamily: 'DM Sans',
              ),
            ),
          ),
        ),
        // TODO: Substituir bloco acima pela lista real de tarefas do dia
        // quando o módulo de Tarefas for implementado.

        // ── Alertas importantes ───────────────────────────────────────────
        const _SectionTitle(title: 'ALERTAS IMPORTANTES'),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: const Center(
            child: Text(
              'Nenhum alerta no momento',
              style: TextStyle(
                color: AppColors.text4,
                fontSize: 13,
                fontFamily: 'DM Sans',
              ),
            ),
          ),
        ),

        // TODO: Substituir bloco acima pelos alertas reais (superlotação, etc.)
        // quando o módulo de Alertas/Pastos for implementado.
        const SizedBox(height: 16),
      ],
    );
  }
}

// =============================================================================
// EMPTY STATE (sem propriedade)
// =============================================================================

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 60),
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
          'Cadastre sua primeira fazenda\npara começar a usar o BovManager.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.text4,
            fontSize: 13,
            fontFamily: 'DM Sans',
          ),
        ),
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: BovPrimaryButton(
            label: 'Cadastrar Propriedade',
            onPressed: () => AppCoordinator.goToNovaPropriedade(context),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// WIDGETS INTERNOS
// =============================================================================

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconBgColor,
    required this.iconColor,
    this.valueColor,
    this.isLoading = false,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color iconBgColor;
  final Color iconColor;
  final Color? valueColor;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(height: 10),
          isLoading
              ? const SizedBox(
                  height: 28,
                  width: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.accent,
                  ),
                )
              : Text(
                  value,
                  style: TextStyle(
                    color: valueColor ?? AppColors.text,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'DM Sans',
                  ),
                ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.text4,
              fontSize: 11,
              fontFamily: 'DM Sans',
            ),
          ),
        ],
      ),
    );
  }
}

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
