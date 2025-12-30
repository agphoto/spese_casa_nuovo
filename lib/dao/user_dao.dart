import 'package:spese_casa_nuovo/db/app_database.dart';
import 'package:spese_casa_nuovo/models/all_models.dart';
import 'package:sembast/sembast.dart';

class UserDao {
  static const String USER_STORE_NAME = "users";

  final _userStore = intMapStoreFactory.store(USER_STORE_NAME);

  Future<Database> get _db async => await AppDatabase.instance.database;

  Future<int> insert(User user) async {
    int id = await _userStore.add(await _db, user.toJson());
    return id;
  }

  Future update(User user) async {
    // print('Update user: ${user.toString()}');
    final finder = Finder(filter: Filter.byKey(user.id));
    await _userStore.update(await _db, user.toJson(), finder: finder);
  }

  Future delete(User user) async {
    final finder = Finder(filter: Filter.byKey(user.id));
    await _userStore.delete(
      await _db,
      finder: finder,
    );
  }

  Future<User?> userById(int idUser) async {
    final finder = Finder(filter: Filter.byKey(idUser));
    final recordSnapshots = await _userStore.find(await _db, finder: finder);
    if (recordSnapshots.isNotEmpty) {
      final user = User.fromJson(recordSnapshots.first.value);
      user.id = recordSnapshots.first.key;
      return user;
    } else {
      return null;
    }
  }

  Future<List<User>> allCarByUser(int idUser) async {
    final finder = Finder(
        sortOrders: [SortOrder('id')], filter: Filter.equals('idUser', idUser));

    final recordSnapshots = await _userStore.find(await _db, finder: finder);

    List<User> l = recordSnapshots.map((snapshot) {
      final user = User.fromJson(snapshot.value);
      user.id = snapshot.key;
      return user;
    }).toList();

    return l;
  }
}
