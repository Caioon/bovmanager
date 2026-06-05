import 'package:bov_manager/core/navigation/app_coordinator.dart';
import 'package:bov_manager/core/theme/app_colors.dart';
import 'package:bov_manager/core/widgets/bov_widgets.dart';
import 'package:bov_manager/repositories/usuario_repository.dart';
import 'package:bov_manager/services/notification_service.dart';
import 'package:bov_manager/viewmodels/notificacao_viewmodel.dart';
import 'package:bov_manager/viewmodels/usuario_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DetalhesPerfilScreen extends ConsumerWidget {
  const DetalhesPerfilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuarioAsync = ref.watch(usuarioAtualProvider);
    final notificacoesAsync = ref.watch(notificacaoViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: usuarioAsync.when(
          data: (usuario) {
            if (usuario == null) {
              return const Center(
                child: Text(
                  'Usuário não encontrado',
                  style: TextStyle(color: AppColors.text),
                ),
              );
            }

            return Column(
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
                            "Meus dados",
                            style: const TextStyle(
                              color: AppColors.text,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'DM Sans',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                // ── Conteúdo ─────────────────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _campo(
                          context,
                          titulo: 'Nome',
                          valor: usuario.nome,
                          onPressed: () => AppCoordinator.goToAlterarNome(
                            context,
                            nomeAtual: usuario.nome,
                          ),
                        ),

                        const SizedBox(height: 16),

                        _campo(
                          context,
                          titulo: 'Email',
                          valor: usuario.email,
                          onPressed: () => _pedirSenhaENavegar(
                            context,
                            ref,
                            onSenhaConfirmada: (senha) =>
                                AppCoordinator.goToAlterarEmail(
                                  context,
                                  emailAtual: usuario.email,
                                  senhaAtual: senha,
                                ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        _campo(
                          context,
                          titulo: 'CPF',
                          valor: usuario.cpf,
                          onPressed: () => AppCoordinator.goToAlterarCpf(
                            context,
                            cpfAtual: usuario.cpf,
                          ),
                        ),

                        const SizedBox(height: 32),

                        BovSecondaryButton(
                          label: 'Alterar Senha',
                          icon: Icons.lock_outline,
                          onPressed: () => _pedirSenhaENavegar(
                            context,
                            ref,
                            onSenhaConfirmada: (senha) =>
                                AppCoordinator.goToAlterarSenha(
                                  context,
                                  senhaAtual: senha,
                                ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ── Toggle geral de notificações ─────────────────────
                        _NotificacaoToggle(notificacoesAsync: notificacoesAsync),

                        const SizedBox(height: 12),

                        // ── Preferências por slot ────────────────────────────
                        const _NotificacaoSlotsSection(),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
          error: (e, st) => Center(
            child: Text(
              e.toString(),
              style: const TextStyle(color: AppColors.red),
            ),
          ),
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
        ),
      ),
    );
  }

  Widget _campo(
    BuildContext context, {
    required String titulo,
    required String valor,
    required VoidCallback onPressed,
  }) {
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
          Text(
            titulo,
            style: const TextStyle(color: AppColors.text4, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            valor,
            style: const TextStyle(color: AppColors.text, fontSize: 16),
          ),
          const SizedBox(height: 16),
          BovSecondaryButton(
            label: 'Alterar $titulo',
            icon: Icons.edit_outlined,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }

  void _pedirSenhaENavegar(
    BuildContext context,
    WidgetRef ref, {
    required void Function(String senha) onSenhaConfirmada,
  }) {
    final controller = TextEditingController();
    bool obscure = true;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (_, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.card,
              title: const Text(
                'Confirmar senha',
                style: TextStyle(color: AppColors.text),
              ),
              content: TextField(
                controller: controller,
                obscureText: obscure,
                style: const TextStyle(color: AppColors.text),
                decoration: InputDecoration(
                  labelText: 'Senha atual',
                  labelStyle: const TextStyle(color: AppColors.text4),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.accent),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.text4,
                    ),
                    onPressed: () => setDialogState(() => obscure = !obscure),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: AppColors.text4),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.onAccent,
                  ),
                  onPressed: () async {
                    final senha = controller.text.trim();
                    if (senha.isEmpty) return;

                    try {
                      await ref
                          .read(usuarioViewModelProvider.notifier)
                          .verificarSenha(senha);

                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                      }
                      if (context.mounted) {
                        onSenhaConfirmada(senha);
                      }
                    } catch (e) {
                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                      }
                      if (context.mounted) {
                        showBovErrorSnackBar(
                          context,
                          e.toString().replaceAll('Exception: ', ''),
                        );
                      }
                    }
                  },
                  child: const Text('Continuar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// =============================================================================
// TOGGLE GERAL DE NOTIFICAÇÕES
// =============================================================================

class _NotificacaoToggle extends ConsumerWidget {
  const _NotificacaoToggle({required this.notificacoesAsync});

  final AsyncValue<bool> notificacoesAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ativo = notificacoesAsync.asData?.value ?? true;
    final carregando = notificacoesAsync.isLoading;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: ativo ? AppColors.accentBg : AppColors.border2,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              ativo
                  ? Icons.notifications_active_outlined
                  : Icons.notifications_off_outlined,
              color: ativo ? AppColors.accent : AppColors.text4,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notificações de tarefas',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'DM Sans',
                  ),
                ),
                Text(
                  ativo
                      ? 'Lembretes de tarefa ativados'
                      : 'Notificações desativadas',
                  style: const TextStyle(
                    color: AppColors.text4,
                    fontSize: 12,
                    fontFamily: 'DM Sans',
                  ),
                ),
              ],
            ),
          ),
          carregando
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.accent,
                  ),
                )
              : Switch(
                  value: ativo,
                  onChanged: (_) =>
                      ref.read(notificacaoViewModelProvider.notifier).alternar(),
                  // ignore: deprecated_member_use
                  activeColor: AppColors.accent,
                  inactiveTrackColor: AppColors.border2,
                ),
        ],
      ),
    );
  }
}

