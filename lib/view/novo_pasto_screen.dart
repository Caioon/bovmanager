import 'package:bov_manager/core/theme/app_colors.dart';
import 'package:bov_manager/core/widgets/bov_widgets.dart';
import 'package:bov_manager/viewmodels/pasto_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NovoPastoScreen extends ConsumerStatefulWidget {
  const NovoPastoScreen({super.key, this.propriedadeId});

  final String? propriedadeId;

  @override
  ConsumerState<NovoPastoScreen> createState() => _NovoPastoScreenState();
}

class _NovoPastoScreenState extends ConsumerState<NovoPastoScreen> {
  final _nomeController = TextEditingController();
  final _areaController = TextEditingController();
  final _limiteController = TextEditingController();
  final _descricaoController = TextEditingController();

  bool _tentouSalvar = false;

  bool get _nomeValido => _nomeController.text.trim().isNotEmpty;
  bool get _areaValida => _areaController.text.trim().isNotEmpty;
  bool get _limiteValido => _limiteController.text.trim().isNotEmpty;

  @override
  void dispose() {
    _nomeController.dispose();
    _areaController.dispose();
    _limiteController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  void _salvar() {
    setState(() => _tentouSalvar = true);

    if (!_nomeValido || !_areaValida || !_limiteValido) {
      showBovErrorSnackBar(context, 'Preencha todos os campos obrigatórios.');
      return;
    }

    ref.read(pastosViewModelProvider.notifier).criar(
          nome: _nomeController.text,
          area: double.tryParse(_areaController.text) ?? 0.0,
          descricao: _descricaoController.text,
          limiteAnimais: int.tryParse(_limiteController.text),
          propriedadeIdOverride: widget.propriedadeId,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(pastosViewModelProvider).isLoading;

    ref.listen(pastosViewModelProvider, (_, next) {
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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  BovBackButton(),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Novo Pasto',
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

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Nome ─────────────────────────────────────────────
                    const BovFieldLabel(label: 'NOME DO PASTO *'),
                    const SizedBox(height: 6),
                    BovTextField(
                      controller: _nomeController,
                      hintText: 'Ex: Pasto Norte A',
                      textInputAction: TextInputAction.next,
                      errorBorder: _tentouSalvar && !_nomeValido,
                      onChanged: (_) => setState(() {}),
                    ),

                    const SizedBox(height: 14),

                    // ── Área e Limite lado a lado ─────────────────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const BovFieldLabel(label: 'TAMANHO (HA) *'),
                              const SizedBox(height: 6),
                              BovTextField(
                                controller: _areaController,
                                hintText: '0.00',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                textInputAction: TextInputAction.next,
                                errorBorder: _tentouSalvar && !_areaValida,
                                onChanged: (_) => setState(() {}),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const BovFieldLabel(label: 'LIMITE ANIMAIS *'),
                              const SizedBox(height: 6),
                              BovTextField(
                                controller: _limiteController,
                                hintText: '0',
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                errorBorder: _tentouSalvar && !_limiteValido,
                                onChanged: (_) => setState(() {}),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // ── Descrição ─────────────────────────────────────────
                    const BovFieldLabel(label: 'DESCRIÇÃO'),
                    const SizedBox(height: 6),
                    BovTextField(
                      controller: _descricaoController,
                      hintText: 'Observações sobre o pasto...',
                      textInputAction: TextInputAction.done,
                    ),

                    const SizedBox(height: 24),

                    BovPrimaryButton(
                      label: 'Salvar Pasto',
                      isLoading: isLoading,
                      onPressed: _salvar,
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
