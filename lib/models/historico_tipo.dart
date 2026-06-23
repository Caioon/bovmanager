// =============================================================================
// TIPOS DE HISTÓRICO — fonte única de verdade
// =============================================================================

enum HistoricoCategoria { entrada, pesagem, movimentacao }

enum HistoricoTipo {
  entrada,
  pesagem,
  entrarRebanho,
  mudarRebanho,
  sairRebanhoMudarPasto,
  sairRebanhoManterPasto,
  mudarPasto,
  mudarPastoComRebanho;

  // String salva no Firestore
  String get valor {
    switch (this) {
      case HistoricoTipo.entrada:
        return 'entrada';
      case HistoricoTipo.pesagem:
        return 'pesagem';
      case HistoricoTipo.entrarRebanho:
        return 'entrar_rebanho';
      case HistoricoTipo.mudarRebanho:
        return 'mudar_rebanho';
      case HistoricoTipo.sairRebanhoMudarPasto:
        return 'sair_rebanho_mudar_pasto';
      case HistoricoTipo.sairRebanhoManterPasto:
        return 'sair_rebanho_manter_pasto';
      case HistoricoTipo.mudarPasto:
        return 'mudar_pasto_sem_rebanho';
      case HistoricoTipo.mudarPastoComRebanho:
        return 'mudar_pasto_com_rebanho';
    }
  }

  // Label exibido na UI
  String get label {
    switch (this) {
      case HistoricoTipo.entrada:
        return 'Entrada';
      case HistoricoTipo.pesagem:
        return 'Pesagem';
      case HistoricoTipo.entrarRebanho:
        return 'Entrar em rebanho';
      case HistoricoTipo.mudarRebanho:
        return 'Mudar rebanho';
      case HistoricoTipo.sairRebanhoMudarPasto:
        return 'Sair do rebanho e mudar pasto';
      case HistoricoTipo.sairRebanhoManterPasto:
        return 'Sair do rebanho e manter pasto';
      case HistoricoTipo.mudarPasto:
        return 'Mudar de pasto e continuar sem rebanho';
      case HistoricoTipo.mudarPastoComRebanho:
        return 'Mudar pasto junto do rebanho';
    }
  }

  // Categoria usada para filtrar na tela de histórico
  HistoricoCategoria get categoria {
    switch (this) {
      case HistoricoTipo.entrada:
        return HistoricoCategoria.entrada;
      case HistoricoTipo.pesagem:
        return HistoricoCategoria.pesagem;
      case HistoricoTipo.entrarRebanho:
      case HistoricoTipo.mudarRebanho:
      case HistoricoTipo.sairRebanhoMudarPasto:
      case HistoricoTipo.sairRebanhoManterPasto:
      case HistoricoTipo.mudarPasto:
      case HistoricoTipo.mudarPastoComRebanho:
        return HistoricoCategoria.movimentacao;
    }
  }

  // Parse a partir da string do Firestore
  static HistoricoTipo fromValor(String valor) {
    return HistoricoTipo.values.firstWhere(
      (t) => t.valor == valor,
      orElse: () => HistoricoTipo.entrada,
    );
  }
}
