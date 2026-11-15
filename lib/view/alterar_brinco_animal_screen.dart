import 'package:bov_manager/core/theme/app_colors.dart';
import 'package:bov_manager/core/widgets/bov_widgets.dart';
import 'package:bov_manager/viewmodels/animal_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Edição pontual da identificação. Não é uma movimentação nem pesagem.
class AlterarBrincoAnimalScreen extends ConsumerStatefulWidget {
  const AlterarBrincoAnimalScreen({super.key});

  @override
  ConsumerState<AlterarBrincoAnimalScreen> createState() =>
      _AlterarBrincoAnimalScreenState();
}

class _AlterarBrincoAnimalScreenState
    extends ConsumerState<AlterarBrincoAnimalScreen> {
  final _brincoController = TextEditingController();
  bool _salvando = false;
  bool _inicializado = false;

  @override
  void dispose() {
    _brincoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final animal = ref.read(animalEmVisualizacaoProvider);
    if (animal == null) return;
    final novoBrinco = _brincoController.text.trim();
    if (novoBrinco.isEmpty) {
      showBovErrorSnackBar(context, 'Informe o número do brinco.');
      return;
    }
    if (novoBrinco == animal.brinco) {
      Navigator.of(context).pop();
      return;
    }

    setState(() => _salvando = true);
    await ref.read(animaisViewModelProvider.notifier).alterarBrinco(
      animalId: animal.id,
      propriedadeId: animal.propriedadeId,
      novoBrinco: novoBrinco,
    );
    if (!mounted) return;
    setState(() => _salvando = false);

    final resultado = ref.read(animaisViewModelProvider);
    if (resultado.hasError) {
      showBovErrorSnackBar(context, resultado.error.toString());
      return;
    }
    showBovSuccessSnackBar(context, 'Brinco atualizado com sucesso.');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final animal = ref.watch(animalEmVisualizacaoProvider);
    if (animal == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!_inicializado) {
      _brincoController.text = animal.brinco;
      _inicializado = true;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  const BovBackButton(),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Alterar brinco',
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
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BovFieldLabel(label: 'BRINCO DO ANIMAL'),
                    const SizedBox(height: 8),
                    BovTextField(
                      controller: _brincoController,
                      hintText: 'Identificação do animal',
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'A correção do brinco não modifica o rebanho, o pasto, '
                      'o peso ou o histórico do animal.',
                      style: TextStyle(
                        color: AppColors.text4,
                        fontSize: 13,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                    const SizedBox(height: 28),
                    BovPrimaryButton(
                      label: 'Salvar brinco',
                      isLoading: _salvando,
                      onPressed: _salvando ? null : _salvar,
                    ),
                    const SizedBox(height: 12),
                    BovSecondaryButton(
                      label: 'Cancelar',
                      onPressed: _salvando ? null : () => Navigator.pop(context),
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
