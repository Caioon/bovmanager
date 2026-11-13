import 'package:bov_manager/core/navigation/app_coordinator.dart';
import 'package:bov_manager/view/app_shell.dart';
import 'package:bov_manager/core/theme/app_colors.dart';
import 'package:bov_manager/core/widgets/bov_widgets.dart';
import 'package:bov_manager/models/propriedade_model.dart';
import 'package:bov_manager/models/tarefa_model.dart';
import 'package:bov_manager/repositories/usuario_repository.dart';
import 'package:bov_manager/view/propriedade_screen.dart';
import 'package:bov_manager/viewmodels/acesso_compartilhado_viewmodel.dart';
import 'package:bov_manager/viewmodels/animal_viewmodel.dart';
import 'package:bov_manager/viewmodels/pasto_viewmodel.dart';
import 'package:bov_manager/viewmodels/propriedade_viewmodel.dart';
import 'package:bov_manager/viewmodels/rebanho_viewmodel.dart';
import 'package:bov_manager/viewmodels/tarefa_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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

            final animaisAsync = ref.watch(animaisListaProvider);
            final pastosAsync = ref.watch(pastosSelecionadosProvider);
            final rebanhoAsync = ref.watch(rebanhosSelecionadosProvider);

            final totalAnimais = animaisAsync.value?.length ?? 0;
            final totalPastos = pastosAsync.value?.length ?? 0;
            final totalRebanhos = rebanhoAsync.value?.length ?? 0;

            final String nomeFazenda = propriedade.nome;

            return Scaffold(
              backgroundColor: AppColors.background,
              body: SafeArea(
                child: Column(
                  children: [
                    // ── Header ────────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 10, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Fazenda',
                                  style: TextStyle(
                                    color: AppColors.text4,
                                    fontSize: 12,
                                    letterSpacing: 0.4,
                                    fontFamily: 'DM Sans',
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  nomeFazenda,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.text,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'DM Sans',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          _HeaderIconButton(
                            icon: Icons.format_list_bulleted_rounded,
                            tooltip: 'Trocar propriedade',
                            onTap: () => _showTrocarPropriedade(context, ref),
                          ),
                          _HeaderIconButton(
                            icon: Icons.share_outlined,
                            tooltip: 'Compartilhar propriedade',
                            onTap: () =>
                                _showCompartilhar(context, ref, propriedade),
                          ),
                        ],
                      ),
                    ),

                    // ── Corpo ─────────────────────────────────────────────
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                        child: _DashboardContent(
                          temCentroDefinido: propriedade.temCentroDefinido,
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

  // ===========================================================================
  // BOTTOM SHEET — trocar propriedade
  // ===========================================================================

  void _showTrocarPropriedade(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _TrocarPropriedadeSheet(ref: ref),
    );
  }

  // ===========================================================================
  // BOTTOM SHEET — compartilhar propriedade
  // ===========================================================================

  void _showCompartilhar(
    BuildContext context,
    WidgetRef ref,
    PropriedadeModel propriedade,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CompartilharSheet(propriedade: propriedade),
    );
  }
}

// =============================================================================
// BOTTOM SHEET DE COMPARTILHAMENTO
// =============================================================================

class _CompartilharSheet extends ConsumerStatefulWidget {
  const _CompartilharSheet({required this.propriedade});

  final PropriedadeModel propriedade;

  @override
  ConsumerState<_CompartilharSheet> createState() => _CompartilharSheetState();
}

class _CompartilharSheetState extends ConsumerState<_CompartilharSheet> {
  final _emailController = TextEditingController();
  PapelAcesso _papelSelecionado = PapelAcesso.espectador;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conviteState = ref.watch(conviteViewModelProvider);

    // Fecha o modal e exibe snackbar de sucesso quando envio der certo
    ref.listen<ConviteState>(conviteViewModelProvider, (_, next) {
      if (next.sucesso) {
        Navigator.of(context).pop();
        ref.read(conviteViewModelProvider.notifier).resetar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Convite enviado com sucesso!',
              style: TextStyle(color: AppColors.text, fontFamily: 'DM Sans'),
            ),
            backgroundColor: AppColors.card,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.accent),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
        return;
      }

