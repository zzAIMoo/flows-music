import 'dart:async';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:finto_spoti/Screens/Login/components/background.dart';

// ignore: must_be_immutable

class BodyPage extends StatefulWidget {
  @override
  _BodyPageState createState() => _BodyPageState();
}

class _BodyPageState extends State<BodyPage> {
  @override
  void initState() {
    super.initState();
    Timer.periodic(new Duration(seconds: 1), (timer) async {
      var url = Uri.parse(
          'http://192.168.178.86/Flows_Progetto_Esame/API/registration/checkVerified.php');
      // ignore: unused_local_variable
      var response = await http.post(url, body: {});
    });
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Una mail di verifica è stata inviata al tuo account, segui le instruzioni nella mail per verificare il tuo account",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