// =============================================================================
// PREFERÊNCIAS GRANULARES POR SLOT
// =============================================================================

class _NotificacaoSlotsSection extends ConsumerWidget {
  const _NotificacaoSlotsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalAtivo = ref.watch(notificacaoViewModelProvider).asData?.value ?? true;
    final slotsAsync = ref.watch(notificacaoSlotsViewModelProvider);
    final slots = slotsAsync.asData?.value ?? {};

    return Opacity(
      opacity: globalAtivo ? 1.0 : 0.4,
      child: IgnorePointer(
        ignoring: !globalAtivo,
        child: Column(
          children: [
            // ── Tarefas sem horário ──────────────────────────────────────────
            _GrupoSlots(
              titulo: 'Tarefas sem horário definido',
              icone: Icons.calendar_today_outlined,
              itens: [
                _SlotConfig(
                  label: 'Dia anterior às 8h',
                  subtitulo: '24h antes da tarefa',
                  chave: NotificationService.kSemHorario24h,
                ),
                _SlotConfig(
                  label: 'Às 8h do dia da tarefa',
                  chave: NotificationService.kSemHorario8h,
                ),
                _SlotConfig(
                  label: 'Às 12h do dia da tarefa',
                  chave: NotificationService.kSemHorario12h,
                ),
                _SlotConfig(
                  label: 'Às 16h do dia da tarefa',
                  chave: NotificationService.kSemHorario16h,
                ),
              ],
              slots: slots,
              onAlternar: (chave) => ref
                  .read(notificacaoSlotsViewModelProvider.notifier)
                  .alternarSlot(chave),
            ),

            const SizedBox(height: 12),

            // ── Tarefas com horário ──────────────────────────────────────────
            _GrupoSlots(
              titulo: 'Tarefas com horário definido',
              icone: Icons.schedule_outlined,
              itens: [
                _SlotConfig(
                  label: 'Dia anterior',
                  subtitulo: '24h antes',
                  chave: NotificationService.kComHorario24h,
                ),
                _SlotConfig(
                  label: '12 horas antes',
                  chave: NotificationService.kComHorario12h,
                ),
                _SlotConfig(
                  label: '6 horas antes',
                  chave: NotificationService.kComHorario6h,
                ),
                _SlotConfig(
                  label: '1 hora antes',
                  chave: NotificationService.kComHorario1h,
                ),
                _SlotConfig(
                  label: '15 minutos antes',
                  chave: NotificationService.kComHorario15min,
                ),
                _SlotConfig(
                  label: 'No momento da execução',
                  chave: NotificationService.kComHorarioImediata,
                ),
              ],
              slots: slots,
              onAlternar: (chave) => ref
                  .read(notificacaoSlotsViewModelProvider.notifier)
                  .alternarSlot(chave),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// GRUPO DE SLOTS (card com cabeçalho + lista de toggles)
// =============================================================================

class _GrupoSlots extends StatelessWidget {
  const _GrupoSlots({
    required this.titulo,
    required this.icone,
    required this.itens,
    required this.slots,
    required this.onAlternar,
  });

  final String titulo;
  final IconData icone;
  final List<_SlotConfig> itens;
  final Map<String, bool> slots;
  final void Function(String chave) onAlternar;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho do grupo
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Icon(icone, color: AppColors.text4, size: 15),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: const TextStyle(
                    color: AppColors.text4,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                    fontFamily: 'DM Sans',
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Linhas de toggle
          ...itens.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            final isLast = i == itens.length - 1;
            return _SlotToggleRow(
              config: item,
              ativo: slots[item.chave] ?? true,
              onAlternar: () => onAlternar(item.chave),
              showDivider: !isLast,
            );
          }),
        ],
      ),
    );
  }
}

// =============================================================================
// LINHA DE TOGGLE INDIVIDUAL
// =============================================================================

class _SlotToggleRow extends StatelessWidget {
  const _SlotToggleRow({
    required this.config,
    required this.ativo,
    required this.onAlternar,
    required this.showDivider,
  });

  final _SlotConfig config;
  final bool ativo;
  final VoidCallback onAlternar;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      config.label,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 14,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                    if (config.subtitulo != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        config.subtitulo!,
                        style: const TextStyle(
                          color: AppColors.text4,
                          fontSize: 12,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Switch(
                value: ativo,
                onChanged: (_) => onAlternar(),
                // ignore: deprecated_member_use
                activeColor: AppColors.accent,
                inactiveTrackColor: AppColors.border2,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.border),
      ],
    );
  }
}

// =============================================================================
// DADOS DE CONFIGURAÇÃO DE UM SLOT
// =============================================================================

class _SlotConfig {
  const _SlotConfig({
    required this.label,
    required this.chave,
    this.subtitulo,
  });

  final String label;
  final String chave;
  final String? subtitulo;
}
