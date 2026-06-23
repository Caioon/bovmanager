import 'package:bov_manager/view/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppShell', () {
    Widget buildScreen() {
      return const ProviderScope(
        child: MaterialApp(
          home: AppShell(),
        ),
      );
    }

    testWidgets('Smoke test - renderiza sem crashar', (tester) async {
      await tester.pumpWidget(buildScreen());

      expect(find.byType(AppShell), findsOneWidget);
      expect(find.byType(IndexedStack), findsOneWidget);
    });

    testWidgets(
      'Widgets principais - exibe os itens da navegação inferior',
      (tester) async {
        await tester.pumpWidget(buildScreen());

        expect(find.byIcon(Icons.dashboard_rounded), findsOneWidget);
        expect(find.byIcon(Icons.home_work_rounded), findsOneWidget);
        expect(find.byIcon(Icons.pets), findsOneWidget);
        expect(find.byIcon(Icons.person_rounded), findsOneWidget);

        expect(find.text('Dashboard'), findsWidgets);
        expect(find.text('Propriedades'), findsWidgets);
        expect(find.text('Animais'), findsWidgets);
        expect(find.text('Perfil'), findsWidgets);
      },
    );

    testWidgets(
      'Comportamento básico - permite navegar entre abas sem lançar exceções',
      (tester) async {
        await tester.pumpWidget(buildScreen());

        await tester.tap(find.byIcon(Icons.home_work_rounded));
        await tester.pump();

        await tester.tap(find.byIcon(Icons.pets));
        await tester.pump();

        await tester.tap(find.byIcon(Icons.person_rounded));
        await tester.pump();

        expect(tester.takeException(), isNull);
      },
    );
  });
}
