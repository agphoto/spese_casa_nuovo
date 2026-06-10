import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:spese_casa_nuovo/config/app_config.dart';
import 'package:spese_casa_nuovo/db/app_database.dart';
import 'package:spese_casa_nuovo/main.dart';
import 'package:spese_casa_nuovo/models/all_models.dart';
import 'package:get_it/get_it.dart';
import 'package:spese_casa_nuovo/services/logging_http_client.dart';

class DbBackupScreen extends StatefulWidget {
  const DbBackupScreen({super.key}) ;
  static String route = "/db_backup_screen";
  @override
  State<DbBackupScreen> createState() => _DbBackupScreenState();
}

class _DbBackupScreenState extends State<DbBackupScreen> {
  String _exportedDb = "";
  String endpoint = AppConfig.backupUploadUrl;
  final TextEditingController _controller = TextEditingController();
  bool buttonEnabled = false;
  bool _isUploading = false;

  @override
  initState() {
    super.initState();
    _controller.addListener(
      () {
        if (_controller.text.isNotEmpty) {
          setState(() {
            buttonEnabled = true;
          });
        } else {
          setState(() {
            buttonEnabled = false;
          });
        }
      },
    );
  }

  _DbBackupScreenState() {
    AppDatabase.instance.exportDb().then((value) => setState(() {
          _exportedDb = value;
        }));
  }

  void _exportDb() async {
    if (_controller.text.isEmpty) return;
    setState(() => _isUploading = true);
    String url =
        "$endpoint${GetIt.instance.get<AppSettings>().udid}/${_controller.text}";
    try {
      final response = await httpClient.post(Uri.parse(url),
          headers: {'Content-type': 'application/json'}, body: _exportedDb);
      if (!mounted) return;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Backup completato')));
        Navigator.pushReplacementNamed(context, MyHomePage.route);
      } else {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Backup fallito (codice ${response.statusCode})')));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Errore di rete: backup non riuscito')));
    }
  }

  /// Salva l'export del DB come file .json scelto dall'utente.
  void _saveLocalBackup() async {
    final messenger = ScaffoldMessenger.of(context);
    if (_exportedDb.isEmpty) {
      messenger.showSnackBar(
          const SnackBar(content: Text('Backup non ancora pronto')));
      return;
    }
    try {
      final now = DateTime.now();
      String two(int n) => n.toString().padLeft(2, '0');
      final fileName = 'quanto_spendo_'
          '${now.year}${two(now.month)}${two(now.day)}_'
          '${two(now.hour)}${two(now.minute)}.json';
      final bytes = utf8.encode(_exportedDb);

      final outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Salva backup',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: bytes,
      );
      if (outputPath == null) return; // selezione annullata

      // Su desktop file_picker restituisce solo il percorso senza scrivere:
      // scriviamo noi il file. Su mobile/web il file è già stato salvato.
      if (!kIsWeb &&
          (Platform.isLinux || Platform.isMacOS || Platform.isWindows)) {
        await File(outputPath).writeAsBytes(bytes);
      }
      if (!mounted) return;
      messenger.showSnackBar(
          SnackBar(content: Text('Backup salvato: $fileName')));
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(
          content: Text('Errore nel salvataggio del backup')));
    }
  }

  @override
  Widget build(BuildContext context) {
    int selectedNavigationItemIndex = 1;
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Quanto spendo?"),
            SizedBox(height: 8.0),
          ],
        ),
        leading: Image.asset(
          'assets/images/logo.png',
          scale: 2.0,
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(child: SingleChildScrollView(child: Text(_exportedDb))),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Enter db name',
                      ),
                      controller: _controller,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: (buttonEnabled && !_isUploading) ? _exportDb : null,
                  child: _isUploading
                      ? const SizedBox(
                          width: 16.0,
                          height: 16.0,
                          child: CircularProgressIndicator(strokeWidth: 2.0),
                        )
                      : const Text("Export"),
                ),
                const SizedBox(width: 4.0),
                Tooltip(
                  message: 'Salva backup su file',
                  child: IconButton(
                    onPressed: _exportedDb.isEmpty ? null : _saveLocalBackup,
                    icon: const Icon(Icons.save_alt),
                    color: Colors.yellow[600],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedNavigationItemIndex,
        onTap: (value) {
          selectedNavigationItemIndex = value;
          switch (value) {
            case 0:
              Navigator.pushReplacementNamed(context, MyHomePage.route);
              break;
            default:
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.house), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.cloud_upload), label: 'Backup'),
        ],
      ),
    );
  }
}
