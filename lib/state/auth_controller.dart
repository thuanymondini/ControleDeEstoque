import 'package:flutter/foundation.dart';

import '../data/auth_repository.dart';
import '../models/user_account.dart';

/// Erro de login ou cadastro (ex.: e-mail ou senha incorretos).
class AuthException implements Exception {
  AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Contas e sessao do usuario. O app ainda nao tem backend, entao as contas
/// ficam salvas no aparelho.
class AuthController extends ChangeNotifier {
  AuthController({AuthRepository? repository})
    : _repository = repository ?? AuthRepository();

  /// Conta criada na primeira execucao, mostrada na tela de login.
  static const demoName = 'Administrador';
  static const demoEmail = 'admin@estoque.com';
  static const demoPassword = 'admin123';

  static const minPasswordLength = 6;

  final AuthRepository _repository;

  List<UserAccount> _accounts = [];
  UserAccount? _currentUser;
  bool _isLoading = true;

  bool get isLoading => _isLoading;

  bool get isAuthenticated => _currentUser != null;

  UserAccount? get currentUser => _currentUser;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    _accounts = await _repository.loadAccounts();
    if (_accounts.isEmpty) {
      _accounts = [
        UserAccount.create(
          name: demoName,
          email: demoEmail,
          password: demoPassword,
        ),
      ];
      await _repository.saveAccounts(_accounts);
    }

    final sessionEmail = await _repository.loadSession();
    _currentUser = sessionEmail == null ? null : _findAccount(sessionEmail);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> login({required String email, required String password}) async {
    final account = _findAccount(email);

    if (account == null || !account.checkPassword(password)) {
      throw AuthException('E-mail ou senha incorretos.');
    }

    await _startSession(account);
  }

  /// Cria a conta e ja entra com ela.
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (name.trim().isEmpty) {
      throw AuthException('Informe o seu nome.');
    }
    if (password.length < minPasswordLength) {
      throw AuthException(
        'A senha precisa ter pelo menos $minPasswordLength caracteres.',
      );
    }
    if (_findAccount(email) != null) {
      throw AuthException('Já existe uma conta com este e-mail.');
    }

    final account = UserAccount.create(
      name: name,
      email: email,
      password: password,
    );
    _accounts = [..._accounts, account];
    await _repository.saveAccounts(_accounts);
    await _startSession(account);
  }

  Future<void> logout() async {
    await _repository.clearSession();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> _startSession(UserAccount account) async {
    await _repository.saveSession(account.email);
    _currentUser = account;
    notifyListeners();
  }

  UserAccount? _findAccount(String email) {
    final normalized = UserAccount.normalizeEmail(email);
    for (final account in _accounts) {
      if (account.email == normalized) return account;
    }
    return null;
  }
}
