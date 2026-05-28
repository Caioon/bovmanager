import 'package:bov_manager/core/theme/app_colors.dart';
import 'package:bov_manager/firebase_options.dart';
import 'package:bov_manager/repositories/usuario_repository.dart';
import 'package:bov_manager/view/app_shell.dart';
import 'package:bov_manager/view/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  tz.initializeTimeZones();

  final timezoneInfo = await FlutterTimezone.getLocalTimezone();

  tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BovManager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuarioAsync = ref.watch(usuarioAtualProvider);

    return usuarioAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.accent)),
      ),
      error: (e, _) => const LoginScreen(),
      data: (usuario) =>
          usuario != null ? const AppShell() : const LoginScreen(),
    );
  }
}
