import 'package:flutter/material.dart';
import 'package:spese_casa_nuovo/components/date_picker_field.dart';
import 'package:spese_casa_nuovo/dao/category_dao.dart';
import 'package:spese_casa_nuovo/dao/event_dao.dart';
import 'package:spese_casa_nuovo/extensions/custom_scheme.dart';
import 'package:spese_casa_nuovo/models/all_models.dart';
import 'package:spese_casa_nuovo/utils/format.dart';
import 'package:spese_casa_nuovo/utils/dialogs.dart';

class EventForm extends StatefulWidget {
  final Event? event;
  const EventForm({this.event, super.key});

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
      _date = widget.event!.date;
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
      return DatePickerField(
        initialValue: widget.event?.date,
        labelText: 'Data',
        onChanged: (value) => _date = value,
        autovalidateMode: autoValidateMode,
        validator: (date) => (date == null) ? 'Campo richiesto' : null,
      );
    }

    Widget buildCategory() {
      return DropdownButtonFormField<int>(
        key: ValueKey(_inSwitch),
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
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: (String? value) {
          if (value == null || value.trim().isEmpty) {
            return 'Campo richiesto';
          }
          final parsed = parseAmount(value);
          if (parsed == null) {
            return 'Importo non valido';
          }
          if (parsed <= 0) {
            return 'L\'importo deve essere maggiore di zero';
          }
          return null;
        },
        onSaved: (String? value) {
          _amount = parseAmount(value) ?? 0.0;
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
              // ENTRATA / USCITA

              if (widget.event == null)
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment<bool>(
                      value: true,
                      label: Text('Entrata'),
                      icon: Icon(Icons.add),
                    ),
                    ButtonSegment<bool>(
                      value: false,
                      label: Text('Uscita'),
                      icon: Icon(Icons.remove),
                    ),
                  ],
                  selected: {_inSwitch},
                  onSelectionChanged: (selection) {
                    setState(() {
                      _inSwitch = selection.first;
                      _outSwitch = !_inSwitch;
                      _idCategory = null;
                      getFilteredCategory();
                    });
                  },
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Annulla: chiude il popup senza salvare.
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[300],
                      side: BorderSide(color: Colors.grey.shade500),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annulla'),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 231, 216, 80),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();

                            Event newEvent = Event(
                                idHome: 0,
                                idNature:
                                    _inSwitch ? Nature.inId : Nature.outId,
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
                              const SnackBar(content: Text('Evento salvato')),
                            );
                          }
                        },
                        child: widget.event != null
                            ? const Text('Aggiorna')
                            : const Text('Applica'),
                      ),
                      if (widget.event != null) ...[
                        const SizedBox(width: 8.0),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.danger,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                          ),
                          onPressed: () async {
                            final navigator = Navigator.of(context);
                            final messenger = ScaffoldMessenger.of(context);
                            final confirmed = await showConfirmDialog(
                              context,
                              title: 'Elimina evento',
                              message:
                                  'Vuoi eliminare definitivamente questo evento?',
                            );
                            if (!confirmed) return;

                            navigator.pop();
                            EventDao().delete(widget.event!);
                            messenger.showSnackBar(
                              const SnackBar(
                                  content: Text('Evento eliminato')),
                            );
                          },
                          child: const Text('Elimina'),
                        ),
                      ],
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
