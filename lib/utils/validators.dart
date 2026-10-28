final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// Validacao do campo de e-mail do login e do cadastro.
String? validateEmail(String? value) {
  final email = (value ?? '').trim();
  if (email.isEmpty) return 'Informe o e-mail.';
  if (!_emailPattern.hasMatch(email)) return 'Informe um e-mail válido.';
  return null;
}
