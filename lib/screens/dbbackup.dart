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
  _DbBackupScreenState createState() => _DbBackupScreenState();
}

class _DbBackupScreenState extends State<DbBackupScreen> {
  String _exportedDb = "";
  String ENDPOINT = "http://api.alessiogiuliano.it/quantospendo/upload/";
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

  // String ENDPOINT = "http://192.168.1.43/upload/";

  //String ENDPOINT = "http://www.quantospendo.local/upload/";

  _DbBackupScreenState() {
    AppDatabase.instance.exportDb().then((value) => setState(() {
          _exportedDb = value;
        }));
  }

  void _exportDb() async {
    if (_controller.text.isEmpty) return;
    // User? user = await UserDao().userById(1);
    String url = "$ENDPOINT${GetIt.instance.get<AppSettings>().udid}/${_controller.text}";
    http
        .post(Uri.parse(url /* "http://192.168.1.43/site/upload" */),
            headers: {'Content-type': 'application/json'}, body: _exportedDb)
        .then((value) => {
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('DB exported'))),
              Navigator.pushReplacementNamed(context, MyHomePage.route)
            });
  }

  @override
  Widget build(BuildContext context) {
    int _selectedNavigationItemIndex = 1;
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
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
        // child: Text(
        //   'Statistic Screen',
        //   style: TextStyle(color: Colors.white),
        // ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedNavigationItemIndex,
        onTap: (value) {
          _selectedNavigationItemIndex = value;
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
