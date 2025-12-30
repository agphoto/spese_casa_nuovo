import 'dart:async';
import 'dart:convert';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast/utils/sembast_import_export.dart';

class AppDatabase {
  // Singleton instance
  static final AppDatabase _singleton = AppDatabase._();

  // Singleton accessor
  static AppDatabase get instance => _singleton;

  // Completer is used for transforming synchronous code into asynchronous code.
  Completer<Database>? _dbOpenCompleter;

  // A private constructor. Allows us to create instances of AppDatabase
  // only from within the AppDatabase class itself.
  AppDatabase._();

  // Sembast database object
  Database? _database;

  // Database object accessor
  Future<Database> get database async {
    // If completer is null, AppDatabaseClass is newly instantiated, so database is not yet opened
    if (_dbOpenCompleter == null) {
      _dbOpenCompleter = Completer();
      // Calling _openDatabase will also complete the completer with database instance
      _openDatabase();
    }
    // If the database is already opened, awaiting the future will happen instantly.
    // Otherwise, awaiting the returned future will take some time - until complete() is called
    // on the Completer in _openDatabase() below.
    return _dbOpenCompleter!.future;
  }

  Future _openDatabase() async {
    // Get a platform-specific directory where persistent app data can be stored
    final appDocumentDir = await getApplicationDocumentsDirectory();
    // Path with the form: /platform-specific-directory/demo.db
    final dbPath = join(appDocumentDir.path, 'quanto_spendo.db');

    final database = await databaseFactoryIo.openDatabase(dbPath);
    // Any code awaiting the Completer's future will now start executing
    _dbOpenCompleter?.complete(database);
  }

  Future<void> deleteDb() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    final dbPath = join(appDocumentDir.path, 'quanto_spendo.db');
    await databaseFactoryIo.deleteDatabase(dbPath);
    _dbOpenCompleter = null;
    return;
  }

  Future<String> exportDb() async {
    var db = await database;
    var map = await exportDatabase(db);
    return const JsonEncoder.withIndent('  ').convert(map);
  }

  Future<bool> importDb(String jsonString) async {
    Map<String, dynamic> map = json.decode(jsonString);
    final appDocumentDir = await getApplicationDocumentsDirectory();
    final dbPath = join(appDocumentDir.path, 'quanto_spendo.db');

    await importDatabase(map, databaseFactoryIo, dbPath);
    if (_database != null) await _database!.close();
    _dbOpenCompleter = null;

    return true;
  }
}
