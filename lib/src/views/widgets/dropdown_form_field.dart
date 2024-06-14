import 'package:flutter/material.dart';

class CustomDropdownFormField<T> extends StatelessWidget {
  final T? value;
  final String labelText;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? Function(T?)? validator;

  const CustomDropdownFormField({
    super.key,
    required this.value,
    required this.labelText,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      validator: validator,
      builder: (FormFieldState<T> state) {
        return InputDecorator(
          decoration: InputDecoration(
            labelText: labelText,
            errorText: state.hasError ? state.errorText : null,
          ),
          isEmpty: value == null,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isDense: true,
              onChanged: (T? newValue) {
                onChanged(newValue);
                state.didChange(newValue);
              },
              items: items,
            ),
          ),
        );
      },
    );
  }
}