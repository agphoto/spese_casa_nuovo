import 'package:intl/intl.dart';

/// Formattazione e parsing valuta centralizzati (locale italiano).
///
/// Tenuti in un unico punto per coerenza fra lista eventi, totali e statistiche.

final NumberFormat _currencyFormat =
    NumberFormat.currency(locale: 'it_IT', symbol: '€');

/// Formatta un importo come valuta italiana, es. `1234.5` -> `€ 1.234,50`.
String formatCurrency(double amount) => _currencyFormat.format(amount);

/// Converte una stringa digitata dall'utente in `double`.
///
/// Accetta sia la virgola (input naturale in italiano, es. `12,50`) sia il
/// punto come separatore decimale, e ignora i separatori delle migliaia.
/// L'ultimo separatore presente è considerato quello decimale.
/// Ritorna `null` se la stringa non è un numero valido.
double? parseAmount(String? value) {
  if (value == null) return null;
  final s = value.trim();
  if (s.isEmpty) return null;

  final lastComma = s.lastIndexOf(',');
  final lastDot = s.lastIndexOf('.');
  final decimalPos = lastComma > lastDot ? lastComma : lastDot;

  if (decimalPos == -1) {
    return double.tryParse(s);
  }

  final intPart = s.substring(0, decimalPos).replaceAll(RegExp(r'[.,]'), '');
  final fracPart = s.substring(decimalPos + 1).replaceAll(RegExp(r'[.,]'), '');
  return double.tryParse('$intPart.$fracPart');
}
