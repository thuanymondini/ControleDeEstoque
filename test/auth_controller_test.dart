import 'package:controle_estoque/data/auth_repository.dart';
import 'package:controle_estoque/models/user_account.dart';
import 'package:controle_estoque/state/auth_controller.dart';
import 'package:flutter_test/flutter_test.dart';

/// Repositorio em memoria para testar o login sem SharedPreferences.
class FakeAuthRepository extends AuthRepository {
  FakeAuthRepository({this.session});

  List<UserAccount> accounts = [];
  String? session;

  @override
  Future<List<UserAccount>> loadAccounts() async => List.of(accounts);

  @override
  Future<void> saveAccounts(List<UserAccount> accounts) async {
    this.accounts = List.of(accounts);
  }

  @override
  Future<String?> loadSession() async => session;

  @override
  Future<void> saveSession(String email) async {
    session = email;
  }

  @override
  Future<void> clearSession() async {
    session = null;
  }
}

Future<AuthController> buildController(FakeAuthRepository repository) async {
  final auth = AuthController(repository: repository);
  await auth.load();
  return auth;
}

void main() {
  group('sessao', () {
    test('comeca deslogado quando nao ha sessao salva', () async {
      final auth = await buildController(FakeAuthRepository());

      expect(auth.isLoading, isFalse);
      expect(auth.isAuthenticated, isFalse);
    });

    test('cria a conta de demonstracao na primeira execucao', () async {
      final repository = FakeAuthRepository();
      await buildController(repository);

      expect(repository.accounts, hasLength(1));
      expect(repository.accounts.single.email, AuthController.demoEmail);
    });

    test('restaura a sessao salva', () async {
      final auth = await buildController(
        FakeAuthRepository(session: AuthController.demoEmail),
      );

      expect(auth.isAuthenticated, isTrue);
      expect(auth.currentUser!.name, AuthController.demoName);
    });

    test('ignora sessao de conta que nao existe mais', () async {
      final auth = await buildController(
        FakeAuthRepository(session: 'sumiu@estoque.com'),
      );

      expect(auth.isAuthenticated, isFalse);
    });

    test('sair apaga a sessao', () async {
      final repository = FakeAuthRepository(session: AuthController.demoEmail);
      final auth = await buildController(repository);

      await auth.logout();

      expect(auth.isAuthenticated, isFalse);
      expect(repository.session, isNull);
    });
  });

  group('login', () {
    test('entra com a conta de demonstracao e salva a sessao', () async {
      final repository = FakeAuthRepository();
      final auth = await buildController(repository);

      await auth.login(
        email: '  ADMIN@Estoque.com ',
        password: AuthController.demoPassword,
      );

      expect(auth.isAuthenticated, isTrue);
      expect(repository.session, AuthController.demoEmail);
    });

    test('recusa senha incorreta', () async {
      final auth = await buildController(FakeAuthRepository());

      await expectLater(
        auth.login(email: AuthController.demoEmail, password: 'errada'),
        throwsA(isA<AuthException>()),
      );
      expect(auth.isAuthenticated, isFalse);
    });

    test('recusa e-mail sem conta', () async {
      final auth = await buildController(FakeAuthRepository());

      await expectLater(
        auth.login(email: 'ninguem@estoque.com', password: 'admin123'),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('criar conta', () {
    test('cria a conta, entra e permite login depois', () async {
      final repository = FakeAuthRepository();
      final auth = await buildController(repository);

      await auth.register(
        name: ' Maria Silva ',
        email: 'Maria@Email.com',
        password: 'segredo1',
      );

      expect(auth.isAuthenticated, isTrue);
      expect(auth.currentUser!.name, 'Maria Silva');
      expect(repository.session, 'maria@email.com');
      expect(repository.accounts, hasLength(2));

      await auth.logout();
      await auth.login(email: 'maria@email.com', password: 'segredo1');
      expect(auth.currentUser!.email, 'maria@email.com');
    });

    test('nao guarda a senha em texto puro', () async {
      final repository = FakeAuthRepository();
      final auth = await buildController(repository);

      await auth.register(
        name: 'Maria',
        email: 'maria@email.com',
        password: 'segredo1',
      );

      final saved = repository.accounts.last.toJson().values;
      expect(saved, isNot(contains('segredo1')));
    });

    test('recusa e-mail ja cadastrado', () async {
      final auth = await buildController(FakeAuthRepository());

      await expectLater(
        auth.register(
          name: 'Outro Admin',
          email: ' ADMIN@estoque.com',
          password: 'qualquer1',
        ),
        throwsA(isA<AuthException>()),
      );
      expect(auth.isAuthenticated, isFalse);
    });

    test('recusa senha curta', () async {
      final auth = await buildController(FakeAuthRepository());

      await expectLater(
        auth.register(name: 'Maria', email: 'maria@email.com', password: '123'),
        throwsA(isA<AuthException>()),
      );
    });
  });
}
