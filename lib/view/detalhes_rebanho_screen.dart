import 'package:bov_manager/core/theme/app_colors.dart';
import 'package:bov_manager/core/widgets/bov_widgets.dart';
import 'package:bov_manager/models/animal_model.dart';
import 'package:bov_manager/models/rebanho_model.dart';
import 'package:bov_manager/services/rebanho_service.dart';
import 'package:bov_manager/view/detalhes_animal_screen.dart';
import 'package:bov_manager/viewmodels/animal_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Lista os animais cujo último vínculo registrado aponta para este rebanho.
/// Não cria coleção ou campo novo no Firebase.
class DetalhesRebanhoScreen extends ConsumerStatefulWidget {
  const DetalhesRebanhoScreen({
    super.key,
    required this.rebanho,
    required this.nomePasto,
  });

  final RebanhoModel rebanho;
  final String nomePasto;

  @override
  ConsumerState<DetalhesRebanhoScreen> createState() =>
      _DetalhesRebanhoScreenState();
}

class _DetalhesRebanhoScreenState
    extends ConsumerState<DetalhesRebanhoScreen> {
  late Future<List<AnimalModel>> _animaisFuture;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  void _carregar() {
    _animaisFuture = ref.read(rebanhoServiceProvider).listarAnimaisDoRebanho(
      propriedadeId: widget.rebanho.propriedadeId,
      rebanhoId: widget.rebanho.id,
    );
  }

  Future<void> _recarregar() async {
    if (!mounted) return;
    setState(_carregar);
    try {
      await _animaisFuture;
    } catch (_) {
      // O FutureBuilder exibe a mensagem e permite tentar novamente.
    }
  }

  Future<void> _abrirAnimal(AnimalModel animal) async {
    ref.read(animalEmVisualizacaoProvider.notifier).abrir(animal);
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const DetalhesAnimalScreen(),
      ),
    );
    if (mounted) _recarregar();
  }

  @override
  Widget build(BuildContext context) {
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
                        'Animais do Rebanho',
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _recarregar,
                    icon: const Icon(Icons.refresh_rounded, color: AppColors.text2),
                    tooltip: 'Atualizar lista',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.rebanho.nome,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'Pasto: ${widget.nomePasto}',
                      style: const TextStyle(
                        color: AppColors.text4,
                        fontSize: 13,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<AnimalModel>>(
                future: _animaisFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Não foi possível carregar os animais deste rebanho.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.text2),
                            ),
                            const SizedBox(height: 14),
                            BovSecondaryButton(
                              label: 'Tentar novamente',
                              onPressed: _recarregar,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final animais = snapshot.data ?? <AnimalModel>[];
                  if (animais.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Nenhum animal vinculado a este rebanho.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.text4,
                            fontSize: 14,
                            fontFamily: 'DM Sans',
                          ),
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                    itemCount: animais.length + 1,
                    separatorBuilder: (_, _) => const SizedBox(height: 9),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Text(
                            '${animais.length} animal(is) neste rebanho',
                            style: const TextStyle(
                              color: AppColors.text4,
                              fontSize: 12,
                              fontFamily: 'DM Sans',
                            ),
                          ),
                        );
                      }
                      final animal = animais[index - 1];
                      return Material(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _abrirAnimal(animal),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.accentBg,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.pets_rounded,
                                    color: AppColors.accent,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        animal.nome.isEmpty
                                            ? 'Brinco #${animal.brinco}'
                                            : animal.nome,
                                        style: const TextStyle(
                                          color: AppColors.text,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'DM Sans',
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        'Brinco #${animal.brinco} · ${animal.raca} · '
                                        '${animal.pesoAtual.toStringAsFixed(0)} kg',
                                        style: const TextStyle(
                                          color: AppColors.text4,
                                          fontSize: 12,
                                          fontFamily: 'DM Sans',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: AppColors.text4,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
