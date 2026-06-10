import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

/// Client HTTP che logga in modo centralizzato tutte le chiamate REST verso
/// il backend: metodo, URL, status code, durata ed eventuali errori.
///
/// Estendendo [http.BaseClient] ogni richiesta passa da [send], quindi
/// qualunque chiamata (get/post/...) effettuata tramite questo client viene
/// loggata automaticamente, anche quelle aggiunte in futuro.
///
/// I log sono emessi con `dart:developer` sotto il nome 'REST', visibili in
/// console e in DevTools (sezione Logging).
class LoggingHttpClient extends http.BaseClient {
  final http.Client _inner;

  LoggingHttpClient([http.Client? inner]) : _inner = inner ?? http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final stopwatch = Stopwatch()..start();
    developer.log('→ ${request.method} ${request.url}', name: 'REST');
    try {
      final response = await _inner.send(request);
      stopwatch.stop();
      developer.log(
        '← ${response.statusCode} ${request.method} ${request.url} '
        '(${stopwatch.elapsedMilliseconds} ms)',
        name: 'REST',
      );
      return response;
    } catch (e, stack) {
      stopwatch.stop();
      developer.log(
        '✗ ${request.method} ${request.url} '
        'fallita dopo ${stopwatch.elapsedMilliseconds} ms',
        name: 'REST',
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}

/// Istanza condivisa da usare per tutte le chiamate al backend.
final LoggingHttpClient httpClient = LoggingHttpClient();
