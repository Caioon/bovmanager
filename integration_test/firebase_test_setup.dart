import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:integration_test/integration_test.dart';
import 'package:http/http.dart' as http;

const _projectId = 'bovmanager';
const _emulatorHost = '10.0.2.2';

bool _emulatorConfigured = false;

Future<void> setupFirebaseEmulator() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  if (_emulatorConfigured) return;
  _emulatorConfigured = true;

  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'fake-key',
        appId: '1:271303804122:android:8bb1cc655e2cad0e4091e3',
        messagingSenderId: '271303804122',
        projectId: _projectId,
      ),
    );
  } catch (e) {
    if (!e.toString().contains('duplicate-app')) rethrow;
  }

  FirebaseFirestore.instance.useFirestoreEmulator(_emulatorHost, 8080);
  await FirebaseAuth.instance.useAuthEmulator(_emulatorHost, 9099);
}

Future<void> clearFirestoreEmulator() async {
  await http.delete(
    Uri.parse(
      'http://$_emulatorHost:8080/emulator/v1/projects/$_projectId/databases/(default)/documents',
    ),
  );
}