      final erro = next.erro;
      if (erro != null) {
        showBovErrorSnackBar(context, erro);
        ref.read(conviteViewModelProvider.notifier).resetar();
      }
    });

    return Padding(
      // Sobe o sheet quando o teclado abre
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
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

              // Título e subtítulo
              const Text(
                'Compartilhar Propriedade',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'DM Sans',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.propriedade.nome,
                style: const TextStyle(
                  color: AppColors.text4,
                  fontSize: 12,
                  fontFamily: 'DM Sans',
                ),
              ),

              const SizedBox(height: 20),

              // Campo de e-mail
              const BovFieldLabel(label: 'E-MAIL DO USUÁRIO'),
              const SizedBox(height: 6),
              BovTextField(
                controller: _emailController,
                hintText: 'email@exemplo.com',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
              ),

              const SizedBox(height: 20),

              // Seleção de papel com checkboxes
              const BovFieldLabel(label: 'FUNÇÃO'),
              const SizedBox(height: 8),
              _PapelSelector(
                selecionado: _papelSelecionado,
                onChanged: (papel) => setState(() => _papelSelecionado = papel),
              ),

              const SizedBox(height: 24),

              // Botão confirmar
              BovPrimaryButton(
                label: 'Enviar Convite',
                isLoading: conviteState.isLoading,
                onPressed: () {
                  ref
                      .read(conviteViewModelProvider.notifier)
                      .enviarConvite(
                        propriedadeId: widget.propriedade.id,
                        email: _emailController.text,
                        papel: _papelSelecionado,
                      );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// SELETOR DE PAPEL COM CHECKBOXES EXCLUSIVOS
// =============================================================================

class _PapelSelector extends StatelessWidget {
  const _PapelSelector({required this.selecionado, required this.onChanged});

  final PapelAcesso selecionado;
  final ValueChanged<PapelAcesso> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: PapelAcesso.values.map((papel) {
          final isLast = papel == PapelAcesso.values.last;
          final isSelecionado = papel == selecionado;

          return GestureDetector(
            onTap: () => onChanged(papel),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : const Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  // Checkbox circular customizado
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelecionado
                          ? AppColors.accent
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelecionado
                            ? AppColors.accent
                            : AppColors.text3,
                        width: 1.5,
                      ),
                    ),
                    child: isSelecionado
                        ? const Icon(
                            Icons.check_rounded,
                            color: AppColors.onAccent,
                            size: 13,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  // Label e descrição
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          papel.label,
                          style: TextStyle(
                            color: isSelecionado
                                ? AppColors.text
                                : AppColors.text2,
                            fontSize: 14,
                            fontWeight: isSelecionado
                                ? FontWeight.w600
                                : FontWeight.w400,
                            fontFamily: 'DM Sans',
                          ),
                        ),
                        Text(
                          _descricaoPapel(papel),
                          style: const TextStyle(
                            color: AppColors.text4,
                            fontSize: 11,
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
        }).toList(),
      ),
    );
  }

  String _descricaoPapel(PapelAcesso papel) {
    switch (papel) {
      case PapelAcesso.administrador:
        return 'Acesso total à propriedade';
      case PapelAcesso.gerente:
        return 'Gerencia animais e tarefas';
      case PapelAcesso.espectador:
        return 'Apenas visualização';
    }
  }
}

// =============================================================================
// BOTTOM SHEET DE TROCA DE PROPRIEDADE
// =============================================================================

class _TrocarPropriedadeSheet extends ConsumerWidget {
  const _TrocarPropriedadeSheet({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef innerRef) {
    final listaAsync = innerRef.watch(propriedadesListaProvider);
    final selecionada = innerRef.watch(propriedadeSelecionadaProvider).value;
    final idsCompartilhadas =
        innerRef.watch(propriedadesCompartilhadasIdsProvider).value ?? {};

    return SafeArea(
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

            const Text(
              'Selecionar Propriedade',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'DM Sans',
              ),
            ),

            const SizedBox(height: 16),

            listaAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(color: AppColors.accent),
                ),
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
              data: (lista) => Column(
                children: lista.asMap().entries.map((entry) {
                  final prop = entry.value;
                  final isSelecionada = prop.id == selecionada?.id;
                  final isFirst = entry.key == 0;
                  final isLast = entry.key == lista.length - 1;

                  return GestureDetector(
                    onTap: () {
                      if (!isSelecionada) {
                        innerRef
                            .read(propriedadeSelecionadaProvider.notifier)
                            .selecionar(prop);
                      }
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isSelecionada
                            ? AppColors.accentBg
                            : AppColors.background,
                        borderRadius: BorderRadius.vertical(
                          top: isFirst
                              ? const Radius.circular(12)
                              : Radius.zero,
                          bottom: isLast
                              ? const Radius.circular(12)
                              : Radius.zero,
                        ),
                        border: Border(
                          left: BorderSide(
                            color: isSelecionada
                                ? AppColors.accent
                                : AppColors.border,
                          ),
                          right: BorderSide(
                            color: isSelecionada
                                ? AppColors.accent
                                : AppColors.border,
                          ),
                          top: isFirst
                              ? BorderSide(
                                  color: isSelecionada
                                      ? AppColors.accent
                                      : AppColors.border,
                                )
                              : BorderSide.none,
                          bottom: BorderSide(
                            color: isSelecionada
                                ? AppColors.accent
                                : AppColors.border,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isSelecionada
                                  // ignore: deprecated_member_use
                                  ? AppColors.accent.withOpacity(0.2)
                                  : AppColors.border2,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.home_work_rounded,
                              color: isSelecionada
                                  ? AppColors.accent
                                  : AppColors.text4,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  prop.nome,
                                  style: TextStyle(
                                    color: isSelecionada
                                        ? AppColors.accent
                                        : AppColors.text,
                                    fontSize: 14,
                                    fontWeight: isSelecionada
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    fontFamily: 'DM Sans',
                                  ),
                                ),
                                if (idsCompartilhadas.contains(prop.id)) ...[
                                  const SizedBox(height: 2),
                                  Row(
                                    children: const [
                                      Icon(
                                        Icons.people_alt_outlined,
                                        color: AppColors.text4,
                                        size: 11,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Propriedade compartilhada',
                                        style: TextStyle(
                                          color: AppColors.text4,
                                          fontSize: 11,
                                          fontFamily: 'DM Sans',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (isSelecionada)
                            const Icon(
                              Icons.check_rounded,
                              color: AppColors.accent,
                              size: 18,
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// CONTEÚDO PRINCIPAL
// =============================================================================

class _DashboardContent extends ConsumerWidget {
  const _DashboardContent({
    required this.temCentroDefinido,
    required this.totalAnimais,
    required this.totalRebanhos,
    required this.totalPastos,
    required this.isLoadingAnimais,
    required this.isLoadingPastos,
    required this.isLoadingRebanhos,
  });

  final bool temCentroDefinido;
  final int totalAnimais;
  final int totalRebanhos;
  final int totalPastos;
  final bool isLoadingAnimais;
  final bool isLoadingPastos;
  final bool isLoadingRebanhos;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tarefasAsync = ref.watch(tarefasListaProvider);

    ref.listen(tarefasViewModelProvider, (_, next) {
      if (!(ModalRoute.of(context)?.isCurrent ?? false)) return;
      next.whenOrNull(
        error: (e, _) => showBovErrorSnackBar(context, e.toString()),
      );
    });

    // Filtra só as tarefas de hoje e pendentes
    final hoje = DateTime.now();
    final tarefasHoje =
        tarefasAsync.value?.where((t) {
          final d = t.dataExecucao;
          return t.status == StatusTarefa.pendente &&
              d.year == hoje.year &&
              d.month == hoje.month &&
              d.day == hoje.day;
        }).toList() ??
        [];

    // Tarefas atrasadas: pendentes com data de execução anterior a hoje
    final inicioHoje = DateTime(hoje.year, hoje.month, hoje.day);
    final tarefasAtrasadas =
        tarefasAsync.value?.where((t) {
          final d = t.dataExecucao;
          final dia = DateTime(d.year, d.month, d.day);
          return t.status == StatusTarefa.pendente && dia.isBefore(inicioHoje);
        }).toList() ??
        [];

    // Tarefas de hoje já concluídas
    final tarefasConcluidasHoje =
        tarefasAsync.value?.where((t) {
          final d = t.dataExecucao;
          return t.status == StatusTarefa.concluida &&
              d.year == hoje.year &&
              d.month == hoje.month &&
              d.day == hoje.day;
        }).toList() ??
        [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Botões de mapa ────────────────────────────────────────────────
        if (!temCentroDefinido)
          _MapButton(
            label: 'Adicionar mapa para propriedade',
            icon: Icons.add_location_alt_outlined,
            destacado: true,
            onTap: () => AppCoordinator.goToConfigurarMapa(context),
          )
        else
          Row(
            children: [
              Expanded(
                child: _MapButton(
                  label: 'Ajustar mapa',
                  icon: Icons.settings_outlined,
                  onTap: () => AppCoordinator.goToConfigurarMapa(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MapButton(
                  label: 'Ver mapa',
                  icon: Icons.map_outlined,
                  destacado: true,
                  onTap: () => AppCoordinator.goToMapa(context),
                ),
              ),
            ],
          ),
        const SizedBox(height: 20),

        Row(
          children: [
            _MetricItem(
              icon: Icons.pets_rounded,
              value: isLoadingAnimais ? '—' : totalAnimais.toString(),
              label: 'Animais',
              iconColor: AppColors.accent,
              onTap: () => abaAtualShell.value = 2,
            ),
            const SizedBox(width: 10),
            _MetricItem(
              icon: Icons.list_alt_rounded,
              value: isLoadingRebanhos ? '—' : totalRebanhos.toString(),
              label: 'Rebanhos',
              iconColor: AppColors.accent,
              onTap: () => AppCoordinator.goToListaRebanhos(context),
            ),
            const SizedBox(width: 10),
            _MetricItem(
              icon: Icons.grass_rounded,
              value: isLoadingPastos ? '—' : totalPastos.toString(),
              label: 'Pastos',
              iconColor: AppColors.accent,
              onTap: () => AppCoordinator.goToListaPastos(context),
            ),
            const SizedBox(width: 10),
            _MetricItem(
              icon: Icons.warning_amber_rounded,
              value: tarefasAsync.isLoading
                  ? '—'
                  : tarefasAtrasadas.length.toString(),
              label: 'Alertas',
              iconColor: AppColors.red,
              onTap: () {},
            ),
          ],
        ),

        // ── Tarefas de hoje ───────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(top: 28, bottom: 12),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Tarefas de hoje',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'DM Sans',
                  ),
                ),
              ),
              _TextAction(
                label: 'Ver mais',
                color: AppColors.text2,
                onTap: () => AppCoordinator.goToListaTarefas(context),
              ),
              const SizedBox(width: 14),
              _TextAction(
                label: '+ Adicionar tarefa',
                color: AppColors.accent,
                bold: true,
                onTap: () => AppCoordinator.goToNovaTarefa(context),
              ),
            ],
          ),
        ),

        if (tarefasAsync.isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
          )
        else if (tarefasHoje.isEmpty)
          const _EmptyMessage(text: 'Nenhuma tarefa para hoje')
        else
          ...tarefasHoje.map(
            (tarefa) => _TarefaHojeItem(
              tarefa: tarefa,
              onConcluir: () => ref
                  .read(tarefasViewModelProvider.notifier)
                  .concluir(tarefaId: tarefa.id),
              onOpcoes: () => _mostrarOpcoesTarefa(context, ref, tarefa),
            ),
          ),

        // ── Alertas importantes ───────────────────────────────────────────
        const _SectionTitle(title: 'Alertas importantes'),
        if (tarefasAsync.isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
          )
        else if (tarefasAtrasadas.isEmpty)
          const _EmptyMessage(text: 'Nenhum alerta no momento')
        else
          ...tarefasAtrasadas.map(
            (tarefa) => _TarefaAtrasadaItem(
              tarefa: tarefa,
              onConcluir: () => ref
                  .read(tarefasViewModelProvider.notifier)
                  .concluir(tarefaId: tarefa.id),
              onOpcoes: () => _mostrarOpcoesTarefa(context, ref, tarefa),
            ),
          ),

        // ── Tarefas concluídas ────────────────────────────────────────────
        const _SectionTitle(title: 'Tarefas concluídas hoje'),
        if (tarefasConcluidasHoje.isEmpty)
          const _EmptyMessage(text: 'Nenhuma tarefa concluída hoje')
        else
          ...tarefasConcluidasHoje.map(
            (tarefa) => _TarefaConcluidaItem(
              tarefa: tarefa,
              onReabrir: () => ref
                  .read(tarefasViewModelProvider.notifier)
                  .reabrir(tarefa: tarefa),
            ),
          ),

        const SizedBox(height: 16),
      ],
    );
  }
}

// =============================================================================
// ITEM DE TAREFA CONCLUÍDA
// =============================================================================

class _TarefaConcluidaItem extends StatelessWidget {
  const _TarefaConcluidaItem({required this.tarefa, required this.onReabrir});

  final TarefaModel tarefa;
  final VoidCallback onReabrir;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Círculo marcado — toque para desfazer a conclusão
          GestureDetector(
            onTap: onReabrir,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AppColors.onAccent,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tarefa.titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.text4,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: AppColors.text4,
                    fontFamily: 'DM Sans',
                  ),
                ),
                if (tarefa.descricao.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    tarefa.descricao,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
        ],
      ),
    );
  }
}

// =============================================================================
// ITEM DE TAREFA ATRASADA (alerta)
// =============================================================================

class _TarefaAtrasadaItem extends StatelessWidget {
  const _TarefaAtrasadaItem({
    required this.tarefa,
    required this.onConcluir,
    required this.onOpcoes,
  });

  final TarefaModel tarefa;
  final VoidCallback onConcluir;
  final VoidCallback onOpcoes;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      decoration: BoxDecoration(
        color: AppColors.redBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.red),
      ),
      child: Row(
        children: [
          // Círculo — toque para concluir a tarefa
          GestureDetector(
            onTap: onConcluir,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.red, width: 1.5),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tarefa.titulo,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'DM Sans',
                  ),
                ),
                if (tarefa.descricao.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    tarefa.descricao,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.text4,
                      fontSize: 12,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  'Atrasada · ${DateFormat('dd/MM/yyyy').format(tarefa.dataExecucao)}',
                  style: const TextStyle(
                    color: AppColors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'DM Sans',
                  ),
                ),
              ],
            ),
          ),
          // Lápis — abre o modal de opções da tarefa
          GestureDetector(
            onTap: onOpcoes,
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Icon(Icons.edit_outlined, color: AppColors.text2, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// ITEM DE TAREFA DO DIA
// =============================================================================

class _TarefaHojeItem extends StatelessWidget {
  const _TarefaHojeItem({
    required this.tarefa,
    required this.onConcluir,
    required this.onOpcoes,
  });

  final TarefaModel tarefa;
  final VoidCallback onConcluir;
  final VoidCallback onOpcoes;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Círculo — toque para concluir a tarefa
          GestureDetector(
            onTap: onConcluir,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.text4, width: 1.5),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tarefa.titulo,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'DM Sans',
                  ),
                ),
                if (tarefa.descricao.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    tarefa.descricao,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
          // Lápis — abre o modal de opções da tarefa
          GestureDetector(
            onTap: onOpcoes,
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Icon(Icons.edit_outlined, color: AppColors.text2, size: 18),
            ),
          ),
        ],
      ),
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

/// Botão de ícone sem fundo usado no cabeçalho.
class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: AppColors.text, size: 22),
        ),
      ),
    );
  }
}

