import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Campo data/ora basato sui picker nativi di Flutter
/// (`showDatePicker` + `showTimePicker`), in sostituzione del pacchetto
/// discontinuato `datetime_picker_formfield`.
///
/// È un campo di sola lettura: il tap apre i picker e il valore selezionato
/// viene notificato tramite [onChanged]. Supporta validazione tramite
/// [validator] (riceve il [DateTime] corrente).
class DatePickerField extends StatefulWidget {
  final DateTime? initialValue;
  final String labelText;
  final ValueChanged<DateTime?> onChanged;
  final String? Function(DateTime?)? validator;
  final AutovalidateMode? autovalidateMode;

  const DatePickerField({
    super.key,
    this.initialValue,
    required this.labelText,
    required this.onChanged,
    this.validator,
    this.autovalidateMode,
  });

  @override
  State<DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  final DateFormat _format = DateFormat('dd/MM/yyyy');
  late final TextEditingController _controller;
  DateTime? _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
    _controller = TextEditingController(
        text: _value != null ? _format.format(_value!) : '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      initialDate: _value ?? DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_value ?? DateTime.now()),
    );

    final picked = DateTime(
      date.year,
      date.month,
      date.day,
      time?.hour ?? 0,
      time?.minute ?? 0,
    );

    setState(() {
      _value = picked;
      _controller.text = _format.format(picked);
    });
    widget.onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      readOnly: true,
      onTap: _pick,
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: Theme.of(context).textTheme.bodyLarge,
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      autovalidateMode: widget.autovalidateMode,
      validator: (_) => widget.validator?.call(_value),
    );
  }
}
