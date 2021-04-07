import 'package:flutter/material.dart';
import 'package:loading_animations/loading_animations.dart';

// ignore: must_be_immutable
class RoundedButton extends StatelessWidget {
  final String text;
  final Function press;
  final Color color, textColor;
  bool isLoading;
  RoundedButton({
    Key key,
    this.text,
    this.press,
    this.color = const Color(0xFF6F35A5),
    this.textColor = Colors.white,
    this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      width: size.width * 0.8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(29),
        child: TextButton(
          style: flatButtonStyle,
          onPressed: press,
          child: !isLoading
              ? Text(
                  text,
                  style: TextStyle(color: textColor),
                )
              : LoadingRotating.square(
                  size: 10.0,
                  borderColor: Colors.white,
                  backgroundColor: Color(0xFF6F35A5),
                ),
        ),
      ),
    );
  }

  final ButtonStyle flatButtonStyle = TextButton.styleFrom(
    backgroundColor: Color(0xFF6F35A5),
    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(2.0)),
    ),
  );
}