/// Botão largo dos mapas. [destacado] usa o tom de acento.
class _MapButton extends StatelessWidget {
  const _MapButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.destacado = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool destacado;

  @override
  Widget build(BuildContext context) {
    final fg = destacado ? AppColors.accent : AppColors.text;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: destacado ? AppColors.accentBg : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: destacado ? AppColors.accentBg : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: fg, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: fg,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'DM Sans',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(height: 10),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                  fontFamily: 'DM Sans',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.text4,
                  fontSize: 12,
                  fontFamily: 'DM Sans',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Texto clicável simples (sem caixa), usado ao lado do título de seção.
class _TextAction extends StatelessWidget {
  const _TextAction({
    required this.label,
    required this.color,
    required this.onTap,
    this.bold = false,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            fontFamily: 'DM Sans',
          ),
        ),
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
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.text,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          fontFamily: 'DM Sans',
        ),
      ),
    );
  }
}

/// Mensagem simples (sem card) para listas vazias.
class _EmptyMessage extends StatelessWidget {
  const _EmptyMessage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.text4,
        fontSize: 14,
        fontFamily: 'DM Sans',
      ),
    );
  }
}

// =============================================================================
// FLUXO DA TAREFA — modal de opções, editar, adiar e apagar
// =============================================================================

