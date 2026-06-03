import 'package:bov_manager/core/theme/app_colors.dart';
import 'package:bov_manager/core/widgets/bov_widgets.dart';
import 'package:bov_manager/viewmodels/tarefa_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class NovaTarefaScreen extends ConsumerStatefulWidget {
  const NovaTarefaScreen({super.key});

  @override
  ConsumerState<NovaTarefaScreen> createState() => _NovaTarefaScreenState();
}

class _NovaTarefaScreenState extends ConsumerState<NovaTarefaScreen> {
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  DateTime _dataExecucao = DateTime.now();
  TimeOfDay? _horaExecucao; // null = sem horário definido

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataExecucao,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
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

  Future<void> _selecionarHora() async {
    final initial = _horaExecucao ?? const TimeOfDay(hour: 8, minute: 0);
    final picked = await showBovTimePicker(
      context: context,
      initialHour: initial.hour,
      initialMinute: initial.minute,
    );
    if (picked != null) setState(() => _horaExecucao = picked);
  }

  void _mostrarInfoNotificacoes() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _InfoNotificacoesSheet(),
    );
  }

  int? get _horaEmMinutos =>
      _horaExecucao != null
          ? _horaExecucao!.hour * 60 + _horaExecucao!.minute
          : null;

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(tarefasViewModelProvider).isLoading;

    ref.listen(tarefasViewModelProvider, (_, next) {
      next.whenOrNull(
        data: (_) => Navigator.of(context).pop(),
        error: (e, _) => showBovErrorSnackBar(context, e.toString()),
      );
    });

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
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Nova Tarefa',
                        style: TextStyle(
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

            // ── Formulário ────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Título ────────────────────────────────────────────
                    const BovFieldLabel(label: 'TÍTULO'),
                    const SizedBox(height: 6),
                    BovTextField(
                      controller: _tituloController,
                      hintText: 'Ex: Vacinação do rebanho norte',
                      textInputAction: TextInputAction.next,
                    ),

                    const SizedBox(height: 14),

                    // ── Descrição ─────────────────────────────────────────
                    const BovFieldLabel(label: 'DESCRIÇÃO'),
                    const SizedBox(height: 6),
                    BovTextField(
                      controller: _descricaoController,
                      hintText: 'Detalhes sobre a tarefa...',
                      textInputAction: TextInputAction.done,
                    ),

                    const SizedBox(height: 14),

                    // ── Data de Execução ──────────────────────────────────
                    const BovFieldLabel(label: 'DATA DE EXECUÇÃO'),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: _selecionarData,
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
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
                            const SizedBox(width: 8),
                            Text(
                              DateFormat('dd/MM/yyyy').format(_dataExecucao),
                              style: const TextStyle(
                                color: AppColors.text,
                                fontSize: 14,
                                fontFamily: 'DM Sans',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── Horário de Execução (opcional) ────────────────────
                    Row(
                      children: [
                        const BovFieldLabel(label: 'HORÁRIO DE EXECUÇÃO'),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: _mostrarInfoNotificacoes,
                          child: const Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.text4,
                            size: 16,
                          ),
                        ),
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
                        // Seletor de hora
                        Expanded(
                          child: GestureDetector(
                            onTap:
                                _horaExecucao != null ? _selecionarHora : null,
                            child: Container(
                              height: 48,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
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
                        // Botão de adicionar/remover horário
                        GestureDetector(
                          onTap: () {
                            if (_horaExecucao != null) {
                              setState(() => _horaExecucao = null);
                            } else {
                              _selecionarHora();
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
                      label: 'Salvar Tarefa',
                      isLoading: isLoading,
                      onPressed: () {
                        ref.read(tarefasViewModelProvider.notifier).criar(
                              titulo: _tituloController.text,
                              descricao: _descricaoController.text,
                              dataExecucao: _dataExecucao,
                              horaExecucaoMinutos: _horaEmMinutos,
                            );
                      },
                    ),

                    const SizedBox(height: 10),

                    BovSecondaryButton(
                      label: 'Cancelar',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
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
// MODAL DE INFORMAÇÃO SOBRE NOTIFICAÇÕES
// =============================================================================

class _InfoNotificacoesSheet extends StatelessWidget {
  const _InfoNotificacoesSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
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
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Título
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.accentBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.accent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Notificações da tarefa',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'DM Sans',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Sem horário
            _InfoBloco(
              icone: Icons.schedule_outlined,
              cor: AppColors.accent,
              corFundo: AppColors.accentBg,
              titulo: 'Sem horário definido',
              descricao:
                  'Você receberá 3 lembretes no dia da tarefa: às 8h, às 12h e às 16h.',
            ),

            const SizedBox(height: 12),

            // Com horário
            _InfoBloco(
              icone: Icons.alarm_rounded,
              cor: AppColors.accent,
              corFundo: AppColors.accentBg,
              titulo: 'Com horário definido',
              descricao:
                  'Você receberá 3 lembretes antes do horário da execução: 12 horas antes, 6 horas antes e 1 hora antes.',
            ),

            const SizedBox(height: 20),

            BovSecondaryButton(
              label: 'Entendi',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBloco extends StatelessWidget {
  const _InfoBloco({
    required this.icone,
    required this.cor,
    required this.corFundo,
    required this.titulo,
    required this.descricao,
  });

  final IconData icone;
  final Color cor;
  final Color corFundo;
  final String titulo;
  final String descricao;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: corFundo,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icone, color: cor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'DM Sans',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  descricao,
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
