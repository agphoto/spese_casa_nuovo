import 'package:flutter/material.dart';
import 'package:spese_casa_nuovo/db/app_database.dart';
import 'package:spese_casa_nuovo/main.dart';
import 'package:spese_casa_nuovo/models/all_models.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

class DbBackupScreen extends StatefulWidget {
  const DbBackupScreen({super.key}) ;
  static String route = "/db_backup_screen";
  @override
  State<DbBackupScreen> createState() => _DbBackupScreenState();
}

class _DbBackupScreenState extends State<DbBackupScreen> {
  String _exportedDb = "";
  String endpoint = "http://api.alessiogiuliano.it/quantospendo/upload/";
  final TextEditingController _controller = TextEditingController();
  bool buttonEnabled = false;

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
    String url = "$endpoint${GetIt.instance.get<AppSettings>().udid}/${_controller.text}";
    await http.post(Uri.parse(url),
        headers: {'Content-type': 'application/json'}, body: _exportedDb);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('DB exported')));
    Navigator.pushReplacementNamed(context, MyHomePage.route);
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
                  onPressed: buttonEnabled ? _exportDb : null,
                  child: const Text("Export"),
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
