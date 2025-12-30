import 'package:flutter/material.dart';
import 'package:spese_casa_nuovo/components/event_form.dart';
import 'package:spese_casa_nuovo/constants/all_constants.dart';
import 'package:spese_casa_nuovo/dao/event_dao.dart';
import 'package:spese_casa_nuovo/extensions/custom_scheme.dart';
import 'package:spese_casa_nuovo/models/all_models.dart';
import 'package:intl/intl.dart';

class EventsList extends StatefulWidget {
  final EventFilter _filter;
  final List<Category> categories;
  const EventsList(this._filter, this.categories, { super.key});

  @override
  _EventsListState createState() => _EventsListState();
}

class _EventsListState extends State<EventsList> {
  Future<List<Event>> getList() => EventDao().allByHome(0, widget._filter);

  @override
  initState() {
    super.initState();
  }

  void callback() {
    setState(() {});
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Event>>(
      future: getList(),
      initialData: kEventsList,
      builder: (
        context,
        AsyncSnapshot<List<Event>> snapshot,
      ) {
        // double totale = 0.0;
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            if (snapshot.hasData && (snapshot.data as List).isNotEmpty) {
              List<Event> events = snapshot.data!;
              double totale = 0.0;
              for (var item in events) {
                totale = totale +
                    (item.amount * (item.idNature == Nature.IN ? 1 : -1));
              }
              return ListView.builder(
                itemCount: events.length + 1,
                itemBuilder: (context, index) {
                  if (index > events.length - 1) {
                    return Column(
                      children: [
                        Container(
                            margin: const EdgeInsets.only(top: 16.0),
                            child: Text('Totale: $totale €')),
                        const SizedBox(
                          height: 150,
                        ),
                      ],
                    );
                  } else {
                    final item = events[index];
                    // totale = totale +   (item.amount * (item.idNature == Nature.IN ? 1 : -1));
                    Category c = widget.categories
                        .firstWhere((element) => element.id == item.idCategory);
                    return EventItem(item, c, callback);
                  }
                },
              );
            } else {
              return Center(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  height: 150.0,
                  width: 220.0,
                  decoration: BoxDecoration(
                      color: Colors.yellow.shade700,
                      border: Border.all(
                        color: Colors.yellow.shade700,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.grey,
                            blurRadius: 1.0,
                            spreadRadius: 1.0,
                            offset: Offset(0.0, 0.0))
                      ]),
                  child: Center(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Lista vuota!',
                        style: TextStyle(color: Colors.black),
                      ),
                      Text(
                          'Definire le categorie prima di inserire nuovi eventi.',
                          style: TextStyle(color: Colors.grey.shade900)),
                    ],
                  )),
                ),
              );
            }
          default:
            return const Center(child: CircularProgressIndicator());
        }
      },
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

  void longPress(BuildContext context, List<Category> categories) {
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
          child: EventForm(categories: categories, event: _event),
        ),
      ),
    ).then((value) => callback());
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () {
        longPress(context, [_category]);
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
                  '€ ${_event.amount}',
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
