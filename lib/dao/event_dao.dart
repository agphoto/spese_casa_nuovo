import 'package:spese_casa_nuovo/db/app_database.dart';
import 'package:spese_casa_nuovo/models/all_models.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/timestamp.dart';

class EventDao {
  static const String eventStoreName = "events";

  final _eventStore = intMapStoreFactory.store(eventStoreName);

  Future<Database> get _db async => await AppDatabase.instance.database;

  Future insert(Event event) async {
    Map<String, dynamic> mapped = event.toJson();
    mapped['date'] = Timestamp.fromDateTime(event.date);
    await _eventStore.add(await _db, mapped);
  }

  Future update(Event event) async {
    // print('Update event: ${event.toString()}');
    final finder = Finder(filter: Filter.byKey(event.id));
    Map<String, dynamic> mapped = event.toJson();
    mapped['date'] = Timestamp.fromDateTime(event.date);
    await _eventStore.update(await _db, mapped, finder: finder);
  }

  Future delete(Event event) async {
    final finder = Finder(filter: Filter.byKey(event.id));
    await _eventStore.delete(
      await _db,
      finder: finder,
    );
  }

  Future<bool> checkAgainstCategoryid(int id) async {
    final eventFinder = Finder(filter: Filter.equals('idCategory', id));

    final recordSnapshots =
        await _eventStore.find(await _db, finder: eventFinder);

    return recordSnapshots.isNotEmpty;
  }

  Future<List<Event>> allByHome(int idHome, EventFilter? f) async {
    Finder finder;
    if (f != null) {
      List<Filter> l = getFilterList(f);
      l.add(Filter.equals('idHome', idHome));
      finder =
          Finder(sortOrders: [SortOrder('date', false)], filter: Filter.and(l));
    } else {
      finder = Finder(
          sortOrders: [SortOrder('date')],
          filter: Filter.equals('idHome', idHome));
    }
    final recordSnapShots = await _eventStore.find(await _db, finder: finder);

    return recordSnapShots.map((snapshot) {
      Map<String, dynamic> mapped = Map.from(snapshot.value);
      mapped['date'] = (mapped['date'] as Timestamp).toDateTime();
      final event = Event.fromJson(mapped);
      event.id = snapshot.key;
      return event;
    }).toList();
  }
}

List<Filter> getFilterList(EventFilter f) {
  List<Filter> l = [];

  if (f.filterIn && f.filterOut) {
    l.add(Filter.or([
      Filter.equals('idNature', Nature.inId),
      Filter.equals('idNature', Nature.outId)
    ]));
  } else if (f.filterIn) {
    l.add(Filter.equals('idNature', Nature.inId));
  } else if (f.filterOut) {
    l.add(Filter.equals('idNature', Nature.outId));
  }
  if (f.filterCatagories != null) {
    for (var item in f.filterCatagories!) {
      l.add(Filter.equals('idCategory', item));
    }
  }
  if (f.filterDateFrom != null) {
    Timestamp from = Timestamp.fromDateTime(f.filterDateFrom!);
    l.add(Filter.greaterThanOrEquals('date', from));
  }

  if (f.filterDateTo != null) {
    Timestamp to = Timestamp.fromDateTime(f.filterDateTo!);
    l.add(Filter.lessThanOrEquals('date', to));
  }

  return l;
}
