import 'package:bov_manager/view/alterar_cpf_screen.dart';
import 'package:bov_manager/view/alterar_email_screen.dart';
import 'package:bov_manager/view/alterar_nome_screen.dart';
import 'package:bov_manager/view/alterar_senha_screen.dart';
import 'package:bov_manager/view/cadastro_screen.dart';
import 'package:bov_manager/view/dashboard_screen.dart';
import 'package:bov_manager/view/detalhes_animal_screen.dart';
import 'package:bov_manager/view/detalhes_perfil_screen.dart';
import 'package:bov_manager/view/detalhes_propriedade_screen.dart';
import 'package:bov_manager/view/historico_animal_screen.dart';
import 'package:bov_manager/view/lista_animais_screen.dart';
import 'package:bov_manager/view/lista_pastos_screen.dart';
import 'package:bov_manager/view/lista_rebanho_screen.dart';
import 'package:bov_manager/view/lista_tarefas_screen.dart';
import 'package:bov_manager/view/login_screen.dart';
import 'package:bov_manager/view/mapa_configuracao_screen.dart';
import 'package:bov_manager/view/mapa_screen.dart';
import 'package:bov_manager/view/mover_rebanho_screen.dart';
import 'package:bov_manager/view/nova_propriedade_screen.dart';
import 'package:bov_manager/view/novo_animal_screen.dart';
import 'package:bov_manager/view/novo_pasto_screen.dart';
import 'package:bov_manager/view/novo_rebanho_screen.dart';
import 'package:bov_manager/view/perfil_screen.dart';
import 'package:bov_manager/view/propriedade_screen.dart';
import 'package:bov_manager/view/tarefa_screen.dart';
import 'package:flutter/material.dart';

abstract class AppCoordinator {
  // =========================
  // HELPER
  // =========================
  static PageRouteBuilder<T> _slideRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, _, _) => page,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (_, animation, _, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: Curves.easeInOut));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  // =========================
  // AUTH
  // =========================

  /// Navega para o login limpando toda a pilha de navegação.
  ///
  /// [onBeforeNavigate] é executado antes da navegação — use para cancelar
  /// notificações no logout:
  /// ```dart
  /// AppCoordinator.goToLogin(
  ///   context,
  ///   onBeforeNavigate: () =>
  ///     ref.read(notificationServiceProvider).cancelarTodasNotificacoes(),
  /// );
  /// ```
  static Future<void> goToLogin(
    BuildContext context, {
    Future<void> Function()? onBeforeNavigate,
  }) async {
    await onBeforeNavigate?.call();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      _slideRoute(const LoginScreen()),
      (route) => false,
    );
  }

  static void goToCadastro(BuildContext context) {
    Navigator.push(context, _slideRoute(const CadastroScreen()));
  }

  // =========================
  // HOME
  // =========================
  static void goToPerfil(BuildContext context) {
    Navigator.push(context, _slideRoute(const PerfilScreen()));
  }

  // =========================
  // PROPRIEDADES
  // =========================
  static void goToPropriedades(BuildContext context) {
    Navigator.push(context, _slideRoute(const PropriedadesScreen()));
  }

  static void goToNovaPropriedade(BuildContext context) {
    Navigator.push(context, _slideRoute(const NovaPropriedadeScreen()));
  }

  static void goToDetalhesPropriedade(BuildContext context) {
    Navigator.push(context, _slideRoute(const DetalhesPropriedadeScreen()));
  }

  // =========================
  // DASHBOARD
  // =========================
  static void goToDashboard(BuildContext context) {
    Navigator.push(context, _slideRoute(const DashboardScreen()));
  }

  // =========================
  // ANIMAIS
  // =========================
  static void goToListaAnimais(BuildContext context) {
    Navigator.push(context, _slideRoute(const ListaAnimaisScreen()));
  }

  static void goToNovoAnimal(BuildContext context) {
    Navigator.push(context, _slideRoute(const NovoAnimalScreen()));
  }

  static void goToDetalhesAnimal(BuildContext context) {
    Navigator.push(context, _slideRoute(const DetalhesAnimalScreen()));
  }

  static void goToHistoricoAnimal(BuildContext context) {
    Navigator.push(context, _slideRoute(const HistoricoAnimalScreen()));
  }

  static void goToListaPastos(BuildContext context) {
    Navigator.push(context, _slideRoute(const ListaPastosScreen()));
  }

  static Future<void> goToNovoPasto(
    BuildContext context, {
    String? propriedadeId,
  }) {
    return Navigator.push(
      context,
      _slideRoute(NovoPastoScreen(propriedadeId: propriedadeId)),
    );
  }

  static void goToListaRebanhos(BuildContext context) {
    Navigator.push(context, _slideRoute(const ListaRebanhoScreen()));
  }

  static Future<void> goToNovoRebanho(
    BuildContext context, {
    String? propriedadeId,
  }) {
    return Navigator.push(
      context,
      _slideRoute(NovoRebanhoScreen(propriedadeId: propriedadeId)),
    );
  }

  static void goToMoverRebanho(BuildContext context) {
    Navigator.push(context, _slideRoute(const MoverRebanhoScreen()));
  }

  static void goToNovaTarefa(BuildContext context) {
    Navigator.push(context, _slideRoute(const NovaTarefaScreen()));
  }

  static void goToListaTarefas(BuildContext context) {
    Navigator.push(context, _slideRoute(const ListaTarefasScreen()));
  }

  static void goToDetalhesPerfil(BuildContext context) {
    Navigator.push(context, _slideRoute(const DetalhesPerfilScreen()));
  }

  static void goToMapa(BuildContext context) {
    Navigator.push(context, _slideRoute(const MapaScreen()));
  }

  static void goToConfigurarMapa(BuildContext context) {
    Navigator.push(context, _slideRoute(const MapaConfiguracaoScreen()));
  }

  // =========================
  // EDIÇÃO DE PERFIL
  // =========================
  static void goToAlterarNome(
    BuildContext context, {
    required String nomeAtual,
  }) {
    Navigator.push(
      context,
      _slideRoute(AlterarNomeScreen(nomeAtual: nomeAtual)),
    );
  }

  static void goToAlterarEmail(
    BuildContext context, {
    required String emailAtual,
    required String senhaAtual,
  }) {
    Navigator.push(
      context,
      _slideRoute(
        AlterarEmailScreen(emailAtual: emailAtual, senhaAtual: senhaAtual),
      ),
    );
  }

  static void goToAlterarCpf(BuildContext context, {required String cpfAtual}) {
    Navigator.push(context, _slideRoute(AlterarCpfScreen(cpfAtual: cpfAtual)));
  }

  static void goToAlterarSenha(
    BuildContext context, {
    required String senhaAtual,
  }) {
    Navigator.push(
      context,
      _slideRoute(AlterarSenhaScreen(senhaAtual: senhaAtual)),
    );
  }
}
