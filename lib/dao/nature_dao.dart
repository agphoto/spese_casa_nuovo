import 'package:spese_casa_nuovo/db/app_database.dart';
import 'package:spese_casa_nuovo/models/all_models.dart';
import 'package:sembast/sembast.dart';

class NatureDao {
  static const String natureStoreName = "natures";

  final _carStore = intMapStoreFactory.store(natureStoreName);

  Future<Database> get _db async => await AppDatabase.instance.database;

  Future insert(Nature nature) async {
    await _carStore.add(await _db, nature.toJson());
  }

  Future update(Nature nature) async {
    // print('Update nature: ${nature.toString()}');
    final finder = Finder(filter: Filter.byKey(nature.id));
    await _carStore.update(await _db, nature.toJson(), finder: finder);
  }

  Future delete(Nature nature) async {
    final finder = Finder(filter: Filter.byKey(nature.id));
    await _carStore.delete(
      await _db,
      finder: finder,
    );
  }

  Future<List<Nature>> allByUser(int idUser) async {
    final finder = Finder(
        sortOrders: [SortOrder('id')], filter: Filter.equals('idUser', idUser));

    final recordSnapshots = await _carStore.find(await _db, finder: finder);

    List<Nature> l = recordSnapshots.map((snapshot) {
      final nature = Nature.fromJson(snapshot.value);
      nature.id = snapshot.key;
      return nature;
    }).toList();

    return l;
  }
}
