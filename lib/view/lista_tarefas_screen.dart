import 'package:bov_manager/core/navigation/app_coordinator.dart';
import 'package:bov_manager/core/theme/app_colors.dart';
import 'package:bov_manager/core/widgets/bov_widgets.dart';
import 'package:bov_manager/models/tarefa_model.dart';
import 'package:bov_manager/viewmodels/propriedade_viewmodel.dart';
import 'package:bov_manager/viewmodels/tarefa_viewmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ListaTarefasScreen extends ConsumerStatefulWidget {
  const ListaTarefasScreen({super.key});

  @override
  ConsumerState<ListaTarefasScreen> createState() => _ListaTarefasScreenState();
}

class _ListaTarefasScreenState extends ConsumerState<ListaTarefasScreen> {
  final Map<String, String> _nomesPorId = {};

  Future<String> _resolverNome(String usuarioId) async {
    if (_nomesPorId.containsKey(usuarioId)) return _nomesPorId[usuarioId]!;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(usuarioId)
          .get();
      final nome = (doc.data()?['nome'] as String?)?.trim() ?? 'Usuário';
      _nomesPorId[usuarioId] = nome;
      return nome;
    } catch (_) {
      _nomesPorId[usuarioId] = 'Usuário';
      return 'Usuário';
    }
  }

  // ===========================================================================
  // FLUXO: tocar na tarefa
  // ===========================================================================

  // ---------------------------------------------------------------------------
  // Modal A — editar título e descrição
  // ---------------------------------------------------------------------------

  void _showEditarInfoTarefa(BuildContext context, TarefaModel tarefa) {
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

  void _showAdiarTarefa(BuildContext context, TarefaModel tarefa) {
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

  void _onTarefaTap(BuildContext context, TarefaModel tarefa) {
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
          _showEditarInfoTarefa(context, tarefa);
        },
        onConcluir: () {
          Navigator.of(context).pop();
          ref
              .read(tarefasViewModelProvider.notifier)
              .concluir(tarefaId: tarefa.id);
        },
        onAdiar: () {
          Navigator.of(context).pop();
          _showAdiarTarefa(context, tarefa);
        },
        onReabrir: () {
          Navigator.of(context).pop();
          ref.read(tarefasViewModelProvider.notifier).reabrir(tarefa: tarefa);
        },
        onApagar: () {
          Navigator.of(context).pop();
          _confirmarApagar(context, tarefa);
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Confirmação de exclusão
  // ---------------------------------------------------------------------------

  void _confirmarApagar(BuildContext context, TarefaModel tarefa) {
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

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    // Item 4: verificar se há propriedade selecionada antes de exibir a lista
    final propriedade = ref.watch(propriedadeSelecionadaProvider).asData?.value;

    final tarefasState = ref.watch(tarefasListaProvider);

    ref.listen(tarefasViewModelProvider, (_, next) {
      next.whenOrNull(
        error: (e, _) => showBovErrorSnackBar(context, e.toString()),
      );
    });

    // Calcula badge de tarefas atrasadas a partir do stream atual
    final atrasadas =
        tarefasState.asData?.value
            .where(
              (t) =>
                  t.status == StatusTarefa.pendente &&
                  t.dataExecucao.isBefore(
                    DateTime.now().subtract(const Duration(days: 1)),
                  ),
            )
            .length ??
        0;

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
                  BovBackButton(),
                  // Título com badge de atrasadas
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Tarefas',
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                      if (atrasadas > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$atrasadas',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'DM Sans',
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  GestureDetector(
                    onTap: () => AppCoordinator.goToNovaTarefa(context),
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

            // ── Fazenda selecionada ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Consumer(
                builder: (context, ref, _) {
                  final nomeFazenda =
                      ref.watch(propriedadeSelecionadaProvider).value?.nome ??
                      '—';
                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.home_work_rounded,
                              color: AppColors.text4,
                              size: 13,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                'Propriedade selecionada: $nomeFazenda',
                                style: const TextStyle(
                                  color: AppColors.text4,
                                  fontSize: 13,
                                  fontFamily: 'DM Sans',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: AppColors.text4,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Tarefas e notificações são vinculadas à propriedade selecionada'
                                ' e são atualizadas ao selecionar outra propriedade na tela de dashboard.',
                                style: TextStyle(
                                  color: AppColors.text4,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // ── Corpo ─────────────────────────────────────────────────────
            Expanded(child: _buildCorpo(context, propriedade, tarefasState)),
          ],
        ),
      ),
    );
  }

  Widget _buildCorpo(
    BuildContext context,
    dynamic propriedade,
    AsyncValue tarefasState,
  ) {
    // Item 4: sem propriedade selecionada → empty state orientativo
    if (propriedade == null) {
      return const _SemPropriedadeState();
    }

    return tarefasState.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      ),
      error: (e, _) => Center(
        child: Text(
          e.toString(),
          style: const TextStyle(color: AppColors.red, fontFamily: 'DM Sans'),
        ),
      ),
      data: (tarefas) {
        if (tarefas.isEmpty) return const _EmptyState();

        final pendentes =
            tarefas.where((t) => t.status == StatusTarefa.pendente).toList()
              ..sort((TarefaModel a, TarefaModel b) {
                return a.dataExecucao.compareTo(b.dataExecucao);
              });

        final concluidas =
            tarefas.where((t) => t.status == StatusTarefa.concluida).toList()
              ..sort((TarefaModel a, TarefaModel b) {
                return a.dataExecucao.compareTo(b.dataExecucao);
              });

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            if (pendentes.isNotEmpty) ...[
              _SectionTitle(title: 'PENDENTES', count: pendentes.length),
              ...pendentes.asMap().entries.map(
                (e) => _TarefaItem(
                  tarefa: e.value,
                  isFirst: e.key == 0,
                  isLast: e.key == pendentes.length - 1,
                  resolverNome: _resolverNome,
                  onTap: () => _onTarefaTap(context, e.value),
                ),
              ),
            ],
            if (concluidas.isNotEmpty) ...[
              _SectionTitle(title: 'CONCLUÍDAS', count: concluidas.length),
              ...concluidas.asMap().entries.map(
                (e) => _TarefaItem(
                  tarefa: e.value,
                  isFirst: e.key == 0,
                  isLast: e.key == concluidas.length - 1,
                  resolverNome: _resolverNome,
                  onTap: () => _onTarefaTap(context, e.value),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
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
        : DateTime.now().add(const Duration(days: 1));

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
      firstDate: DateTime.now().add(const Duration(days: 1)),
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

// =============================================================================
// ITEM DE TAREFA  (item 2: exibe horário de execução)
// =============================================================================

class _TarefaItem extends StatefulWidget {
  const _TarefaItem({
    required this.tarefa,
    required this.isFirst,
    required this.isLast,
    required this.resolverNome,
    required this.onTap,
  });

  final TarefaModel tarefa;
  final bool isFirst;
  final bool isLast;
  final Future<String> Function(String) resolverNome;
  final VoidCallback onTap;

  @override
  State<_TarefaItem> createState() => _TarefaItemState();
}

class _TarefaItemState extends State<_TarefaItem> {
  late Future<String> _nomeFuture;

  @override
  void initState() {
    super.initState();
    _nomeFuture = widget.resolverNome(widget.tarefa.usuarioId);
  }

  @override
  void didUpdateWidget(covariant _TarefaItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tarefa.usuarioId != widget.tarefa.usuarioId) {
      _nomeFuture = widget.resolverNome(widget.tarefa.usuarioId);
    }
  }

  bool get _isPendente => widget.tarefa.status == StatusTarefa.pendente;
  bool get _isAtrasada =>
      _isPendente &&
      widget.tarefa.dataExecucao.isBefore(
        DateTime.now().subtract(const Duration(days: 1)),
      );

  /// Formata horaExecucaoMinutos → "HH:mm"
  String _formatarHora(int minutos) {
    final h = minutos ~/ 60;
    final m = minutos % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final data = DateFormat('dd/MM/yyyy').format(widget.tarefa.dataExecucao);
    final horaMinutos = widget.tarefa.horaExecucaoMinutos;
    final horaTexto = horaMinutos != null
        ? _formatarHora(horaMinutos)
        : 'Sem horário definido';

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(
            top: widget.isFirst ? const Radius.circular(12) : Radius.zero,
            bottom: widget.isLast ? const Radius.circular(12) : Radius.zero,
          ),
          border: Border(
            left: const BorderSide(color: AppColors.border),
            right: const BorderSide(color: AppColors.border),
            top: widget.isFirst
                ? const BorderSide(color: AppColors.border)
                : BorderSide.none,
            bottom: const BorderSide(color: AppColors.border),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ícone de status
            Container(
              margin: const EdgeInsets.only(top: 1),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: _isPendente
                    ? (_isAtrasada ? AppColors.redBg : AppColors.accentBg)
                    : AppColors.accentBg,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _isPendente
                      ? (_isAtrasada ? AppColors.red : AppColors.accent)
                      : AppColors.accent,
                ),
              ),
              child: _isPendente
                  ? null
                  : const Icon(
                      Icons.check_rounded,
                      color: AppColors.accent,
                      size: 13,
                    ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.tarefa.titulo,
                    style: TextStyle(
                      color: _isPendente ? AppColors.text : AppColors.text4,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'DM Sans',
                      decoration: _isPendente
                          ? TextDecoration.none
                          : TextDecoration.lineThrough,
                      decorationColor: AppColors.text4,
                    ),
                  ),
                  if (widget.tarefa.descricao.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      "Descrição: ${widget.tarefa.descricao}",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.text4,
                        fontSize: 14,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  // ── Data, horário e usuário ──────────────────────────────
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 11,
                        color: _isAtrasada ? AppColors.red : AppColors.text4,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        data,
                        style: TextStyle(
                          color: _isAtrasada ? AppColors.red : AppColors.text4,
                          fontSize: 14,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Item 2: horário de execução
                      Icon(
                        Icons.schedule_rounded,
                        size: 11,
                        color: _isAtrasada ? AppColors.red : AppColors.text4,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        horaTexto,
                        style: TextStyle(
                          color: _isAtrasada ? AppColors.red : AppColors.text4,
                          fontSize: 14,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline_rounded,
                        size: 11,
                        color: AppColors.text4,
                      ),
                      const SizedBox(width: 4),
                      FutureBuilder<String>(
                        future: _nomeFuture,
                        builder: (context, snapshot) => Text(
                          "Autor da tarefa: ${snapshot.data ?? '...'}",
                          style: const TextStyle(
                            color: AppColors.text4,
                            fontSize: 14,
                            fontFamily: 'DM Sans',
                          ),
                        ),
                      ),
                    ],
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
// TÍTULO DE SEÇÃO
// =============================================================================

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 12),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.text4,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
              fontFamily: 'DM Sans',
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.border2,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: AppColors.text4,
                fontSize: 10,
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
// EMPTY STATE — sem tarefas
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
              Icons.task_alt_rounded,
              color: AppColors.accent,
              size: 34,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Nenhuma tarefa',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'DM Sans',
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Crie a primeira tarefa desta\npropriedade para começar.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.text4,
              fontSize: 13,
              fontFamily: 'DM Sans',
            ),
          ),
          const SizedBox(height: 28),
          BovPrimaryButton(
            label: 'Criar Tarefa',
            onPressed: () => AppCoordinator.goToNovaTarefa(context),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// EMPTY STATE — sem propriedade cadastrada  (item 4)
// =============================================================================

class _SemPropriedadeState extends StatelessWidget {
  const _SemPropriedadeState();

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
              Icons.home_work_rounded,
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
            'Cadastre uma propriedade para\ngerenciar suas tarefas.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.text4,
              fontSize: 13,
              fontFamily: 'DM Sans',
            ),
          ),
          const SizedBox(height: 28),
          BovPrimaryButton(
            label: 'Criar Propriedade',
            onPressed: () => AppCoordinator.goToNovaPropriedade(context),
          ),
        ],
      ),
    );
  }
}
