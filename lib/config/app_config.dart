/// Configurazione dell'app.
///
/// L'endpoint del backend è iniettato a compile-time tramite
/// `--dart-define=BACKEND_ENDPOINT=...` (vedi `.vscode/launch.json`).
/// Se non viene fornito, si usa l'endpoint di produzione come default.
class AppConfig {
  /// URL base del backend, senza slash finale.
  /// Es. `http://api.alessiogiuliano.it/quantospendo`.
  static const String backendBaseUrl = String.fromEnvironment(
    'BACKEND_ENDPOINT',
    defaultValue: 'http://api.alessiogiuliano.it/quantospendo',
  );

  /// Endpoint completo per l'upload del backup (con slash finale, come usato
  /// dalla schermata di backup).
  static String get backupUploadUrl => '$backendBaseUrl/upload/';
}
