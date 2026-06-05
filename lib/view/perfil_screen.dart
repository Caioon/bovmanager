import 'package:bov_manager/core/navigation/app_coordinator.dart';
import 'package:bov_manager/core/theme/app_colors.dart';
import 'package:bov_manager/core/widgets/bov_widgets.dart';
import 'package:bov_manager/repositories/usuario_repository.dart';
import 'package:bov_manager/services/notification_service.dart';
import 'package:bov_manager/viewmodels/usuario_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PerfilScreen extends ConsumerWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(usuarioViewModelProvider);
    final usuario = ref.watch(usuarioAtualProvider).value;

    if (usuario == null) {
      return Center(child: CircularProgressIndicator(color: AppColors.accent));
    }

    final nomeUsuario = usuario.nome;
    final isLoadingLogout = state.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const Spacer(),
                    const BovLogo(),
                    const SizedBox(height: 40),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'DM Sans',
                        ),
                        children: [
                          const TextSpan(
                            text: 'Bem-vindo, ',
                            style: TextStyle(color: AppColors.text),
                          ),
                          TextSpan(
                            text: '$nomeUsuario!',
                            style: const TextStyle(color: AppColors.accent),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Você está conectado ao BovManager.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.text4,
                        fontSize: 14,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                    const Spacer(),
                    BovSecondaryButton(
                      label: 'Nova Tarefa',
                      icon: Icons.add_task,
                      onPressed: () => AppCoordinator.goToNovaTarefa(context),
                    ),
                    const SizedBox(height: 10),
                    BovSecondaryButton(
                      label: 'Lista de Tarefas',
                      icon: Icons.task,
                      onPressed: () => AppCoordinator.goToListaTarefas(context),
                    ),
                    const SizedBox(height: 10),
                    BovSecondaryButton(
                      label: 'Ver Dados',
                      icon: Icons.person_outline,
                      onPressed: () =>
                          AppCoordinator.goToDetalhesPerfil(context),
                    ),
                    const SizedBox(height: 10),
                    BovSecondaryButton(
                      label: 'Mapa da Propriedade',
                      icon: Icons.map_outlined,
                      onPressed: () => AppCoordinator.goToMapa(context),
                    ),
                    const SizedBox(height: 10),
                    BovSecondaryButton(
                      label: 'Configuração de mapa',
                      icon: Icons.map_outlined,
                      onPressed: () =>
                          AppCoordinator.goToConfigurarMapa(context),
                    ),
                    const SizedBox(height: 30),

                    // ── Testes de notificação ──────────────────────────────
                    BovSecondaryButton(
                      label: 'Testar Notificação Imediata',
                      icon: Icons.notifications_active_outlined,
                      onPressed: () async {
                        await ref
                            .read(notificationServiceProvider)
                            .mostrarNotificacaoAgora();
                        if (context.mounted) {
                          showBovErrorSnackBar(context, 'Notificação ativada.');
                        }
                      },
                    ),
                    const SizedBox(height: 10),

                    BovSecondaryButton(
                      label: 'Testar Notificação (5s)',
                      icon: Icons.notifications_active_outlined,
                      onPressed: () async {
                        await ref
                            .read(notificationServiceProvider)
                            .dispararNotificacaoTeste();
                        if (context.mounted) {
                          showBovErrorSnackBar(
                            context,
                            'Notificação agendada — chegará em 5 segundos.',
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 10),

                    // ── Logout ─────────────────────────────────────────────
                    BovDangerButton(
                      label: 'Sair da conta',
                      icon: Icons.logout_rounded,
                      isLoading: isLoadingLogout,
                      onPressed: () {
                        ref.read(usuarioViewModelProvider.notifier).logout();
                      },
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
