import 'package:flutter/material.dart';
import 'package:spese_casa_nuovo/components/event_form.dart';
import 'package:spese_casa_nuovo/constants/all_constants.dart';
import 'package:spese_casa_nuovo/dao/event_dao.dart';
import 'package:spese_casa_nuovo/extensions/custom_scheme.dart';
import 'package:spese_casa_nuovo/models/all_models.dart';
import 'package:spese_casa_nuovo/utils/format.dart';
import 'package:intl/intl.dart';

class EventsList extends StatefulWidget {
  final EventFilter _filter;
  final List<Category> categories;
  const EventsList(this._filter, this.categories, { super.key});

  @override
  State<EventsList> createState() => _EventsListState();
}

class _EventsListState extends State<EventsList> {
  String _searchQuery = "";
  bool _hideTotal = true;

  Future<List<Event>> getList() => EventDao().allByHome(0, widget._filter);

  @override
  initState() {
    super.initState();
  }

  void callback() {
    setState(() {});
  }

  /// Cerca la categoria dell'evento senza lanciare eccezioni se mancante
  /// (es. categoria eliminata): in tal caso ritorna un segnaposto.
  Category categoryFor(Event item) {
    return widget.categories.firstWhere(
      (element) => element.id == item.idCategory,
      orElse: () =>
          Category(id: item.idCategory, idNature: item.idNature, label: '—'),
    );
  }

  bool matchFilter(Event item) {
    EventFilter f = widget._filter;
    bool value = false;
    if ((item.isInEvent && f.filterIn) || (item.isOutEvent && f.filterOut)) {
      if (f.filterCatagories == null ||
          (f.filterCatagories != null && f.filterCatagories!.isEmpty) ||
          (f.filterCatagories != null &&
              f.filterCatagories!.contains(item.idCategory))) {
        value = true;
      }
    }
    return value;
  }

  Widget _totalHeader(double totale) {
    final bool positive = totale >= 0;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: positive ? Colors.green : Colors.red,
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Totale', style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _hideTotal ? '••••••' : formatCurrency(totale),
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: _hideTotal
                      ? Colors.grey
                      : (positive ? Colors.green : Colors.red),
                ),
              ),
              const SizedBox(width: 8.0),
              InkWell(
                onTap: () => setState(() => _hideTotal = !_hideTotal),
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Icon(
                    _hideTotal ? Icons.visibility_off : Icons.visibility,
                    size: 20.0,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _searchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 0.0),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        style: const TextStyle(fontSize: 13.0),
        decoration: const InputDecoration(
          isDense: true,
          // Padding verticale ridotto per recuperare spazio in altezza.
          contentPadding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
          prefixIcon: Icon(Icons.search, size: 18.0),
          prefixIconConstraints: BoxConstraints(minWidth: 32.0, minHeight: 0.0),
          hintText: 'Cerca per descrizione',
          hintStyle: TextStyle(fontSize: 13.0),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _emptyState(String message) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(12.0),
        width: 240.0,
        decoration: BoxDecoration(
            color: Colors.yellow.shade700,
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: const [
              BoxShadow(
                  color: Colors.grey,
                  blurRadius: 1.0,
                  spreadRadius: 1.0,
                  offset: Offset(0.0, 0.0))
            ]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.receipt_long, color: Colors.black, size: 32.0),
            const SizedBox(height: 8.0),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _searchField(),
        Expanded(
          child: FutureBuilder<List<Event>>(
            future: getList(),
            initialData: kEventsList,
            builder: (
              context,
              AsyncSnapshot<List<Event>> snapshot,
            ) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  if (snapshot.hasData && (snapshot.data as List).isNotEmpty) {
                    final query = _searchQuery.trim().toLowerCase();
                    final List<Event> events = query.isEmpty
                        ? snapshot.data!
                        : snapshot.data!
                            .where((e) => e.text.toLowerCase().contains(query))
                            .toList();

                    double totale = 0.0;
                    for (var item in events) {
                      totale = totale +
                          (item.amount *
                              (item.idNature == Nature.inId ? 1 : -1));
                    }

                    return Column(
                      children: [
                        _totalHeader(totale),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: () async => setState(() {}),
                            child: events.isEmpty
                                ? ListView(
                                    children: [
                                      const SizedBox(height: 80),
                                      _emptyState(
                                          'Nessun risultato per "$_searchQuery".'),
                                    ],
                                  )
                                : ListView.builder(
                                    padding:
                                        const EdgeInsets.only(bottom: 150.0),
                                    itemCount: events.length,
                                    itemBuilder: (context, index) {
                                      final item = events[index];
                                      return EventItem(
                                          item, categoryFor(item), callback);
                                    },
                                  ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return _emptyState(
                        'Lista vuota!\nDefinire le categorie prima di inserire nuovi eventi.');
                  }
                default:
                  return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ],
    );
  }
}

// -----------------------------------
// EventItem
// -----------------------------------

class EventItem extends StatelessWidget {
  final Event _event;
  final Category _category;
  final Function callback;

  const EventItem(this._event, this._category, this.callback, {super.key})
      ;

  void longPress(BuildContext context) {
    showModalBottomSheet(
      context: context,
      elevation: 0,
      barrierColor: Colors.black.withAlpha(0),
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 20.0),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.yellow.shade600.withValues(alpha: 0.7),
              spreadRadius: 2,
              blurRadius: 0,
              offset: const Offset(0, 0), // changes position of shadow
            ),
          ],
          color: Colors.grey[600],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
        ),
        child: Center(
          child: EventForm(event: _event),
        ),
      ),
    ).then((value) => callback());
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () {
        longPress(context);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: Colors.grey[900],
          border: Border.all(color: Colors.yellow[600]!, width: 0.2),
          boxShadow: const [
            BoxShadow(blurRadius: 10, color: Colors.black, offset: Offset(1, 3))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              maxRadius: 20.0,
              backgroundColor:
                  (_event.idNature == 0) ? Colors.green : Colors.red,
              child: (_event.idNature == 0)
                  ? const Icon(
                      Icons.add,
                      color: Colors.white,
                    )
                  : const Icon(
                      Icons.remove,
                      color: Colors.white,
                    ),
            ),
            const SizedBox(
              width: 8.0,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('dd/MM/yyyy').format(_event.date),
                    style: Theme.of(context).textTheme.dateSmall,
                  ),
                  Text(
                    _event.text,
                    style: Theme.of(context).textTheme.boldBody,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatCurrency(_event.amount),
                  style: Theme.of(context).textTheme.amountText,
                ),
                Container(
                  padding: const EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: Colors.grey[700]),
                  child: Text(
                    _category.label,
                    style: Theme.of(context).textTheme.tagBody,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