/// Abre o modal "Alterar tarefa" (título e descrição).
void _mostrarEditarInfoTarefa(
  BuildContext context,
  WidgetRef ref,
  TarefaModel tarefa,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.card,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _EditarInfoTarefaSheet(
      tarefa: tarefa,
      onSalvar: (titulo, descricao) {
        ref
            .read(tarefasViewModelProvider.notifier)
            .editar(
              tarefaId: tarefa.id,
              titulo: titulo,
              descricao: descricao,
              // Preserva data e hora atuais — este modal não altera data/hora
              dataExecucao: tarefa.dataExecucao,
              horaExecucaoMinutos: tarefa.horaExecucaoMinutos,
              clearHora: false,
            );
      },
    ),
  );
}

// ---------------------------------------------------------------------------
// Modal B — adiar: escolher data e horário
// ---------------------------------------------------------------------------

void _mostrarAdiarTarefa(
  BuildContext context,
  WidgetRef ref,
  TarefaModel tarefa,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.card,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _EditarDataHoraTarefaSheet(
      tarefa: tarefa,
      onSalvar: (novaData, horaExecucaoMinutos, clearHora) {
        // BUGFIX: clearHora estava sendo calculado no modal mas descartado
        // aqui — o adiar() do viewmodel/service/repository não tinha esse
        // parâmetro, e o método atualizarData() do repository nem gravava
        // horaExecucaoMinutos no Firestore. Resultado: o horário escolhido
        // (ou removido) ao adiar nunca era persistido — só era usado para
        // reagendar a notificação local, por isso a UI nunca refletia a
        // mudança. Corrigido em tarefa_viewmodel.dart, tarefa_service.dart
        // e tarefa_repository.dart (atualizarData).
        ref
            .read(tarefasViewModelProvider.notifier)
            .adiar(
              tarefaId: tarefa.id,
              novaData: novaData,
              titulo: tarefa.titulo,
              horaExecucaoMinutos: horaExecucaoMinutos,
              clearHora: clearHora,
            );
      },
    ),
  );
}

