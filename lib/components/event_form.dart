import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:spese_casa_nuovo/dao/category_dao.dart';
import 'package:spese_casa_nuovo/dao/event_dao.dart';
import 'package:spese_casa_nuovo/extensions/custom_scheme.dart';
import 'package:spese_casa_nuovo/models/all_models.dart';
import 'package:intl/intl.dart';

class EventForm extends StatefulWidget {
  final List<Category> categories;
  final Event? event;
  const EventForm({required this.categories, this.event, super.key});

  @override
  State<EventForm> createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  AutovalidateMode autoValidateMode = AutovalidateMode.onUserInteraction;
  int? _idCategory;
  DateTime? _date;
  bool _inSwitch = true;
  bool _outSwitch = false;
  String _text = "";
  double _amount = 0.0;
  List<Category> categories = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    //TODO: implement initState
    super.initState();
    if (widget.event != null) {
      _inSwitch = widget.event!.isInEvent;
      _outSwitch = !_inSwitch;
    }
    getFilteredCategory();
  }

  void getFilteredCategory() async {
    CategoryFilter filter = CategoryFilter(
        filterBoth: _inSwitch && _outSwitch,
        filterIn: _inSwitch,
        filterOut: _outSwitch);

    CategoryDao().all(filter).then((value) {
      categories = value;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget buildDatetime() {
      final format = DateFormat("dd/MM/yyyy");
      return DateTimeField(
        format: format,
        initialValue: widget.event?.date,
        onChanged: (value) => _date = value,
        decoration: InputDecoration(
          labelText: 'Data',
          labelStyle: Theme.of(context).textTheme.bodyLarge,
        ),
        onShowPicker: (context, currentValue) async {
          final date = await showDatePicker(
              context: context,
              firstDate: DateTime(1900),
              initialDate: currentValue ?? DateTime.now(),
              lastDate: DateTime(2100));
          if (date != null) {
            if (!context.mounted) return currentValue;
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
        validator: (date) => (date == null) ? 'Campo richiesto' : null,
        onSaved: (dt) {
          setState(() => _date = dt);
        },
      );
    }

    Widget buildCategory() {
      return DropdownButtonFormField<int>(
        decoration: InputDecoration(
          labelText: 'Categoria',
          isDense: true,
          labelStyle: Theme.of(context).textTheme.dropDownLabelForm,
        ),
        // value: l.isNotEmpty ? l.first.id : null,
        initialValue: widget.event?.idCategory,
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
          if (value == null) {
            return 'Campo richiesto';
          }
          return null;
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

    Widget buildText() {
      return TextFormField(
        style: Theme.of(context).textTheme.bodyLarge,
        initialValue: widget.event?.text,
        decoration: const InputDecoration(labelText: 'Testo', isDense: true),
        maxLength: 50,
        validator: (String? value) {
          if (value != null && value.isEmpty) {
            return 'Campo richiesto';
          }
          return null;
        },
        onSaved: (String? value) {
          _text = value!;
        },
      );
    }

    Widget buildAmount() {
      return TextFormField(
        initialValue: widget.event?.amount.toString(),
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: const InputDecoration(labelText: 'Euro', isDense: true),
        maxLength: 50,
        keyboardType: TextInputType.number,
        validator: (String? value) {
          if (value != null && value.isEmpty) {
            return 'Campo richiesto';
          }

          return null;
        },
        onSaved: (String? value) {
          _amount = double.tryParse(value ?? "0.0")!;
        },
      );
    }

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: AnimatedPadding(
          padding: MediaQuery.of(context).viewInsets,
          duration: const Duration(milliseconds: 100),
          curve: Curves.decelerate,
          child: Column(
            children: [
              // ENTRATA

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: (widget.event == null)
                    ? [
                        const Text('Entrata'),
                        Switch(
                          value: widget.event?.isInEvent ?? _inSwitch,
                          onChanged: (value) {
                            setState(() {
                              if (widget.event != null) {
                                widget.event!.idNature =
                                    value ? Nature.inId : Nature.outId;
                              }
                              _inSwitch = value;
                              _outSwitch = !value;
                              getFilteredCategory();
                            });
                          },
                          activeTrackColor: Colors.lightGreenAccent,
                          activeThumbColor: Colors.green,
                        ),
                        const Text('Uscita'),
                        Switch(
                          value: widget.event?.isOutEvent ?? _outSwitch,
                          onChanged: (value) {
                            setState(() {
                              if (widget.event != null) {
                                widget.event!.idNature =
                                    value ? Nature.outId : Nature.inId;
                              }
                              _outSwitch = value;
                              _inSwitch = !value;
                              getFilteredCategory();
                            });
                          },
                          activeTrackColor: Colors.lightGreenAccent,
                          activeThumbColor: Colors.green,
                        ),
                      ]
                    : [],
              ),

              Row(
                children: [
                  Expanded(child: buildCategory()),
                ],
              ),
              // DATA
              Row(
                children: [
                  Expanded(child: buildDatetime()),
                ],
              ),
              Row(
                children: [
                  Expanded(child: buildText()),
                ],
              ),
              Row(
                children: [
                  Expanded(child: buildAmount()),
                ],
              ),
              const SizedBox(
                height: 10.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();

                        Event newEvent = Event(
                            idHome: 0,
                            idNature: _inSwitch ? Nature.inId : Nature.outId,
                            idCategory: _idCategory!,
                            date: _date!,
                            text: _text,
                            amount: _amount);

                        Navigator.pop(context);

                        // DAO
                        if (widget.event != null) {
                          newEvent.id = widget.event!.id;
                          EventDao().update(newEvent);
                        } else {
                          EventDao().insert(newEvent);
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Processing Data ok')),
                        );
                      }
                    },
                    child: widget.event != null
                        ? const Text('Aggiorna')
                        : const Text('Applica'),
                  ),
                  if (widget.event != null) ...[
                    const SizedBox(
                      width: 16.0,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);

                          // DAO
                          EventDao().delete(widget.event!);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Processing Data ok')),
                          );
                        },
                        child: const Text('Cancella'))
                  ]
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
