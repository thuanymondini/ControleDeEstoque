import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_account.dart';

/// Guarda as contas criadas no aparelho e a sessao do usuario logado
/// (SharedPreferences), para que o app nao peca login a cada abertura.
class AuthRepository {
  static const _accountsKey = 'controle_estoque.accounts';
  static const _sessionKey = 'controle_estoque.session_email';

  Future<List<UserAccount>> loadAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_accountsKey) ?? const [];
    return raw
        .map(
          (item) =>
              UserAccount.fromJson(jsonDecode(item) as Map<String, dynamic>),
        )
        .toList();
  }

  Future<void> saveAccounts(List<UserAccount> accounts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _accountsKey,
      accounts.map((account) => jsonEncode(account.toJson())).toList(),
    );
  }

  Future<String?> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionKey);
  }

  Future<void> saveSession(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, email);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }
}
