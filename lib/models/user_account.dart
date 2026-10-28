import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Conta de usuario guardada no aparelho.
///
/// A senha nunca e salva em texto puro: guardamos apenas o SHA-256 de
/// salt + senha, com um salt aleatorio por conta.
class UserAccount {
  const UserAccount({
    required this.name,
    required this.email,
    required this.salt,
    required this.passwordHash,
  });

  /// Cria a conta gerando o salt e o hash da senha.
  factory UserAccount.create({
    required String name,
    required String email,
    required String password,
  }) {
    final random = Random.secure();
    final salt = base64Encode(
      List<int>.generate(16, (_) => random.nextInt(256)),
    );
    return UserAccount(
      name: name.trim(),
      email: normalizeEmail(email),
      salt: salt,
      passwordHash: _hash(salt, password),
    );
  }

  final String name;
  final String email;
  final String salt;
  final String passwordHash;

  bool checkPassword(String password) => _hash(salt, password) == passwordHash;

  /// E-mail sem espacos e em minusculas, para comparar contas.
  static String normalizeEmail(String email) => email.trim().toLowerCase();

  static String _hash(String salt, String password) =>
      sha256.convert(utf8.encode('$salt$password')).toString();

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'salt': salt,
    'passwordHash': passwordHash,
  };

  factory UserAccount.fromJson(Map<String, dynamic> json) {
    return UserAccount(
      name: json['name'] as String,
      email: json['email'] as String,
      salt: json['salt'] as String,
      passwordHash: json['passwordHash'] as String,
    );
  }
}
