import 'package:bov_manager/repositories/tarefa_repository.dart';
import 'package:bov_manager/services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bov_manager/models/tarefa_model.dart';
import 'package:bov_manager/services/tarefa_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockTarefaRepository extends TarefaRepository {
  MockTarefaRepository(FirebaseFirestore firestore)
    : super(firestore: firestore);

  bool criou = false;
  bool atualizou = false;
  bool atualizouStatus = false;
  bool atualizouData = false;
  bool apagou = false;

  @override
  Stream<List<TarefaModel>> listar(String propriedadeId) {
    return Stream.value([]);
  }

  @override
  Future<String> criar(TarefaModel tarefa) async {
    criou = true;
    return 'tarefa123';
  }

  @override
  Future<void> atualizar({
    required String propriedadeId,
    required String tarefaId,
    required String titulo,
    required String descricao,
    required DateTime dataExecucao,
    int? horaExecucaoMinutos,
    bool clearHora = false,
  }) async {
    atualizou = true;
  }

  @override
  Future<void> atualizarStatus({
    required String propriedadeId,
    required String tarefaId,
    required StatusTarefa status,
  }) async {
    atualizouStatus = true;
  }

  @override
  Future<void> atualizarData({
    required String propriedadeId,
    required String tarefaId,
    required DateTime novaData,
    int? horaExecucaoMinutos,
    bool clearHora = false,
  }) async {
    atualizouData = true;
  }

  @override
  Future<void> apagar({
    required String propriedadeId,
    required String tarefaId,
  }) async {
    apagou = true;
  }
}

class MockNotificationService extends NotificationService {
  bool agendou = false;
  bool cancelou = false;

  @override
  Future<void> agendarNotificacaoTarefa(TarefaModel tarefa) async {
    agendou = true;
  }

  @override
  Future<void> cancelarNotificacaoTarefa(String tarefaId) async {
    cancelou = true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TarefaService', () {
    late MockTarefaRepository repository;
    late MockNotificationService notifications;
    late TarefaService service;
    late FakeFirebaseFirestore firestore;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      repository = MockTarefaRepository(firestore);
      SharedPreferences.setMockInitialValues({'notificacoes_ativas': true});
      notifications = MockNotificationService();
      service = TarefaService(repository as dynamic, notifications as dynamic);
    });
    test('listar() deve retornar tarefas da propriedade', () async {
      final result = await service.listar('prop123').first;

      expect(result, isEmpty);
    });

    test('listar() deve lançar erro com propriedade vazia', () {
      expect(() => service.listar(''), throwsException);
    });

    test('criar() deve criar tarefa corretamente', () async {
      await service.criar(
        titulo: 'Vacinar animais',
        descricao: 'Aplicar vacina',
        dataExecucao: DateTime(2026),
        propriedadeId: 'prop123',
        usuarioId: 'usuario123',
      );

      expect(repository.criou, true);
      expect(notifications.agendou, true);
    });

    test('criar() deve impedir título vazio', () {
      expect(
        () => service.criar(
          titulo: '',
          descricao: '',
          dataExecucao: DateTime(2026),
          propriedadeId: 'prop123',
          usuarioId: 'usuario123',
        ),
        throwsException,
      );
    });

    test('criar() deve impedir propriedade inválida', () {
      expect(
        () => service.criar(
          titulo: 'Tarefa',
          descricao: '',
          dataExecucao: DateTime(2026),
          propriedadeId: '',
          usuarioId: 'usuario123',
        ),
        throwsException,
      );
    });

    test('criar() deve impedir usuário inválido', () {
      expect(
        () => service.criar(
          titulo: 'Tarefa',
          descricao: '',
          dataExecucao: DateTime(2026),
          propriedadeId: 'prop123',
          usuarioId: '',
        ),
        throwsException,
      );
    });

    test('editar() deve atualizar tarefa e reagendar notificação', () async {
      await service.editar(
        propriedadeId: 'prop123',
        tarefaId: 'tarefa123',
        titulo: 'Nova tarefa',
        descricao: 'Descrição',
        dataExecucao: DateTime(2026),
      );

      expect(repository.atualizou, true);
      expect(notifications.cancelou, true);
      expect(notifications.agendou, true);
    });

    test('concluir() deve alterar status e cancelar notificação', () async {
      await service.concluir(propriedadeId: 'prop123', tarefaId: 'tarefa123');

      expect(repository.atualizouStatus, true);
      expect(notifications.cancelou, true);
    });

    test('reabrir() deve alterar status para pendente e reagendar', () async {
      final tarefa = TarefaModel(
        id: 'tarefa123',
        titulo: 'Tarefa',
        descricao: '',
        dataExecucao: DateTime(2026),
        status: StatusTarefa.concluida,
        propriedadeId: 'prop123',
        usuarioId: 'usuario123',
      );

      await service.reabrir(propriedadeId: 'prop123', tarefa: tarefa);

      expect(repository.atualizouStatus, true);
      expect(notifications.agendou, true);
    });

    test('adicionar adiamento deve atualizar data e reagendar', () async {
      await service.adiar(
        propriedadeId: 'prop123',
        tarefaId: 'tarefa123',
        novaData: DateTime(2026),
        titulo: 'Tarefa adiada',
      );

      expect(repository.atualizouData, true);
      expect(notifications.cancelou, true);
      expect(notifications.agendou, true);
    });

    test('apagar() deve remover tarefa e cancelar notificação', () async {
      await service.apagar(propriedadeId: 'prop123', tarefaId: 'tarefa123');

      expect(repository.apagou, true);
      expect(notifications.cancelou, true);
    });

    test('editar() deve impedir IDs vazios', () {
      expect(
        () => service.editar(
          propriedadeId: '',
          tarefaId: '',
          titulo: 'Tarefa',
          descricao: '',
          dataExecucao: DateTime(2026),
        ),
        throwsException,
      );
    });
  });
}
