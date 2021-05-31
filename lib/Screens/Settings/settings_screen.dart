import 'package:flows/Screens/Main/main_screen.dart';
import 'package:flutter/material.dart';
import 'components/body.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(),
      appBar: AppBar(
        title: Text("settings"),
      ),
    );
  }
}
