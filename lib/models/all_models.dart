 // --------------------
// User
// --------------------


class User {
  int? id;
  final String name;
  final String surname;
  final String login;
  final String passwd;
  final String uuid;

  User(
      {this.id,
      required this.name,
      required this.surname,
      required this.login,
      required this.passwd,
      required this.uuid});

  static User fromJson(Map<String, dynamic> json) {
    return User(
        id: json['id'],
        name: json['name'],
        surname: json['surname'],
        login: json['login'],
        passwd: json['passwd'],
        uuid: json['uuid']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['surname'] = surname;
    data['login'] = login;
    data['passwd'] = passwd;
    data['uuid'] = uuid;
    return data;
  }
}

// --------------------
// Housing
// --------------------

class Home {
  int? id;
  final int idUser;
  final String address;
  final String city;
  final String zipcode;

  Home(
      {this.id,
      required this.idUser,
      required this.address,
      required this.city,
      required this.zipcode});

  static Home fromJson(Map<String, dynamic> json) {
    return Home(
      id: json['id'],
      idUser: json['idUser'],
      address: json['address'],
      city: json['city'],
      zipcode: json['zipcode'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['idUser'] = idUser;
    data['address'] = address;
    data['city'] = city;
    data['zipcode'] = zipcode;
    return data;
  }
}

// --------------------
// Event
// --------------------

class Event {
  int? id;
  final int idHome;
  int idNature;
  final int idCategory;
  final DateTime date;
  final String text;
  final double amount;

  Event(
      {this.id,
      required this.idHome,
      required this.idNature,
      required this.idCategory,
      required this.date,
      required this.text,
      required this.amount});

  bool get isInEvent => idNature == 0;
  bool get isOutEvent => idNature == 1;

  static Event fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      idHome: json['idHome'],
      idNature: json['idNature'],
      idCategory: json['idCategory'],
      date: json['date'],
      text: json['text'],
      amount: json['amount'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['idHome'] = idHome;
    data['idNature'] = idNature;
    data['idCategory'] = idCategory;
    data['date'] = date;
    data['text'] = text;
    data['amount'] = amount;
    return data;
  }
}

// --------------------
// Nature
// --------------------

class Nature {
  int? id;
  final String label;

  Nature({this.id, required this.label});

  static Nature fromJson(Map<String, dynamic> json) {
    return Nature(
      id: json['id'],
      label: json['label'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['label'] = label;
    return data;
  }

  static int IN = 0;
  static int OUT = 1;
}
// --------------------
// Category
// --------------------

class Category {
  int? id;
  int idNature;
  String label;

  Category({this.id, required this.idNature, required this.label});

  static Category fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      idNature: json['idNature'],
      label: json['label'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['idNature'] = idNature;
    data['label'] = label;
    return data;
  }
}

// --------------------
// Filter
// --------------------

class EventFilter {
  bool filterIn;
  bool filterOut;
  List<int>? filterCatagories;
  DateTime? filterDateFrom;
  DateTime? filterDateTo;

  EventFilter(
      {this.filterIn = true,
      this.filterOut = true,
      this.filterCatagories,
      this.filterDateFrom,
      this.filterDateTo});
}

class CategoryFilter {
  bool filterIn;
  bool filterOut;
  bool filterBoth;

  CategoryFilter({
    this.filterIn = false,
    this.filterOut = false,
    this.filterBoth = true,
  });
}

// ---------------------------------
//  GetIt
// ---------------------------------

class AppSettings {
  String udid;
  AppSettings({this.udid = ""});
}
