import 'package:bov_manager/view/cadastro_screen.dart';
import 'package:bov_manager/view/dashboard_screen.dart';
import 'package:bov_manager/view/detalhes_animal_screen.dart';
import 'package:bov_manager/view/detalhes_propriedade_screen.dart';
import 'package:bov_manager/view/historico_animal_screen.dart';
import 'package:bov_manager/view/home_screen.dart';
import 'package:bov_manager/view/lista_animais_screen.dart';
import 'package:bov_manager/view/lista_pastos_screen.dart';
import 'package:bov_manager/view/lista_rebanho_screen.dart';
import 'package:bov_manager/view/login_screen.dart';
import 'package:bov_manager/view/mover_rebanho_screen.dart';
import 'package:bov_manager/view/nova_propriedade_screen.dart';
import 'package:bov_manager/view/novo_animal_screen.dart';
import 'package:bov_manager/view/novo_pasto_screen.dart';
import 'package:bov_manager/view/novo_rebanho_screen.dart';
import 'package:bov_manager/view/propriedade_screen.dart';
import 'package:flutter/material.dart';

/// Centralizador de navegação do BovManager.
/// Todos os pushes e transições de tela passam por aqui.
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
  static void goToLogin(BuildContext context) {
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
  static void goToHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      _slideRoute(const HomeScreen()),
      (route) => false,
    );
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

  static void goToNovoPasto(BuildContext context) {
    Navigator.push(context, _slideRoute(const NovoPastoScreen()));
  }

  static void goToListaRebanhos(BuildContext context) {
    Navigator.push(context, _slideRoute(const ListaRebanhoScreen()));
  }

  static void goToNovoRebanho(BuildContext context) {
    Navigator.push(context, _slideRoute(const NovoRebanhoScreen()));
  }

  static void goToMoverRebanho(BuildContext context) {
    Navigator.push(context, _slideRoute(const MoverRebanhoScreen()));
  }
}
