import 'package:flutter/foundation.dart' hide Category;
import 'package:spese_casa_nuovo/dao/event_dao.dart';
import 'package:spese_casa_nuovo/db/app_database.dart';
import 'package:spese_casa_nuovo/models/all_models.dart';
import 'package:sembast/sembast.dart';

class CategoryDao {
  static const String categoryStoreName = "categories";

  final _categoryStore = intMapStoreFactory.store(categoryStoreName);

  Future<Database> get _db async => await AppDatabase.instance.database;

  Future insert(Category category) async {
    await _categoryStore.add(await _db, category.toJson());
    AppDatabase.instance.exportDb().then((value) => debugPrint(value));
    return;
  }

  Future update(Category category) async {
    final finder = Finder(filter: Filter.byKey(category.id));
    await _categoryStore.update(await _db, category.toJson(), finder: finder);

    AppDatabase.instance.exportDb().then((value) => debugPrint(value));
    return;
  }

  Future<int> delete(Category category) async {
    int count = -1;

    final bool check = await EventDao().checkAgainstCategoryid(category.id!);

    if (!check) {
      final finder = Finder(filter: Filter.byKey(category.id));
      count = await _categoryStore.delete(
        await _db,
        finder: finder,
      );
      debugPrint('Deleted category: $count');
    } else {
      debugPrint('Category in use!');
    }
    return count;
  }

  Future<List<Category>> all(CategoryFilter filter) async {
    late Filter f;
    if (filter.filterBoth) {
      f = Filter.or([
        Filter.equals('idNature', Nature.inId),
        Filter.equals('idNature', Nature.outId)
      ]);
    }
    if (filter.filterIn) {
      f = Filter.equals('idNature', Nature.inId);
    }
    if (filter.filterOut) {
      f = Filter.equals('idNature', Nature.outId);
    }

    final finder = Finder(sortOrders: [SortOrder('id')], filter: f);

    final recordSnapshots =
        await _categoryStore.find(await _db, finder: finder);

    List<Category> l = recordSnapshots.map((snapshot) {
      final category = Category.fromJson(snapshot.value);
      category.id = snapshot.key;
      return category;
    }).toList();

    return l;
  }
}
