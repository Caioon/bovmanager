import 'package:bov_manager/models/pasto_model.dart';
import 'package:bov_manager/models/propriedade_model.dart';
import 'package:bov_manager/models/rebanho_model.dart';
import 'package:bov_manager/repositories/animal_repository.dart';
import 'package:bov_manager/repositories/rebanho_repository.dart';
import 'package:bov_manager/services/historico_animal_service.dart';
import 'package:bov_manager/services/pasto_service.dart';
import 'package:bov_manager/services/rebanho_service.dart';
import 'package:bov_manager/view/novo_animal_screen.dart';
import 'package:bov_manager/viewmodels/animal_viewmodel.dart';
import 'package:bov_manager/viewmodels/propriedade_viewmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Fake — AnimaisViewModel
// ---------------------------------------------------------------------------

class FakeAnimaisViewModel extends AnimaisViewModel {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  @override
  Future<void> criar({
    required String nome,
    required String brinco,
    required String raca,
    required double pesoAtual,
    required DateTime dataNascimento,
    required String? rebanhoId,   // required + nullable — igual ao ViewModel real
    String? pastoDestinoId,
  }) async {}
}

// ---------------------------------------------------------------------------
// Fake — PropriedadeSelecionada
// Necessário porque initState chama requireValue!.id diretamente.
// ---------------------------------------------------------------------------

class FakePropriedadeSelecionada extends PropriedadeSelecionada {
  @override
  AsyncValue<PropriedadeModel?> build() => AsyncData(
    PropriedadeModel(
      id: 'prop-fake-id',
      nome: 'Fazenda Teste',
      proprietarioId: 'uid-fake',
      dataCadastro: DateTime(2024),
    ),
  );
}

// ---------------------------------------------------------------------------
// Fake — PastoService (implements evita o construtor posicional com Firebase)
// ---------------------------------------------------------------------------

class FakePastoService implements PastoService {
  @override
  Future<List<PastoModel>> listar(String propriedadeId) async => [];

  @override
  Stream<List<PastoModel>> listarStream(String propriedadeId) =>
      const Stream.empty();

  @override
  Future<void> criar({
    required String nome,
    required String propriedadeId,
    required double area,
    required String descricao,
    int? limiteAnimais,
  }) async {}

  @override
  Future<String?> verificarBloqueioExclusao({
    required String propriedadeId,
    required String pastoId,
  }) async => null;

  @override
  Future<bool> possuiPoligono({
    required String propriedadeId,
    required String pastoId,
  }) async => false;

  @override
  Future<void> apagar({
    required String propriedadeId,
    required String pastoId,
  }) async {}

  @override
  Future<void> editar({
    required String id,
    required String nome,
    required String propriedadeId,
    required double area,
    required String descricao,
    int? limiteAnimais,
  }) async {}
}

// ---------------------------------------------------------------------------
// Fake — RebanhoService (implements evita o construtor nomeado com Firebase)
// Os getters de campos públicos não são chamados nos testes e lançam
// UnimplementedError apenas se acionados acidentalmente.
// ---------------------------------------------------------------------------

class FakeRebanhoService implements RebanhoService {
  // Campos públicos exigidos pela interface — nunca acionados nos testes.
  @override
  RebanhoRepository get repository => throw UnimplementedError();
  @override
  AnimalRepository get animalRepository => throw UnimplementedError();
  @override
  HistoricoAnimalService get historicoService => throw UnimplementedError();
  @override
  FirebaseFirestore get firestore => throw UnimplementedError();

  @override
  Future<List<RebanhoModel>> listar(String propriedadeId) async => [];

  @override
  Future<void> criar({
    required String nome,
    required String pastoId,
    required String propriedadeId,
  }) async {}

  @override
  Future<void> mover({
    required String rebanhoId,
    required String propriedadeId,
    required String antigoPastoId,
    required String novoPastoId,
    String? nomePastoOrigem,
    String? nomePastoDestino,
    required DateTime data,
  }) async {}

  @override
  Future<String?> podeApagarRebanho({
    required String rebanhoId,
    required String propriedadeId,
  }) async => null;

  @override
  Future<void> apagarRebanho({
    required String rebanhoId,
    required String propriedadeId,
  }) async {}
}

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

Widget buildScreen() {
  return ProviderScope(
    overrides: [
      animaisViewModelProvider.overrideWith(() => FakeAnimaisViewModel()),
      propriedadeSelecionadaProvider.overrideWith(
        () => FakePropriedadeSelecionada(),
      ),
      pastoServiceProvider.overrideWithValue(FakePastoService()),
      rebanhoServiceProvider.overrideWithValue(FakeRebanhoService()),
    ],
    child: const MaterialApp(home: NovoAnimalScreen()),
  );
}

// ---------------------------------------------------------------------------
// Testes
// ---------------------------------------------------------------------------

void main() {
  group('NovoAnimalScreen', () {
    testWidgets('1. Smoke test — tela renderiza sem crashar', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(NovoAnimalScreen), findsOneWidget);
    });

    testWidgets(
      '2. Widgets principais — título, campos do formulário e botões estão presentes',
      (tester) async {
        await tester.pumpWidget(buildScreen());
        await tester.pumpAndSettle();

        // Título da tela
        expect(find.text('Novo Animal'), findsOneWidget);

        // Labels dos campos de texto
        expect(find.text('NOME (OPCIONAL)'), findsOneWidget);
        expect(find.text('BRINCO'), findsOneWidget);
        expect(find.text('PESO (KG)'), findsOneWidget);
        expect(find.text('NASCIMENTO'), findsOneWidget);

        // Os três TextFields (nome, brinco e peso)
        expect(find.byType(TextField), findsNWidgets(3));

        // Seletor de aba Pasto / Rebanho
        expect(find.text('Pasto'), findsOneWidget);
        expect(find.text('Rebanho'), findsOneWidget);

        // Botões de ação
        expect(find.text('Cadastrar Animal'), findsOneWidget);
        expect(find.text('Cancelar'), findsOneWidget);
      },
    );

    testWidgets(
      '3. Comportamento básico — tap em Cadastrar sem pasto selecionado exibe snackbar de erro',
      (tester) async {
        await tester.pumpWidget(buildScreen());
        await tester.pumpAndSettle();

        // A aba "Pasto" é a padrão e o fake retorna lista vazia,
        // portanto _pastoDestino permanece null e o guard dispara.
        // O botão pode estar abaixo da área visível — rola até ele antes de tocar.
        await tester.ensureVisible(find.text('Cadastrar Animal'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Cadastrar Animal'));
        await tester.pumpAndSettle();

        expect(find.text('Selecione um pasto.'), findsOneWidget);
      },
    );
  });
}
