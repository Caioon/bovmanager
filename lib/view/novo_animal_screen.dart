import 'package:bov_manager/core/navigation/app_coordinator.dart';
import 'package:bov_manager/core/theme/app_colors.dart';
import 'package:bov_manager/core/widgets/bov_widgets.dart';
import 'package:bov_manager/models/pasto_model.dart';
import 'package:bov_manager/models/propriedade_model.dart';
import 'package:bov_manager/models/rebanho_model.dart';
import 'package:bov_manager/services/pasto_service.dart';
import 'package:bov_manager/services/rebanho_service.dart';
import 'package:bov_manager/viewmodels/animal_viewmodel.dart';
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

  String _racaSelecionada = '';
  DateTime _dataNascimento = DateTime.now();

  PropriedadeModel? _propriedadeSelecionada;
  // ── Rebanho ───────────────────────────────────────────────────────────────
  List<RebanhoModel> _rebanhos = [];
  bool _carregandoRebanhos = false;
  RebanhoModel? _rebanhoSelecionado;

  // ── Pasto destino ─────────────────────────────────────────────────────────
  List<PastoModel> _pastos = [];
  bool _carregandoPastos = false;
  PastoModel? _pastoDestino;
  bool _usarRebanho = false;

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

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(animaisViewModelProvider).isLoading;
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

                    const SizedBox(height: 20),
                    // =========================================================
                    // ── Pasto / Rebanho ───────────────────────────────────────
                    // =========================================================
                    const BovFieldLabel(label: 'PASTO / REBANHO'),
                    const SizedBox(height: 4),

                    const Text(
                      'Escolha um pasto ou um rebanho.',
                      style: TextStyle(
                        color: AppColors.text4,
                        fontSize: 12,
                        fontFamily: 'DM Sans',
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (_usarRebanho == false) return;
                                setState(() {
                                  _usarRebanho = false;
                                });
                                // Se a propriedade já está selecionada e os pastos
                                // ainda não foram carregados, busca agora.
                                if (_propriedadeSelecionada != null &&
                                    _pastos.isEmpty &&
                                    !_carregandoPastos) {
                                  setState(() => _carregandoPastos = true);
                                  ref
                                      .read(pastoServiceProvider)
                                      .listar(_propriedadeSelecionada!.id)
                                      .then((pastos) {
                                        if (!mounted) return;
                                        setState(() {
                                          _pastos = pastos;
                                          _carregandoPastos = false;
                                        });
                                      })
                                      .catchError((_) {
                                        if (!mounted) return;
                                        setState(
                                          () => _carregandoPastos = false,
                                        );
                                      });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: !_usarRebanho
                                      ? AppColors.accentBg
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Pasto',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: !_usarRebanho
                                        ? AppColors.accent
                                        : AppColors.text4,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'DM Sans',
                                  ),
                                ),
                              ),
                            ),
                          ),

                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (_usarRebanho == true) return;
                                setState(() {
                                  _usarRebanho = true;
                                });
                                // Se a propriedade já está selecionada e os rebanhos
                                // ainda não foram carregados, busca agora.
                                if (_propriedadeSelecionada != null &&
                                    _rebanhos.isEmpty &&
                                    !_carregandoRebanhos) {
                                  setState(() => _carregandoRebanhos = true);
                                  ref
                                      .read(rebanhoServiceProvider)
                                      .listar(_propriedadeSelecionada!.id)
                                      .then((rebanhos) {
                                        if (!mounted) return;
                                        setState(() {
                                          _rebanhos = rebanhos;
                                          _carregandoRebanhos = false;
                                        });
                                      })
                                      .catchError((_) {
                                        if (!mounted) return;
                                        setState(
                                          () => _carregandoRebanhos = false,
                                        );
                                      });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: _usarRebanho
                                      ? AppColors.accentBg
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Rebanho',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: _usarRebanho
                                        ? AppColors.accent
                                        : AppColors.text4,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'DM Sans',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── Propriedade ──────────────────────────────────────────
                    propriedadesAsync.when(
                      loading: () => const _DropdownSkeleton(
                        label: 'Carregando propriedades...',
                      ),

                      error: (_, _) => const _DropdownSkeleton(
                        label: 'Erro ao carregar propriedades',
                      ),

                      data: (propriedades) => _BovDropdown<PropriedadeModel>(
                        value: _propriedadeSelecionada,
                        hint: 'Selecionar propriedade',

                        items: propriedades
                            .map(
                              (p) => DropdownMenuItem(
                                value: p,
                                child: Text(p.nome),
                              ),
                            )
                            .toList(),

                        onChanged: (p) async {
                          if (p == null) return;

                          setState(() {
                            _propriedadeSelecionada = p;

                            _rebanhos = [];
                            _rebanhoSelecionado = null;
                            _pastos = [];
                            _pastoDestino = null;

                            _carregandoRebanhos = _usarRebanho;
                            _carregandoPastos = !_usarRebanho;
                          });

                          try {
                            if (_usarRebanho) {
                              final rebanhos = await ref
                                  .read(rebanhoServiceProvider)
                                  .listar(p.id);

                              if (!mounted) return;

                              setState(() {
                                _rebanhos = rebanhos;
                                _carregandoRebanhos = false;
                              });
                            } else {
                              final pastos = await ref
                                  .read(pastoServiceProvider)
                                  .listar(p.id);

                              if (!mounted) return;

                              setState(() {
                                _pastos = pastos;
                                _carregandoPastos = false;
                              });
                            }
                          } catch (_) {
                            if (!mounted) return;

                            setState(() {
                              _carregandoRebanhos = false;
                              _carregandoPastos = false;
                            });
                          }
                        },
                      ),
                    ),

                    // ── Conteúdo dinâmico ────────────────────────────────────
                    if (_propriedadeSelecionada != null) ...[
                      const SizedBox(height: 10),

                      if (_usarRebanho) ...[
                        if (_carregandoRebanhos)
                          const _DropdownSkeleton(
                            label: 'Carregando rebanhos...',
                          )
                        else if (_rebanhos.isEmpty)
                          _InfoBox(
                            mensagem:
                                'Nenhum rebanho cadastrado nesta propriedade.',
                            botaoLabel: 'Criar rebanho',
                            onBotao: () async {
                              await AppCoordinator.goToNovoRebanho(
                                context,
                                propriedadeId: _propriedadeSelecionada!.id,
                              );

                              if (!mounted) return;

                              if (_propriedadeSelecionada != null) {
                                final rebanhos = await ref
                                    .read(rebanhoServiceProvider)
                                    .listar(_propriedadeSelecionada!.id);

                                if (!mounted) return;

                                setState(() {
                                  _rebanhos = rebanhos;
                                });
                              }
                            },
                          )
                        else
                          _BovDropdown<RebanhoModel>(
                            value: _rebanhoSelecionado,
                            hint: 'Selecionar rebanho',

                            items: _rebanhos
                                .map(
                                  (r) => DropdownMenuItem(
                                    value: r,
                                    child: Text(
                                      r.nome,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),

                            onChanged: (r) {
                              setState(() {
                                _rebanhoSelecionado = r;
                              });
                            },
                          ),
                      ] else ...[
                        if (_carregandoPastos)
                          const _DropdownSkeleton(label: 'Carregando pastos...')
                        else if (_pastos.isEmpty)
                          _InfoBox(
                            mensagem:
                                'Nenhum pasto cadastrado nesta propriedade.',
                            botaoLabel: 'Criar pasto',
                            onBotao: () async {
                              await AppCoordinator.goToNovoPasto(
                                context,
                                propriedadeId: _propriedadeSelecionada!.id,
                              );

                              if (_propriedadeSelecionada != null) {
                                final pastos = await ref
                                    .read(pastoServiceProvider)
                                    .listar(_propriedadeSelecionada!.id);

                                if (!mounted) return;

                                setState(() {
                                  _pastos = pastos;
                                });
                              }
                            },
                          )
                        else
                          _BovDropdown<PastoModel>(
                            value: _pastoDestino,
                            hint: 'Selecionar pasto',

                            items: _pastos
                                .map(
                                  (p) => DropdownMenuItem(
                                    value: p,
                                    child: Text(
                                      p.nome,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),

                            onChanged: (p) {
                              setState(() {
                                _pastoDestino = p;
                              });
                            },
                          ),
                      ],
                    ],
                    const SizedBox(height: 24),

                    BovPrimaryButton(
                      label: 'Cadastrar Animal',
                      isLoading: isLoading,
                      onPressed: () {
                        final pastoIdFinal = _usarRebanho
                            ? _rebanhoSelecionado?.pastoId
                            : _pastoDestino?.id;

                        if (_usarRebanho && _rebanhoSelecionado == null) {
                          showBovErrorSnackBar(
                            context,
                            'Selecione um rebanho.',
                          );
                          return;
                        }

                        if (!_usarRebanho && _pastoDestino == null) {
                          showBovErrorSnackBar(context, 'Selecione um pasto.');
                          return;
                        }

                        ref
                            .read(animaisViewModelProvider.notifier)
                            .criar(
                              nome: _nomeController.text,
                              brinco: _brincoController.text,
                              raca: _racaSelecionada,
                              pesoAtual:
                                  double.tryParse(_pesoController.text) ?? 0.0,
                              dataNascimento: _dataNascimento,
                              rebanhoId: _usarRebanho
                                  ? _rebanhoSelecionado?.id
                                  : null,
                              pastoDestinoId: pastoIdFinal!,
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
// CAIXA DE AVISO COM BOTÃO OPCIONAL
// =============================================================================

class _InfoBox extends StatelessWidget {
  const _InfoBox({
    required this.mensagem,
    required this.botaoLabel,
    required this.onBotao,
  });

  final String mensagem;
  final String? botaoLabel;
  final VoidCallback? onBotao;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              mensagem,
              style: const TextStyle(
                color: AppColors.text4,
                fontSize: 13,
                fontFamily: 'DM Sans',
              ),
            ),
          ),
          if (botaoLabel != null && onBotao != null) ...[
            const SizedBox(width: 10),
            GestureDetector(
              onTap: onBotao,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentBg,
                  borderRadius: BorderRadius.circular(8),
                  // ignore: deprecated_member_use
                  border: Border.all(color: AppColors.accent.withOpacity(0.4)),
                ),
                child: Text(
                  botaoLabel!,
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'DM Sans',
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// =============================================================================
// DROPDOWN ESTILIZADO
// =============================================================================

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

// =============================================================================
// SKELETON DE DROPDOWN
// =============================================================================

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
