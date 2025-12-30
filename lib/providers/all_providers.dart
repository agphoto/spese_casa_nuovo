import 'package:flutter/cupertino.dart';
import 'package:spese_casa_nuovo/models/all_models.dart';

class CategoryProvider with ChangeNotifier {
  Category? _category;

  set category(Category? c) {
    _category = c;
    notifyListeners();
  }

  Category? get category => _category;

  toNull() {
    _category = null;
    notifyListeners();
  }
}
