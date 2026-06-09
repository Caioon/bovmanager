import 'package:bov_manager/core/navigation/app_coordinator.dart';
import 'package:bov_manager/core/theme/app_colors.dart';
import 'package:bov_manager/core/widgets/bov_widgets.dart';
import 'package:bov_manager/models/animal_model.dart';
import 'package:bov_manager/viewmodels/animal_viewmodel.dart';
import 'package:bov_manager/viewmodels/propriedade_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ListaAnimaisScreen extends ConsumerStatefulWidget {
  const ListaAnimaisScreen({super.key});

  @override
  ConsumerState<ListaAnimaisScreen> createState() => _ListaAnimaisScreenState();
}

class _ListaAnimaisScreenState extends ConsumerState<ListaAnimaisScreen> {
  final _buscaController = TextEditingController();
  String _busca = '';

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final propriedadeState = ref.watch(propriedadeSelecionadaProvider);

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
                  const Text(
                    'Animais',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                  GestureDetector(
                    onTap: () => AppCoordinator.goToNovoAnimal(context),
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

            // ── Busca ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: BovTextField(
                controller: _buscaController,
                hintText: 'Buscar por brinco ou nome...',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.text4,
                  size: 18,
                ),
                onChanged: (v) => setState(() => _busca = v.toLowerCase()),
              ),
            ),

            // ── Corpo ─────────────────────────────────────────────────────
            Expanded(
              child: propriedadeState.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
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

                data: (propriedade) {
                  // Nenhuma propriedade cadastrada
                  if (propriedade == null) {
                    return const _SemPropriedadeState();
                  }

                  final listaState = ref.watch(animaisListaProvider);

                  return listaState.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
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

                    data: (lista) {
                      final filtrada = _busca.isEmpty
                          ? lista
                          : lista
                                .where(
                                  (a) =>
                                      a.nome.toLowerCase().contains(_busca) ||
                                      a.brinco.toLowerCase().contains(_busca),
                                )
                                .toList();

                      if (lista.isEmpty) {
                        return const _EmptyState();
                      }

                      if (filtrada.isEmpty) {
                        return const Center(
                          child: Text(
                            'Nenhum animal encontrado',
                            style: TextStyle(
                              color: AppColors.text4,
                              fontFamily: 'DM Sans',
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                        itemCount: filtrada.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 1),
                        itemBuilder: (context, i) => _AnimalItem(
                          animal: filtrada[i],
                          isFirst: i == 0,
                          isLast: i == filtrada.length - 1,
                          onTap: () {
                            ref
                                .read(animalEmVisualizacaoProvider.notifier)
                                .abrir(filtrada[i]);

                            AppCoordinator.goToDetalhesAnimal(context);
                          },
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

// =============================================================================
// ITEM DA LISTA
// =============================================================================

class _AnimalItem extends StatelessWidget {
  const _AnimalItem({
    required this.animal,
    required this.onTap,
    required this.isFirst,
    required this.isLast,
  });

  final AnimalModel animal;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  int get _idadeAnos {
    final hoje = DateTime.now();
    int anos = hoje.year - animal.dataNascimento.year;
    if (hoje.month < animal.dataNascimento.month ||
        (hoje.month == animal.dataNascimento.month &&
            hoje.day < animal.dataNascimento.day)) {
      anos--;
    }
    return anos;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(
            top: isFirst ? const Radius.circular(12) : Radius.zero,
            bottom: isLast ? const Radius.circular(12) : Radius.zero,
          ),
          border: Border(
            left: const BorderSide(color: AppColors.border),
            right: const BorderSide(color: AppColors.border),
            top: isFirst
                ? const BorderSide(color: AppColors.border)
                : BorderSide.none,
            bottom: const BorderSide(color: AppColors.border),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.accentBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.pets_rounded,
                color: AppColors.accent,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    animal.nome.isNotEmpty
                        ? animal.nome
                        : 'Brinco #${animal.brinco}',
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${animal.raca} · ${_idadeAnos}a · ${animal.pesoAtual.toStringAsFixed(0)}kg',
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
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// EMPTY STATE
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
              Icons.pets_rounded,
              color: AppColors.accent,
              size: 34,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Nenhum animal',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'DM Sans',
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Cadastre o primeiro animal desta\npropriedade para começar.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.text4,
              fontSize: 13,
              fontFamily: 'DM Sans',
            ),
          ),
          const SizedBox(height: 28),
          BovPrimaryButton(
            label: 'Cadastrar Animal',
            onPressed: () => AppCoordinator.goToNovoAnimal(context),
          ),
        ],
      ),
    );
  }
}

class _SemPropriedadeState extends StatelessWidget {
  const _SemPropriedadeState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.home_work_outlined,
                size: 32,
                color: AppColors.text3,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Nenhuma propriedade cadastrada',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.text,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'DM Sans',
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Cadastre uma propriedade para começar a gerenciar seus animais.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.text4,
                fontSize: 14,
                height: 1.5,
                fontFamily: 'DM Sans',
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: BovPrimaryButton(
                label: 'Cadastrar propriedade',
                onPressed: () {
                  AppCoordinator.goToNovaPropriedade(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
