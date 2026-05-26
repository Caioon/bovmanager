import 'package:bov_manager/core/theme/app_colors.dart';
import 'package:bov_manager/core/widgets/bov_widgets.dart';
import 'package:bov_manager/viewmodels/propriedade_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NovaPropriedadeScreen extends ConsumerStatefulWidget {
  const NovaPropriedadeScreen({super.key});

  @override
  ConsumerState<NovaPropriedadeScreen> createState() =>
      _NovaPropriedadeScreenState();
}

class _NovaPropriedadeScreenState extends ConsumerState<NovaPropriedadeScreen> {
  final _nomeController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(propriedadesViewModelProvider).isLoading;

    ref.listen(propriedadesViewModelProvider, (_, next) {
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
                        'Nova Propriedade',
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
                    const BovFieldLabel(label: 'NOME DA FAZENDA'),
                    const SizedBox(height: 6),
                    BovTextField(
                      controller: _nomeController,
                      hintText: 'Ex: Fazenda Santa Clara',
                      textInputAction: TextInputAction.done,
                    ),

                    const SizedBox(height: 20),

                    BovPrimaryButton(
                      label: 'Salvar Propriedade',
                      isLoading: isLoading,
                      onPressed: () {
                        ref
                            .read(propriedadesViewModelProvider.notifier)
                            .criar(nome: _nomeController.text);
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
