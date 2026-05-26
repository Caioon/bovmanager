import 'package:bov_manager/core/theme/app_colors.dart';
import 'package:bov_manager/core/widgets/bov_widgets.dart';
import 'package:bov_manager/viewmodels/pasto_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NovoPastoScreen extends ConsumerStatefulWidget {
  const NovoPastoScreen({super.key});

  @override
  ConsumerState<NovoPastoScreen> createState() => _NovoPastoScreenState();
}

class _NovoPastoScreenState extends ConsumerState<NovoPastoScreen> {
  final _nomeController = TextEditingController();
  final _areaController = TextEditingController();
  final _descricaoController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _areaController.dispose();
    _descricaoController.dispose();
    super.dispose();
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
            // ── Header ────────────────────────────────────────────────────
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

            // ── Formulário ────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Nome ─────────────────────────────────────────────
                    const BovFieldLabel(label: 'NOME DO PASTO'),
                    const SizedBox(height: 6),
                    BovTextField(
                      controller: _nomeController,
                      hintText: 'Ex: Pasto Norte A',
                      textInputAction: TextInputAction.next,
                    ),

                    const SizedBox(height: 14),

                    // ── Área ──────────────────────────────────────────────
                    const BovFieldLabel(label: 'TAMANHO (HECTARES)'),
                    const SizedBox(height: 6),
                    BovTextField(
                      controller: _areaController,
                      hintText: '0.00',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.next,
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
                      onPressed: () {
                        ref.read(pastosViewModelProvider.notifier).criar(
                          nome: _nomeController.text,
                          area:
                              double.tryParse(_areaController.text) ?? 0.0,
                          descricao: _descricaoController.text,
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
