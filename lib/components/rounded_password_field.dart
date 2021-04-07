import 'package:flutter/material.dart';
import 'text_field_container.dart';

// ignore: must_be_immutable
class RoundedPasswordField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final Function press;
  final bool hidden;
  InputBorder border;
  RoundedPasswordField({
    Key key,
    this.onChanged,
    this.press,
    this.hidden,
    this.border,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    bool selected = false;
    return TextFieldContainer(
        child: Theme(
            data: ThemeData(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent),
            child: TextField(
              enableInteractiveSelection: false,
              enableSuggestions: false,
              autocorrect: false,
              obscureText: hidden,
              onChanged: onChanged,
              cursorColor: Color(0xFF6F35A5),
              decoration: InputDecoration(
                hintText: "Password (min 9 char)",
                icon: Icon(
                  Icons.lock,
                  color: Color(0xFF6F35A5),
                ),
                suffixIcon: IconButton(
                  icon: Icon(hidden ? Icons.visibility_off : Icons.visibility),
                  onPressed: press,
                  color: Color(0xFF6F35A5),
                ),
                border: border,
              ),
            )));
  }
}
