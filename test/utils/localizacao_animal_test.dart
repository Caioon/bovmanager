import 'package:bov_manager/models/historico_animal_model.dart';
import 'package:bov_manager/models/historico_tipo.dart';
import 'package:bov_manager/utils/localizacao_animal.dart';
import 'package:flutter_test/flutter_test.dart';

HistoricoAnimalModel evento({
  required HistoricoTipo tipo,
  String? rebanhoId,
  String? pastoId,
  String? nomeRebanho,
  String? nomePasto,
}) {
  return HistoricoAnimalModel(
    id: tipo.valor,
    animalId: 'animal-1',
    tipo: tipo,
    data: DateTime(2026, 11, 14),
    rebanhoDestinoId: rebanhoId,
    pastoDestinoId: pastoId,
    nomeRebanhoDestino: nomeRebanho,
    nomePastoDestino: nomePasto,
  );
}

void main() {
  test('entrada reconhece vínculo pelos IDs mesmo sem nomes salvos', () {
    final local = LocalizacaoAnimal.deHistoricos([
      evento(
        tipo: HistoricoTipo.entrada,
        rebanhoId: 'rebanho-1',
        pastoId: 'pasto-1',
      ),
    ]);
    expect(local?.rebanhoId, 'rebanho-1');
    expect(local?.pastoId, 'pasto-1');
    expect(local?.nomeRebanho, isNull);
  });

  test('pesagem recente não remove rebanho nem pasto', () {
    final local = LocalizacaoAnimal.deHistoricos([
      evento(tipo: HistoricoTipo.pesagem),
      evento(
        tipo: HistoricoTipo.entrada,
        rebanhoId: 'rebanho-1',
        pastoId: 'pasto-1',
      ),
    ]);
    expect(local?.rebanhoId, 'rebanho-1');
    expect(local?.pastoId, 'pasto-1');
  });

  test('movimentação do rebanho com nomes nulos conserva IDs', () {
    final local = LocalizacaoAnimal.deHistoricos([
      evento(
        tipo: HistoricoTipo.mudarPastoComRebanho,
        rebanhoId: 'rebanho-1',
        pastoId: 'pasto-2',
      ),
      evento(
        tipo: HistoricoTipo.entrada,
        rebanhoId: 'rebanho-1',
        pastoId: 'pasto-1',
      ),
    ]);
    expect(local?.rebanhoId, 'rebanho-1');
    expect(local?.pastoId, 'pasto-2');
  });

  test('saída intencional do rebanho mantém o pasto', () {
    final local = LocalizacaoAnimal.deHistoricos([
      evento(
        tipo: HistoricoTipo.sairRebanhoManterPasto,
        pastoId: 'pasto-1',
      ),
      evento(
        tipo: HistoricoTipo.entrada,
        rebanhoId: 'rebanho-1',
        pastoId: 'pasto-1',
      ),
    ]);
    expect(local?.rebanhoId, isNull);
    expect(local?.pastoId, 'pasto-1');
  });

  test('mudança de pasto sem rebanho preserva destino', () {
    final local = LocalizacaoAnimal.deHistoricos([
      evento(
        tipo: HistoricoTipo.mudarPastoContinuarSemRebanho,
        pastoId: 'pasto-2',
      ),
      evento(tipo: HistoricoTipo.entrada, pastoId: 'pasto-1'),
    ]);
    expect(local?.rebanhoId, isNull);
    expect(local?.pastoId, 'pasto-2');
  });

  test('sem histórico de movimentação retorna null', () {
    expect(
      LocalizacaoAnimal.deHistoricos([evento(tipo: HistoricoTipo.pesagem)]),
      isNull,
    );
  });
}
