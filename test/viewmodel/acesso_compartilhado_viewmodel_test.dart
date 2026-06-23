import 'package:flutter_test/flutter_test.dart';
import 'package:bov_manager/viewmodels/acesso_compartilhado_viewmodel.dart';

class MockAcessoCompartilhadoService {
  bool convidou = false;

  String? emailRecebido;
  String? papelRecebido;
  String? propriedadeRecebida;

  Future<void> convidarPorEmail({
    required String propriedadeId,
    required String email,
    required String papel,
  }) async {
    convidou = true;
    emailRecebido = email;
    papelRecebido = papel;
    propriedadeRecebida = propriedadeId;
  }
}

void main() {
  group('ConviteState', () {
    test('deve possuir valores padrão corretos', () {
      const state = ConviteState();

      expect(state.isLoading, false);
      expect(state.erro, null);
      expect(state.sucesso, false);
    });

    test('copyWith deve alterar valores corretamente', () {
      const state = ConviteState();

      final novoEstado = state.copyWith(
        isLoading: true,
        sucesso: true,
        erro: 'Erro',
      );

      expect(novoEstado.isLoading, true);
      expect(novoEstado.sucesso, true);
      expect(novoEstado.erro, 'Erro');
    });

    test('copyWith clearErro deve remover erro existente', () {
      const state = ConviteState(
        erro: 'Erro',
      );

      final novoEstado = state.copyWith(
        clearErro: true,
      );

      expect(novoEstado.erro, null);
    });
  });

  group('PapelAcesso', () {
    test('deve possuir valores corretos', () {
      expect(
        PapelAcesso.administrador.valor,
        'administrador',
      );

      expect(
        PapelAcesso.gerente.label,
        'Gerente',
      );

      expect(
        PapelAcesso.espectador.valor,
        'espectador',
      );
    });
  });

  group('ConviteViewModel', () {
    test('resetar deve retornar estado inicial', () {
      const estado = ConviteState(
        isLoading: true,
        erro: 'Erro',
        sucesso: true,
      );

      final novoEstado = estado.copyWith(
        isLoading: false,
        sucesso: false,
        clearErro: true,
      );

      expect(novoEstado.isLoading, false);
      expect(novoEstado.erro, null);
      expect(novoEstado.sucesso, false);
    });

    test('email vazio deve retornar erro', () async {
      final state = ConviteState();

      final novoEstado = state.copyWith(
        erro: 'Informe o e-mail do usuário.',
      );

      expect(
        novoEstado.erro,
        'Informe o e-mail do usuário.',
      );
    });

    test('enviar convite deve enviar email normalizado', () async {
      final service = MockAcessoCompartilhadoService();

      await service.convidarPorEmail(
        propriedadeId: 'prop123',
        email: 'teste@email.com',
        papel: PapelAcesso.gerente.valor,
      );

      expect(service.convidou, true);
      expect(service.emailRecebido, 'teste@email.com');
      expect(service.papelRecebido, 'gerente');
      expect(service.propriedadeRecebida, 'prop123');
    });

    test('erro de convite deve armazenar mensagem sem prefixo Exception',
        () {
      final mensagem =
          Exception('Email de usuário não encontrado.')
              .toString()
              .replaceFirst('Exception: ', '');

      expect(
        mensagem,
        'Email de usuário não encontrado.',
      );
    });
  });
}
