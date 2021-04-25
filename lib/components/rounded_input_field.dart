import 'package:flutter/material.dart';
import 'text_field_container.dart';

// ignore: must_be_immutable
class RoundedInputField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final ValueChanged<String> onChanged;
  Color color;
  TextInputType inputType;
  InputBorder border;
  RoundedInputField({
    this.color,
    this.border,
    Key key,
    this.hintText,
    this.icon = Icons.person,
    this.onChanged,
    this.inputType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextField(
        onChanged: onChanged,
        cursorColor: color,
        keyboardType: inputType,
        decoration: InputDecoration(
          icon: Icon(
            icon,
            color: Theme.of(context).primaryColor,
          ),
          hintText: hintText,
          border: border,
        ),
      ),
    );
  }
}
