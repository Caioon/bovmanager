import 'package:bov_manager/models/animal_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'model_factories.dart';

void main() {
  group('AnimalModel', () {
    group('fromMap / toMap', () {
      test('toMap serializa todos os campos corretamente', () {
        final animal = makeAnimal(
          nome: 'Boi Teste',
          brinco: 'A001',
          raca: 'Nelore',
          pesoAtual: 450.0,
          dataNascimento: DateTime(2020, 1, 1),
          fotoUrl: 'https://exemplo.com/foto.jpg',
        );

        final map = animal.toMap();

        expect(map['nome'], 'Boi Teste');
        expect(map['brinco'], 'A001');
        expect(map['raca'], 'Nelore');
        expect(map['pesoAtual'], 450.0);
        expect(map['dataNascimento'], DateTime(2020, 1, 1).toIso8601String());
        expect(map['fotoUrl'], 'https://exemplo.com/foto.jpg');
      });

      test('fromMap desserializa corretamente', () {
        final map = {
          'nome': 'Boi Teste',
          'brinco': 'A001',
          'raca': 'Nelore',
          'pesoAtual': 450.0,
          'dataNascimento': DateTime(2020, 1, 1).toIso8601String(),
          'fotoUrl': 'https://exemplo.com/foto.jpg',
        };

        final animal = AnimalModel.fromMap(map, 'animal-1');

        expect(animal.id, 'animal-1');
        expect(animal.nome, 'Boi Teste');
        expect(animal.brinco, 'A001');
        expect(animal.raca, 'Nelore');
        expect(animal.pesoAtual, 450.0);
        expect(animal.dataNascimento, DateTime(2020, 1, 1));
        expect(animal.fotoUrl, 'https://exemplo.com/foto.jpg');
      });

      test('fromMap com fotoUrl ausente retorna campo null', () {
        final map = {
          'nome': 'Boi Teste',
          'brinco': 'A001',
          'raca': 'Nelore',
          'pesoAtual': 450.0,
          'dataNascimento': DateTime(2020, 1, 1).toIso8601String(),
        };

        final animal = AnimalModel.fromMap(map, 'animal-1');

        expect(animal.fotoUrl, isNull);
      });

      test('round-trip toMap → fromMap preserva todos os campos', () {
        final original = makeAnimal(
          fotoUrl: 'https://exemplo.com/foto.jpg',
        );

        final map = original.toMap();
        final restaurado = AnimalModel.fromMap(map, original.id);

        expect(restaurado.id, original.id);
        expect(restaurado.nome, original.nome);
        expect(restaurado.brinco, original.brinco);
        expect(restaurado.raca, original.raca);
        expect(restaurado.pesoAtual, original.pesoAtual);
        expect(restaurado.dataNascimento, original.dataNascimento);
        expect(restaurado.fotoUrl, original.fotoUrl);
      });
    });
  });
}
