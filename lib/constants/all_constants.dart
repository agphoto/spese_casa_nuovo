import 'package:spese_casa_nuovo/models/all_models.dart';

const String version = "5.1";
const String description = "Creation of new DB";

final List<Nature> kNaturesList = [
  Nature(id: 0, label: 'IN'),
  Nature(id: 1, label: 'OUT'),
];

final List<Category> kCategoriesList = [
  Category(id: 0, idNature: 1, label: 'affitto'),
  Category(id: 1, idNature: 1, label: 'bollette'),
  Category(id: 2, idNature: 1, label: 'spesa'),
  Category(id: 3, idNature: 1, label: 'manutenzione'),
  Category(id: 4, idNature: 0, label: 'stipendio'),
  Category(id: 5, idNature: 0, label: 'altro'),
];

final List<Event> kEventsList = [
  Event(
      id: 0,
      amount: 120.0,
      date: DateTime.now(),
      text: 'luce',
      idCategory: 1,
      idNature: 1,
      idHome: 0),
  Event(
      id: 1,
      amount: 200.0,
      date: DateTime.now(),
      text: 'gas',
      idCategory: 1,
      idNature: 1,
      idHome: 0),
  Event(
      id: 2,
      amount: 30.0,
      date: DateTime.now(),
      text: 'telecom',
      idCategory: 1,
      idNature: 1,
      idHome: 0),
  Event(
      id: 3,
      amount: 1000.0,
      date: DateTime.now(),
      text: 'stipendio',
      idCategory: 4,
      idNature: 0,
      idHome: 0),
  Event(
      id: 4,
      amount: 100.0,
      date: DateTime.now(),
      text: 'fotografia',
      idCategory: 5,
      idNature: 0,
      idHome: 0),
  Event(
      id: 5,
      amount: 50.0,
      date: DateTime.now(),
      text: 'pulizie',
      idCategory: 5,
      idNature: 0,
      idHome: 0),
  Event(
      id: 6,
      amount: 50.0,
      date: DateTime.now(),
      text: 'pulizie',
      idCategory: 5,
      idNature: 0,
      idHome: 0),
];
