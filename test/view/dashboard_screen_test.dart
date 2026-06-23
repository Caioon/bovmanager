import 'package:bov_manager/models/propriedade_model.dart';
import 'package:bov_manager/models/usuario_model.dart';
import 'package:bov_manager/repositories/usuario_repository.dart';
import 'package:bov_manager/view/dashboard_screen.dart';
import 'package:bov_manager/viewmodels/propriedade_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DashboardScreen', () {
    Widget buildScreen({
      AsyncValue<UsuarioModel?> usuario = const AsyncData(null),

      AsyncValue<PropriedadeModel?> propriedade = const AsyncData(null),
    }) {
      return ProviderScope(
        overrides: [
          usuarioAtualProvider.overrideWithValue(usuario),

          propriedadeSelecionadaProvider.overrideWithValue(propriedade),
        ],
        child: const MaterialApp(home: DashboardScreen()),
      );
    }

    testWidgets('Smoke test - renderiza sem crashar', (tester) async {
      await tester.pumpWidget(buildScreen());

      expect(find.byType(DashboardScreen), findsOneWidget);
    });

    testWidgets(
      'Widgets principais - exibe carregamento quando usuário não existe',
      (tester) async {
        await tester.pumpWidget(buildScreen(usuario: const AsyncData(null)));

        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'Comportamento básico - exibe estado vazio sem propriedade selecionada',
      (tester) async {
        await tester.pumpWidget(
          buildScreen(
            usuario: const AsyncData(null),
            propriedade: const AsyncData(null),
          ),
        );

        await tester.pump();

        expect(find.byType(Scaffold), findsOneWidget);
      },
    );
  });
}
