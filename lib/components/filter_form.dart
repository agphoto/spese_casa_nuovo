import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:spese_casa_nuovo/dao/category_dao.dart';
import 'package:spese_casa_nuovo/models/all_models.dart';
import 'package:intl/intl.dart';

class FilterForm extends StatefulWidget {
  const FilterForm({Key? key}) : super(key: key);
  // bool _isSwitched = false;
  // bool _isChecked = false;
  @override
  _FilterFormState createState() => _FilterFormState();
}

class _FilterFormState extends State<FilterForm> {
  AutovalidateMode autoValidateMode = AutovalidateMode.onUserInteraction;
  int? _idCategory;
  DateTime? _dateFrom;
  DateTime? _dateTo;
  bool _inSwitch = true;
  bool _outSwitch = true;
  // bool _inChk = false;
  // bool _outChk = false;
  bool _catChk = false;
  bool _toChk = false;
  bool _fromChk = false;
  List<Category> categories = [];

  @override
  void initState() {
    super.initState();
    getCategoryList();
  }

  Future getCategoryList() async {
    List<Category> value = await CategoryDao().all(CategoryFilter());
    setState(() {
      categories = value;
    });
  }

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    //  EventFilter _filter = EventFilter();

    Widget _buildDatetime({bool isDateTo = true}) {
      final format = DateFormat("dd/MM/yyyy");
      return DateTimeField(
        format: format,
        onChanged: (value) => isDateTo ? _dateTo = value : _dateFrom = value,
        decoration: InputDecoration(
          labelText: !isDateTo ? 'Data da' : 'Data a',
          labelStyle: Theme.of(context).textTheme.bodyLarge,
        ),
        onShowPicker: (context, currentValue) async {
          final date = await showDatePicker(
              context: context,
              firstDate: DateTime(1900),
              initialDate: currentValue ?? DateTime.now(),
              lastDate: DateTime(2100));
          if (date != null) {
            final time = await showTimePicker(
              context: context,
              initialTime:
                  TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
            );
            return DateTimeField.combine(date, time);
          } else {
            return currentValue;
          }
        },
        autovalidateMode: autoValidateMode,
        validator: (date) => (date == null && (isDateTo ? _toChk : _fromChk))
            ? 'Campo richiesto'
            : null,
        onSaved: (dt) {
          if (isDateTo) setState(() => _dateTo = dt);
          if (!isDateTo) setState(() => _dateFrom = dt);
        },
      );
    }

    Widget _buildCategory() {
      return DropdownButtonFormField<int>(
        decoration: InputDecoration(
          labelText: 'Categoria',
          isDense: true,
          labelStyle: Theme.of(context).textTheme.bodyLarge,
        ),
        initialValue: _idCategory,
        items: categories
            .map((elem) => DropdownMenuItem<int>(
                  enabled: true,
                  value: elem.id,
                  child: Text(
                    elem.label,
                    style: const TextStyle(fontSize: 14.0),
                  ),
                ))
            .toList(),
        validator: (int? value) {
          return null;
          // if (value == null) {
          //   return 'Campo richiesto';
          // }
        },
        onChanged: (value) {
          setState(() {
            _idCategory = value;
          });
        },
        onSaved: (int? value) {
          _idCategory = value;
        },
      );
    }

    return Form(
      key: _formKey,
      child: Container(
        margin: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Mostra le entrate'),
                Switch(
                  value: _inSwitch,
                  onChanged: (value) {
                    setState(() {
                      _inSwitch = value;
                    });
                  },
                  activeTrackColor: Colors.lightGreenAccent,
                  activeThumbColor: Colors.green,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Mostra le uscite'),
                Switch(
                  value: _outSwitch,
                  onChanged: (value) {
                    setState(() {
                      _outSwitch = value;
                    });
                  },
                  activeTrackColor: Colors.lightGreenAccent,
                  activeThumbColor: Colors.green,
                ),
              ],
            ),
            Row(
              children: [
                Expanded(child: _buildCategory()),
                Checkbox(
                  value: _catChk,
                  onChanged: (value) {
                    setState(() {
                      _catChk = value ?? false;
                    });
                  },
                ),
              ],
            ),
            Row(
              children: [
                Expanded(child: _buildDatetime(isDateTo: false)),
                Checkbox(
                  value: _fromChk,
                  onChanged: (value) {
                    setState(() {
                      _fromChk = value ?? false;
                    });
                  },
                ),
              ],
            ),
            Row(
              children: [
                Expanded(child: _buildDatetime(isDateTo: true)),
                Checkbox(
                  value: _toChk,
                  onChanged: (value) {
                    setState(() {
                      _toChk = value ?? false;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(
              height: 20.0,
            ),
            ElevatedButton(
              onPressed: () {
                EventFilter newFilter = EventFilter();
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();

                  newFilter = EventFilter(
                      filterCatagories: (_catChk) ? [_idCategory!] : [],
                      filterIn: _inSwitch,
                      filterOut: _outSwitch,
                      filterDateFrom: _dateFrom,
                      filterDateTo: _dateTo);
                  Navigator.pop(context, newFilter);
                }
              },
              child: const Text('Applica'),
            )
          ],
        ),
      ),
    );
  }
}
