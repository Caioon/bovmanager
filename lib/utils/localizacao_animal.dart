import 'package:bov_manager/models/historico_animal_model.dart';
import 'package:bov_manager/models/historico_tipo.dart';

/// Localização atual do animal conforme o evento de entrada/movimentação mais
/// recente. A pesagem não altera a localização.
///
/// IDs são a fonte de verdade. Nomes no histórico são apenas rótulos antigos,
/// que podem estar ausentes (por exemplo, após mover o rebanho inteiro).
class LocalizacaoAnimal {
  const LocalizacaoAnimal({
    required this.rebanhoId,
    required this.pastoId,
    this.nomeRebanho,
    this.nomePasto,
  });

  final String? rebanhoId;
  final String? pastoId;
  final String? nomeRebanho;
  final String? nomePasto;

  /// [historicos] deve estar ordenado do mais recente para o mais antigo.
  /// Retorna null quando ainda não existe entrada/movimentação registrada.
  static LocalizacaoAnimal? deHistoricos(
    Iterable<HistoricoAnimalModel> historicos,
  ) {
    for (final registro in historicos) {
      if (registro.tipo == HistoricoTipo.pesagem) continue;
      return LocalizacaoAnimal(
        rebanhoId: _idOuNull(registro.rebanhoDestinoId),
        pastoId: _idOuNull(registro.pastoDestinoId),
        nomeRebanho: registro.nomeRebanhoDestino,
        nomePasto: registro.nomePastoDestino,
      );
    }
    return null;
  }

  static String? _idOuNull(String? id) {
    final valor = id?.trim();
    return valor == null || valor.isEmpty ? null : valor;
  }
}
