import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:spese_casa_nuovo/config/app_config.dart';
import 'package:spese_casa_nuovo/db/app_database.dart';
import 'package:spese_casa_nuovo/main.dart';
import 'package:get_it/get_it.dart';
import 'package:spese_casa_nuovo/services/logging_http_client.dart';
import 'package:spese_casa_nuovo/utils/dialogs.dart';
import '../models/all_models.dart';

class DbRestoreScreen extends StatefulWidget {
  const DbRestoreScreen({super.key}) ;
  static String route = "/_db_restore_screen";
  @override
  State<DbRestoreScreen> createState() => _DbRestoreScreenState();
}

class _DbRestoreScreenState extends State<DbRestoreScreen> {
  List<String> _dbList = [];
  String endpoint = AppConfig.backendBaseUrl;
  String _loadedDb = "";
  bool _isDisabled = true;
  bool _isLoadingList = false;
  String _importButtonText = "Import";
  String _currentUdid = "";
  final TextEditingController _udidController = TextEditingController();

  @override
  void initState() {
    _currentUdid = GetIt.instance.get<AppSettings>().udid;
    _udidController.text = _currentUdid;
    _backuplist();
    super.initState();
  }

  @override
  void dispose() {
    _udidController.dispose();
    super.dispose();
  }

  _DbRestoreScreenState();

  void _importDb(String filename) async {
    try {
      final value = await httpClient.get(
        Uri.parse("$endpoint/load/$filename/$_currentUdid"),
        headers: {'Content-type': 'application/json'},
      );
      if (!mounted) return;
      if (value.statusCode >= 200 && value.statusCode < 300) {
        _loadedDb = value.body;
        setState(() {
          _isDisabled = false;
          _importButtonText = "Importa $filename";
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text('Download fallito (codice ${value.statusCode})')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Errore di rete: backup non scaricato')));
    }
  }

  /// Carica un file .json da memoria locale e lo prepara per l'import,
  /// come se fosse stato selezionato dalla lista remota.
  void _loadLocalJson() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );
      if (result == null) return; // selezione annullata

      final file = result.files.single;
      final bytes = file.bytes;
      if (bytes == null) {
        messenger.showSnackBar(const SnackBar(
            content: Text('Impossibile leggere il file selezionato')));
        return;
      }

      final content = utf8.decode(bytes);
      // Validazione minima: deve essere JSON valido prima di abilitare l'import.
      json.decode(content);

      if (!mounted) return;
      setState(() {
        _loadedDb = content;
        _isDisabled = false;
        _importButtonText = 'Importa ${file.name}';
      });
      messenger.showSnackBar(
          SnackBar(content: Text('File caricato: ${file.name}')));
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(
          content: Text('File non valido: non è un JSON corretto')));
    }
  }

  void _backuplist() async {
    setState(() => _isLoadingList = true);
    try {
      final response = await httpClient.get(
          Uri.parse("$endpoint/backuplist/$_currentUdid"),
          headers: {'Content-type': 'application/json'});
      if (!mounted) return;
      if (response.statusCode < 200 || response.statusCode >= 300) {
        setState(() => _isLoadingList = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Impossibile caricare la lista (codice ${response.statusCode})')));
        return;
      }
      final Iterable l = json.decode(response.body);
      setState(() {
        _dbList = List<String>.from(l);
        _isLoadingList = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Lista backup aggiornata')));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingList = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Errore di rete: lista non caricata')));
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
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: TextField(
                      controller: _udidController,
                      onChanged: (value) => _currentUdid = value.trim(),
                      decoration: InputDecoration(
                        labelText: 'Udid',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 8.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 189, 201, 18),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 189, 201, 18),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 5.0,
                ),
                Tooltip(
                  message: "Reload",
                  child: Ink(
                    width: 30.0,
                    height: 30.0,
                    decoration: const ShapeDecoration(
                      color: Color.fromARGB(255, 231, 216, 80),
                      shape: CircleBorder(),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      splashRadius: 20,
                      icon: const Icon(Icons.refresh),
                      color: const Color.fromARGB(255, 61, 61, 61),
                      onPressed: () {
                        _backuplist();
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 5.0),
                Tooltip(
                  message: "Carica JSON da locale",
                  child: Ink(
                    width: 30.0,
                    height: 30.0,
                    decoration: const ShapeDecoration(
                      color: Color.fromARGB(255, 231, 216, 80),
                      shape: CircleBorder(),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      splashRadius: 20,
                      icon: const Icon(Icons.folder_open),
                      color: const Color.fromARGB(255, 61, 61, 61),
                      onPressed: () {
                        _loadLocalJson();
                      },
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: _isLoadingList
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                itemCount: _dbList.length,
                itemBuilder: (context, index) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        color: Color.fromARGB(255, 231, 216, 80),
                      ),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: ListTile(
                        title: Text(_dbList[index]),
                        onTap: () {
                          _importDb(_dbList[index]);
                        }),
                  );
                },
              ),
            ),
            ElevatedButton(
                onPressed: _isDisabled
                    ? null
                    : () async {
                        final navigator = Navigator.of(context);
                        final messenger = ScaffoldMessenger.of(context);
                        final confirmed = await showConfirmDialog(
                          context,
                          title: 'Importa database',
                          message:
                              'I dati attuali verranno sovrascritti con questo backup. Continuare?',
                          confirmLabel: 'Importa',
                        );
                        if (!confirmed) return;

                        await AppDatabase.instance.importDb(_loadedDb);
                        messenger.showSnackBar(
                            const SnackBar(content: Text('DB importato')));
                        navigator.pushReplacementNamed(MyHomePage.route);
                      },
                child: Text(_importButtonText))
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
              icon: Icon(Icons.cloud_download), label: 'Restore'),
        ],
      ),
    );
  }
}
