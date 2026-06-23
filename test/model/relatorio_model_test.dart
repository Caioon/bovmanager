import 'package:flutter_test/flutter_test.dart';
import 'package:bov_manager/models/relatorio_model.dart';

void main() {
  group('RelatorioModel', () {
    final dataGeracao = DateTime(2026, 1, 10, 12, 30);

    final relatorio = RelatorioModel(
      id: 'relatorio123',
      propriedadeId: 'propriedade123',
      usuarioId: 'usuario123',
      dataGeracao: dataGeracao,
      tipo: 'animais',
      urlArquivo: 'https://arquivo.com/relatorio.pdf',
    );

    test('toMap() deve converter todos os campos corretamente', () {
      final map = relatorio.toMap();

      expect(map['propriedadeId'], 'propriedade123');
      expect(map['usuarioId'], 'usuario123');
      expect(map['dataGeracao'], dataGeracao.toIso8601String());
      expect(map['tipo'], 'animais');
      expect(map['urlArquivo'], 'https://arquivo.com/relatorio.pdf');
    });

    test('RelatorioModel.fromMap() deve criar objeto corretamente', () {
      final map = {
        'propriedadeId': 'propriedade123',
        'usuarioId': 'usuario123',
        'dataGeracao': dataGeracao.toIso8601String(),
        'tipo': 'animais',
        'urlArquivo': 'https://arquivo.com/relatorio.pdf',
      };

      final result = RelatorioModel.fromMap(map, 'relatorio123');

      expect(result.id, 'relatorio123');
      expect(result.propriedadeId, 'propriedade123');
      expect(result.usuarioId, 'usuario123');
      expect(result.dataGeracao, dataGeracao);
      expect(result.tipo, 'animais');
      expect(result.urlArquivo, 'https://arquivo.com/relatorio.pdf');
    });

    test('Round-trip toMap() → fromMap() deve manter todos os valores', () {
      final map = relatorio.toMap();

      final result = RelatorioModel.fromMap(
        map,
        relatorio.id,
      );

      expect(result.id, relatorio.id);
      expect(result.propriedadeId, relatorio.propriedadeId);
      expect(result.usuarioId, relatorio.usuarioId);
      expect(result.dataGeracao, relatorio.dataGeracao);
      expect(result.tipo, relatorio.tipo);
      expect(result.urlArquivo, relatorio.urlArquivo);
    });

    test('fromMap() com campos opcionais ausentes deve usar valores padrão', () {
      final map = {
        'dataGeracao': dataGeracao.toIso8601String(),
      };

      final result = RelatorioModel.fromMap(map, 'relatorio123');

      expect(result.id, 'relatorio123');
      expect(result.propriedadeId, '');
      expect(result.usuarioId, '');
      expect(result.dataGeracao, dataGeracao);
      expect(result.tipo, '');
      expect(result.urlArquivo, '');
    });
  });
}
