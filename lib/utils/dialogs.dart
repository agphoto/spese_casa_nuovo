import 'package:flutter/material.dart';

/// Mostra un dialog di conferma Sì/No per azioni distruttive.
///
/// Ritorna `true` solo se l'utente conferma. Centralizzato qui per coerenza
/// fra le varie eliminazioni (eventi, categorie, ...).
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Elimina',
  String cancelLabel = 'Annulla',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            confirmLabel,
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}
