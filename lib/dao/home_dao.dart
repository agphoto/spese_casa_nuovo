import 'package:spese_casa_nuovo/db/app_database.dart';
import 'package:spese_casa_nuovo/models/all_models.dart';
import 'package:sembast/sembast.dart';

class HomeDao {
  static const String HOME_STORE_NAME = "housing";

  final _carStore = intMapStoreFactory.store(HOME_STORE_NAME);

  Future<Database> get _db async => await AppDatabase.instance.database;

  Future insert(Home home) async {
    await _carStore.add(await _db, home.toJson());
  }

  Future update(Home home) async {
    // print('Update home: ${home.toString()}');
    final finder = Finder(filter: Filter.byKey(home.id));
    await _carStore.update(await _db, home.toJson(), finder: finder);
  }

  Future delete(Home home) async {
    final finder = Finder(filter: Filter.byKey(home.id));
    await _carStore.delete(
      await _db,
      finder: finder,
    );
  }

  Future<List<Home>> allByUser(int idUser) async {
    final finder = Finder(
        sortOrders: [SortOrder('id')], filter: Filter.equals('idUser', idUser));

    final recordSnapshots = await _carStore.find(await _db, finder: finder);

    List<Home> l = recordSnapshots.map((snapshot) {
      final home = Home.fromJson(snapshot.value);
      home.id = snapshot.key;
      return home;
    }).toList();

    return l;
  }
}
