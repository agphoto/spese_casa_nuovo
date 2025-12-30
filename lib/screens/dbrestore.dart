import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:spese_casa_nuovo/db/app_database.dart';
import 'package:spese_casa_nuovo/main.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import '../models/all_models.dart';

class DbRestoreScreen extends StatefulWidget {
  const DbRestoreScreen({super.key}) ;
  static String route = "/_db_restore_screen";
  @override
  State<DbRestoreScreen> createState() => _DbRestoreScreenState();
}

class _DbRestoreScreenState extends State<DbRestoreScreen> {
  // String _selectedDb = "";
  List<String> _dbList = [];
  String ENDPOINT = "http://api.alessiogiuliano.it/quantospendo";
  String _loadedDb = "";
  bool _isDisabled = true;
  String _importButtonText = "Import";
  String _currentUdid = "";
  // final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    _currentUdid = GetIt.instance.get<AppSettings>().udid;
    _backuplist();
    super.initState();
  }

  _DbRestoreScreenState();

  void _importDb(String filename) async {
    http.get(
      Uri.parse("$ENDPOINT/load/$filename/$_currentUdid"),
      headers: {'Content-type': 'application/json'},
    ).then((value) {
      _loadedDb = value.body;

      setState(() {
        _isDisabled = false;
        _importButtonText = "Import $filename";
      });
    });
  }

  void _backuplist() async {
    http.get(Uri.parse("$ENDPOINT/backuplist/$_currentUdid"),
        headers: {'Content-type': 'application/json'}).then(
      (value) {
        Iterable l = json.decode(value.body);
        setState(() {
          _dbList = List<String>.from(l);
        });

        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('DB list reloaded')));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int _selectedNavigationItemIndex = 1;
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
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromARGB(255, 189, 201, 18),
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text('Your Udid : $_currentUdid '),
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
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _dbList.length,
                itemBuilder: (context, index) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      //<-- SEE HERE
                      side: const BorderSide(
                        color: Color.fromARGB(255, 231, 216, 80),
                      ),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: ListTile(
                        title: Text(_dbList[index]),
                        onTap: () {
                          print(_dbList[index]);
                          _importDb(_dbList[index]);
                        }),
                  );
                },
              ),
            ),
            ElevatedButton(
                onPressed: _isDisabled
                    ? null
                    : () {
                        AppDatabase.instance.importDb(_loadedDb).then((value) =>
                            {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('DB imported'))),
                              Navigator.pushReplacementNamed(
                                  context, MyHomePage.route)
                            });
                      },
                child: Text(_importButtonText))
          ],
        ),
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
              icon: Icon(Icons.cloud_download), label: 'Restore'),
        ],
      ),
    );
  }
}