/// Abre o modal de opções da tarefa (editar, concluir, adiar, reabrir, apagar).
void _mostrarOpcoesTarefa(
  BuildContext context,
  WidgetRef ref,
  TarefaModel tarefa,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.card,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _TarefaOpcoes(
      tarefa: tarefa,
      onEditar: () {
        Navigator.of(context).pop();
        _mostrarEditarInfoTarefa(context, ref, tarefa);
      },
      onConcluir: () {
        Navigator.of(context).pop();
        ref
            .read(tarefasViewModelProvider.notifier)
            .concluir(tarefaId: tarefa.id);
      },
      onAdiar: () {
        Navigator.of(context).pop();
        _mostrarAdiarTarefa(context, ref, tarefa);
      },
      onReabrir: () {
        Navigator.of(context).pop();
        ref.read(tarefasViewModelProvider.notifier).reabrir(tarefa: tarefa);
      },
      onApagar: () {
        Navigator.of(context).pop();
        _mostrarConfirmarApagar(context, ref, tarefa);
      },
    ),
  );
}

// ---------------------------------------------------------------------------
// Confirmação de exclusão
// ---------------------------------------------------------------------------

void _mostrarConfirmarApagar(
  BuildContext context,
  WidgetRef ref,
  TarefaModel tarefa,
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
        'Apagar tarefa?',
        style: TextStyle(
          color: AppColors.text,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          fontFamily: 'DM Sans',
        ),
      ),
      content: Text(
        'A tarefa "${tarefa.titulo}" será apagada permanentemente.',
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
          onPressed: () {
            Navigator.of(ctx).pop();
            ref
                .read(tarefasViewModelProvider.notifier)
                .apagar(tarefaId: tarefa.id);
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

// =============================================================================
// MODAL DE OPÇÕES DA TAREFA
// =============================================================================

class _TarefaOpcoes extends StatelessWidget {
  const _TarefaOpcoes({
    required this.tarefa,
    required this.onEditar,
    required this.onConcluir,
    required this.onAdiar,
    required this.onReabrir,
    required this.onApagar,
  });

  final TarefaModel tarefa;
  final VoidCallback onEditar;
  final VoidCallback onConcluir;
  final VoidCallback onAdiar;
  final VoidCallback onReabrir;
  final VoidCallback onApagar;

  @override
  Widget build(BuildContext context) {
    final isConcluida = tarefa.status == StatusTarefa.concluida;

    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Alça
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Título da tarefa
                Text(
                  tarefa.titulo,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'DM Sans',
                  ),
                ),

                if (tarefa.descricao.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    tarefa.descricao,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.text4,
                      fontSize: 13,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Alterar — sempre disponível
                _OpcaoItem(
                  icon: Icons.edit_outlined,
                  iconColor: AppColors.accent,
                  iconBgColor: AppColors.accentBg,
                  titulo: 'Editar tarefa',
                  subtitulo: 'Editar título e descrição',
                  onTap: onEditar,
                ),

                const SizedBox(height: 10),

                // Concluir e Adiar — só se pendente
                if (!isConcluida) ...[
                  _OpcaoItem(
                    icon: Icons.check_circle_outline_rounded,
                    iconColor: AppColors.accent,
                    iconBgColor: AppColors.accentBg,
                    titulo: 'Concluir tarefa',
                    subtitulo: 'Marcar como concluída',
                    onTap: onConcluir,
                  ),
                  const SizedBox(height: 10),

                  _OpcaoItem(
                    icon: Icons.schedule_rounded,
                    iconColor: AppColors.accent,
                    iconBgColor: AppColors.accentBg,
                    titulo: 'Mudar dia ou horario da tarefa',
                    subtitulo: 'Escolher nova data e horário',
                    onTap: onAdiar,
                  ),
                  const SizedBox(height: 10),
                ],

                // Reabrir — só se concluída
                if (isConcluida) ...[
                  _OpcaoItem(
                    icon: Icons.radio_button_unchecked_rounded,
                    iconColor: AppColors.accent,
                    iconBgColor: AppColors.accentBg,
                    titulo: 'Desmarcar concluída',
                    subtitulo: 'Mover de volta para pendente',
                    onTap: onReabrir,
                  ),
                  const SizedBox(height: 10),
                ],

                // Apagar — sempre disponível
                _OpcaoItem(
                  icon: Icons.delete_outline_rounded,
                  iconColor: AppColors.red,
                  iconBgColor: AppColors.redBg,
                  titulo: 'Apagar tarefa',
                  subtitulo: 'Remover permanentemente',
                  onTap: onApagar,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// =============================================================================
// MODAL A — EDITAR TÍTULO E DESCRIÇÃO
// =============================================================================

class _EditarInfoTarefaSheet extends StatefulWidget {
  const _EditarInfoTarefaSheet({required this.tarefa, required this.onSalvar});

  final TarefaModel tarefa;
  final void Function(String titulo, String descricao) onSalvar;

  @override
  State<_EditarInfoTarefaSheet> createState() => _EditarInfoTarefaSheetState();
}

class _EditarInfoTarefaSheetState extends State<_EditarInfoTarefaSheet> {
  late final TextEditingController _tituloCtrl;
  late final TextEditingController _descricaoCtrl;

  @override
  void initState() {
    super.initState();
    _tituloCtrl = TextEditingController(text: widget.tarefa.titulo);
    _descricaoCtrl = TextEditingController(text: widget.tarefa.descricao);
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descricaoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Alça
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Alterar tarefa',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'DM Sans',
              ),
            ),
            const SizedBox(height: 20),
            const BovFieldLabel(label: 'TÍTULO'),
            const SizedBox(height: 6),
            BovTextField(controller: _tituloCtrl, hintText: 'Título da tarefa'),
            const SizedBox(height: 16),
            const BovFieldLabel(label: 'DESCRIÇÃO'),
            const SizedBox(height: 6),
            BovTextField(
              controller: _descricaoCtrl,
              hintText: 'Descrição (opcional)',
            ),
            const SizedBox(height: 24),
            BovPrimaryButton(
              label: 'Salvar alterações',
              onPressed: () {
                Navigator.of(context).pop();
                widget.onSalvar(
                  _tituloCtrl.text.trim(),
                  _descricaoCtrl.text.trim(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// MODAL B — ADIAR: SELECIONAR DATA E HORÁRIO
// =============================================================================

class _EditarDataHoraTarefaSheet extends StatefulWidget {
  const _EditarDataHoraTarefaSheet({
    required this.tarefa,
    required this.onSalvar,
  });

  final TarefaModel tarefa;
  final void Function(
    DateTime novaData,
    int? horaExecucaoMinutos,
    bool clearHora,
  )
  onSalvar;

  @override
  State<_EditarDataHoraTarefaSheet> createState() =>
      _EditarDataHoraTarefaSheetState();
}

class _EditarDataHoraTarefaSheetState
    extends State<_EditarDataHoraTarefaSheet> {
  late DateTime _dataExecucao;
  TimeOfDay? _horaExecucao;

  @override
  void initState() {
    super.initState();
    // Adiar começa com uma data futura como padrão
    _dataExecucao = widget.tarefa.dataExecucao.isAfter(DateTime.now())
        ? widget.tarefa.dataExecucao
        : DateTime.now();

    // Preserva o horário atual da tarefa, se houver
    final minutos = widget.tarefa.horaExecucaoMinutos;
    if (minutos != null) {
      _horaExecucao = TimeOfDay(hour: minutos ~/ 60, minute: minutos % 60);
    }
  }

  Future<void> _escolherData(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataExecucao,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.accent,
            surface: AppColors.card,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dataExecucao = picked);
  }

  // BUGFIX: antes este método só era chamado quando _horaExecucao != null
  // (o onTap do container ficava `null` quando não havia horário ainda),
  // então era impossível abrir o picker para DEFINIR um horário pela
  // primeira vez tocando no campo — só o botão "+" lateral funcionava.
  // Agora o campo principal sempre abre o picker, tenha ou não horário já
  // selecionado.
  Future<void> _escolherHora(BuildContext context) async {
    final initial = _horaExecucao ?? const TimeOfDay(hour: 8, minute: 0);
    final picked = await showBovTimePicker(
      context: context,
      initialHour: initial.hour,
      initialMinute: initial.minute,
    );
    if (picked != null) {
      setState(() => _horaExecucao = picked);
    }
  }

  int? get _horaEmMinutos => _horaExecucao != null
      ? _horaExecucao!.hour * 60 + _horaExecucao!.minute
      : null;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Alça
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Adiar tarefa',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'DM Sans',
              ),
            ),
            const SizedBox(height: 20),

            // ── Data de Execução ─────────────────────────────────────────
            const BovFieldLabel(label: 'NOVA DATA DE EXECUÇÃO'),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => _escolherData(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      color: AppColors.text4,
                      size: 16,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      DateFormat('dd/MM/yyyy').format(_dataExecucao),
                      style: const TextStyle(
                        color: AppColors.text,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Horário de Execução (opcional) ───────────────────────────
            Row(
              children: [
                const BovFieldLabel(label: 'HORÁRIO DE EXECUÇÃO'),
                const Spacer(),
                const Text(
                  'Opcional',
                  style: TextStyle(
                    color: AppColors.text4,
                    fontSize: 11,
                    fontFamily: 'DM Sans',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    // BUGFIX: onTap não é mais condicional a
                    // _horaExecucao != null — agora sempre abre o picker.
                    onTap: () => _escolherHora(context),
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: _horaExecucao != null
                            ? AppColors.card
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _horaExecucao != null
                              ? AppColors.accent
                              : AppColors.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            color: _horaExecucao != null
                                ? AppColors.accent
                                : AppColors.text4,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _horaExecucao != null
                                ? _horaExecucao!.format(context)
                                : 'Sem horário',
                            style: TextStyle(
                              color: _horaExecucao != null
                                  ? AppColors.text
                                  : AppColors.text4,
                              fontSize: 14,
                              fontFamily: 'DM Sans',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Toggle +/×
                GestureDetector(
                  onTap: () {
                    if (_horaExecucao != null) {
                      setState(() => _horaExecucao = null);
                    } else {
                      _escolherHora(context);
                    }
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _horaExecucao != null
                          ? AppColors.redBg
                          : AppColors.accentBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _horaExecucao != null
                            ? AppColors.red
                            : AppColors.accent,
                      ),
                    ),
                    child: Icon(
                      _horaExecucao != null
                          ? Icons.close_rounded
                          : Icons.add_rounded,
                      color: _horaExecucao != null
                          ? AppColors.red
                          : AppColors.accent,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            BovPrimaryButton(
              label: 'Confirmar adiamento',
              onPressed: () {
                final clearHora =
                    widget.tarefa.horaExecucaoMinutos != null &&
                    _horaExecucao == null;
                Navigator.of(context).pop();
                widget.onSalvar(_dataExecucao, _horaEmMinutos, clearHora);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// ITEM DE OPÇÃO DO MODAL
// =============================================================================

class _OpcaoItem extends StatelessWidget {
  const _OpcaoItem({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'DM Sans',
                  ),
                ),
                Text(
                  subtitulo,
                  style: const TextStyle(
                    color: AppColors.text4,
                    fontSize: 12,
                    fontFamily: 'DM Sans',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
