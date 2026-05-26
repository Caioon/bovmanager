import 'package:bov_manager/core/theme/app_colors.dart';
import 'package:bov_manager/core/widgets/bov_widgets.dart';
import 'package:bov_manager/models/pasto_model.dart';
import 'package:bov_manager/models/propriedade_model.dart';
import 'package:bov_manager/services/pasto_service.dart';
import 'package:bov_manager/viewmodels/animal_viewmodel.dart';
import 'package:bov_manager/viewmodels/pasto_viewmodel.dart';
import 'package:bov_manager/viewmodels/propriedade_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NovoAnimalScreen extends ConsumerStatefulWidget {
  const NovoAnimalScreen({super.key});

  @override
  ConsumerState<NovoAnimalScreen> createState() => _NovoAnimalScreenState();
}

class _NovoAnimalScreenState extends ConsumerState<NovoAnimalScreen> {
  final _nomeController = TextEditingController();
  final _brincoController = TextEditingController();
  final _pesoController = TextEditingController();
  final _rebanhoController = TextEditingController();

  String _racaSelecionada = '';
  DateTime _dataNascimento = DateTime.now();

  // ── Estado do seletor de pasto ────────────────────────────────────────────
  // Propriedade escolhida no primeiro dropdown (independente da selecionada)
  PropriedadeModel? _propriedadePasto;
  // Lista de pastos carregada ao escolher a propriedade
  List<PastoModel> _pastos = [];
  bool _carregandoPastos = false;
  // Pasto escolhido no segundo dropdown
  PastoModel? _pastoDestino;

  static const _racas = [
    'Nelore',
    'Angus',
    'Girolando',
    'Zebu',
    'Brahman',
    'Simmental',
    'Hereford',
    'Gir',
    'Outra',
  ];

  @override
  void dispose() {
    _nomeController.dispose();
    _brincoController.dispose();
    _pesoController.dispose();
    _rebanhoController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataNascimento,
      firstDate: DateTime(2000),
      lastDate: DateTime(3000),
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
    if (picked != null) setState(() => _dataNascimento = picked);
  }

