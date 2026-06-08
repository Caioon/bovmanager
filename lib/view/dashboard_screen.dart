import 'package:bov_manager/core/navigation/app_coordinator.dart';
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
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Nome e fazenda
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Text(
                                //   'Olá, $nomeUsuario 👋',
                                //   style: const TextStyle(
                                //     color: AppColors.text4,
                                //     fontSize: 12,
                                //     fontFamily: 'DM Sans',
                                //   ),
                                // ),
                                // const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        "Fazenda: $nomeFazenda",
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: AppColors.text,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'DM Sans',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Botão trocar propriedade
                          GestureDetector(
                            onTap: () => _showTrocarPropriedade(context, ref),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Icon(
                                Icons.swap_horiz_rounded,
                                color: AppColors.text2,
                                size: 18,
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Botão compartilhar propriedade
                          GestureDetector(
                            onTap: () => _showCompartilhar(
                              context,
                              ref,
                              propriedade,
                            ),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Icon(
                                Icons.ios_share_rounded,
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
                  ref.read(conviteViewModelProvider.notifier).enviarConvite(
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
  const _PapelSelector({
    required this.selecionado,
    required this.onChanged,
  });

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
                    : const Border(
                        bottom: BorderSide(color: AppColors.border),
                      ),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tarefasAsync = ref.watch(tarefasListaProvider);

    // Filtra só as tarefas de hoje e pendentes
    final hoje = DateTime.now();
    final tarefasHoje = tarefasAsync.value?.where((t) {
          final d = t.dataExecucao;
          return t.status == StatusTarefa.pendente &&
              d.year == hoje.year &&
              d.month == hoje.month &&
              d.day == hoje.day;
        }).toList() ??
        [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Métricas ──────────────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: Icons.pets_rounded,
                value: isLoadingAnimais ? '—' : totalAnimais.toString(),
                label: 'Animais',
                iconBgColor: AppColors.accentBg,
                iconColor: AppColors.accent,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                icon: Icons.list_alt_rounded,
                value: isLoadingRebanhos ? '—' : totalRebanhos.toString(),
                label: 'Rebanhos',
                iconBgColor: AppColors.accentBg,
                iconColor: AppColors.accent,
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
                value: isLoadingPastos ? '—' : totalPastos.toString(),
                label: 'Pastos',
                iconBgColor: AppColors.accentBg,
                iconColor: AppColors.accent,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                icon: Icons.warning_amber_rounded,
                value: '0',
                label: 'Alertas',
                iconBgColor: AppColors.redBg,
                iconColor: AppColors.red,
              ),
            ),
          ],
        ),

        // ── Tarefas do dia ────────────────────────────────────────────────
        const _SectionTitle(title: 'TAREFAS DO DIA'),

        if (tarefasAsync.isLoading)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
          )
        else if (tarefasHoje.isEmpty)
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
          )
        else
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: tarefasHoje.asMap().entries.map((entry) {
                final tarefa = entry.value;
                final isLast = entry.key == tarefasHoje.length - 1;
                return _TarefaHojeItem(tarefa: tarefa, isLast: isLast);
              }).toList(),
            ),
          ),

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

        const SizedBox(height: 16),
      ],
    );
  }
}

// =============================================================================
// ITEM DE TAREFA DO DIA
// =============================================================================

class _TarefaHojeItem extends StatelessWidget {
  const _TarefaHojeItem({required this.tarefa, required this.isLast});

  final TarefaModel tarefa;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: AppColors.border),
              ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(4),
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
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
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
    // ignore: unused_element_parameter
    this.valueColor,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color iconBgColor;
  final Color iconColor;
  final Color? valueColor;

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
          Text(
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
