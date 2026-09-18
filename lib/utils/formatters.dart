const _weekdays = [
  'Segunda-feira',
  'Terça-feira',
  'Quarta-feira',
  'Quinta-feira',
  'Sexta-feira',
  'Sábado',
  'Domingo',
];

const _months = [
  'janeiro',
  'fevereiro',
  'março',
  'abril',
  'maio',
  'junho',
  'julho',
  'agosto',
  'setembro',
  'outubro',
  'novembro',
  'dezembro',
];

/// "Quarta-feira, 02 de setembro de 2026" (cabecalho da tela inicial).
String formatFullDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  return '${_weekdays[date.weekday - 1]}, $day de '
      '${_months[date.month - 1]} de ${date.year}';
}

/// Formatacoes simples de data, sem depender do pacote intl.
String formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

String formatDateTime(DateTime date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '${formatDate(date)} às $hour:$minute';
}

String relativeDate(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inMinutes < 1) return 'agora';
  if (difference.inMinutes < 60) return 'há ${difference.inMinutes} min';
  if (difference.inHours < 24) return 'há ${difference.inHours} h';
  if (difference.inDays == 1) return 'ontem';
  if (difference.inDays < 7) return 'há ${difference.inDays} dias';
  return formatDate(date);
}