  // Ao escolher uma propriedade no dropdown, carrega os pastos dela
  Future<void> _onPropriedadePastoSelecionada(PropriedadeModel prop) async {
    setState(() {
      _propriedadePasto = prop;
      _pastos = [];
      _pastoDestino = null;
      _carregandoPastos = true;
    });

    try {
      final pastos = await ref.read(pastosListaProvider.future);
      if (mounted) {
        setState(() {
          _pastos = pastos;
          _carregandoPastos = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _carregandoPastos = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(animaisViewModelProvider).isLoading;

    // Lista de todas as propriedades do usuário — apenas para o seletor de pasto
    final propriedadesAsync = ref.watch(propriedadesListaProvider);

    ref.listen(animaisViewModelProvider, (_, next) {
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
                        'Novo Animal',
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
                    // ── Nome ─────────────────────────────────────────────
                    const BovFieldLabel(label: 'NOME (OPCIONAL)'),
                    const SizedBox(height: 6),
                    BovTextField(
                      controller: _nomeController,
                      hintText: 'Ex: Mimosa',
                      textInputAction: TextInputAction.next,
                    ),

                    const SizedBox(height: 14),

                    // ── Brinco ────────────────────────────────────────────
                    const BovFieldLabel(label: 'BRINCO'),
                    const SizedBox(height: 6),
                    BovTextField(
                      controller: _brincoController,
                      hintText: 'Ex: #0042',
                      textInputAction: TextInputAction.next,
                    ),

                    const SizedBox(height: 14),

                    // ── Raça ──────────────────────────────────────────────
                    const BovFieldLabel(label: 'RAÇA'),
                    const SizedBox(height: 6),
                    _BovDropdown<String>(
                      value: _racaSelecionada.isEmpty ? null : _racaSelecionada,
                      hint: 'Selecione a raça',
                      items: _racas
                          .map(
                            (r) => DropdownMenuItem(value: r, child: Text(r)),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _racaSelecionada = v ?? ''),
                    ),

                    const SizedBox(height: 14),

                    // ── Peso e Data ───────────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const BovFieldLabel(label: 'PESO (KG)'),
                              const SizedBox(height: 6),
                              BovTextField(
                                controller: _pesoController,
                                hintText: '0.0',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                textInputAction: TextInputAction.next,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const BovFieldLabel(label: 'NASCIMENTO'),
                              const SizedBox(height: 6),
                              GestureDetector(
                                onTap: _selecionarData,
                                child: Container(
                                  height: 48,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
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
                                      const SizedBox(width: 8),
                                      Text(
                                        '${_dataNascimento.day.toString().padLeft(2, '0')}/${_dataNascimento.month.toString().padLeft(2, '0')}/${_dataNascimento.year}',
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
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // ── Rebanho ───────────────────────────────────────────
                    // TODO: substituir por dropdown com lista real de rebanhos
                    const BovFieldLabel(label: 'ID DO REBANHO'),
                    const SizedBox(height: 6),
                    BovTextField(
                      controller: _rebanhoController,
                      hintText: 'ID do rebanho',
                      textInputAction: TextInputAction.next,
                    ),

                    const SizedBox(height: 20),

                    // ── Pasto Destino (opcional) ──────────────────────────
                    Row(
                      children: [
                        const Text(
                          'PASTO DESTINO',
                          style: TextStyle(
                            color: AppColors.text4,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                            fontFamily: 'DM Sans',
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.border2,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'OPCIONAL',
                            style: TextStyle(
                              color: AppColors.text4,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                              fontFamily: 'DM Sans',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Selecione a propriedade e depois o pasto onde o animal será alocado.',
                      style: TextStyle(
                        color: AppColors.text4,
                        fontSize: 12,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Dropdown 1: Propriedade
                    propriedadesAsync.when(
                      loading: () => const _DropdownSkeleton(
                        label: 'Carregando propriedades...',
                      ),
                      error: (_, __) => const _DropdownSkeleton(
                        label: 'Erro ao carregar propriedades',
                      ),
                      data: (propriedades) => _BovDropdown<PropriedadeModel>(
                        value: _propriedadePasto,
                        hint: 'Selecionar propriedade',
                        items: propriedades
                            .map(
                              (p) => DropdownMenuItem(
                                value: p,
                                child: Text(p.nome),
                              ),
                            )
                            .toList(),
                        onChanged: (p) {
                          if (p != null) _onPropriedadePastoSelecionada(p);
                        },
                      ),
                    ),

                    // Dropdown 2: Pasto — só aparece se uma propriedade foi escolhida
                    if (_propriedadePasto != null) ...[
                      const SizedBox(height: 10),
                      if (_carregandoPastos)
                        const _DropdownSkeleton(label: 'Carregando pastos...')
                      else if (_pastos.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 13,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Text(
                            'Nenhum pasto cadastrado nesta propriedade',
                            style: TextStyle(
                              color: AppColors.text4,
                              fontSize: 14,
                              fontFamily: 'DM Sans',
                            ),
                          ),
                        )
                      else
                        _BovDropdown<PastoModel>(
                          value: _pastoDestino,
                          hint: 'Selecionar pasto (opcional)',
                          items: [
                            // Opção explícita de "nenhum"
                            const DropdownMenuItem<PastoModel>(
                              value: null,
                              child: Text('Nenhum pasto'),
                            ),
                            ..._pastos.map(
                              (p) => DropdownMenuItem(
                                value: p,
                                child: Text(
                                  p.nome,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                          onChanged: (p) => setState(() => _pastoDestino = p),
                        ),
                    ],

                    const SizedBox(height: 24),

                    BovPrimaryButton(
                      label: 'Cadastrar Animal',
                      isLoading: isLoading,
                      onPressed: () {
                        ref
                            .read(animaisViewModelProvider.notifier)
                            .criar(
                              nome: _nomeController.text,
                              brinco: _brincoController.text,
                              raca: _racaSelecionada,
                              pesoAtual:
                                  double.tryParse(_pesoController.text) ?? 0.0,
                              dataNascimento: _dataNascimento,
                              rebanhoId: _rebanhoController.text,
                              pastoDestinoId: _pastoDestino?.id,
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
// WIDGETS INTERNOS
// =============================================================================

/// Dropdown estilizado no padrão BovManager.
class _BovDropdown<T> extends StatelessWidget {
  const _BovDropdown({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  final T? value;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(
            hint,
            style: const TextStyle(
              color: AppColors.text4,
              fontSize: 14,
              fontFamily: 'DM Sans',
            ),
          ),
          isExpanded: true,
          dropdownColor: AppColors.card,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 14,
            fontFamily: 'DM Sans',
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.text4,
          ),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

/// Placeholder enquanto os dados carregam.
class _DropdownSkeleton extends StatelessWidget {
  const _DropdownSkeleton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.text4,
          fontSize: 14,
          fontFamily: 'DM Sans',
        ),
      ),
    );
  }
}
