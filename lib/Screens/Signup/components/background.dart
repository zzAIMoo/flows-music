import 'package:flutter/material.dart';
//import 'dart:async';
import 'dart:math';

// ignore: must_be_immutable
class Background extends StatefulWidget {
  final Widget child;
  Background({
    Key key,
    @required this.child,
  }) : super(key: key);

  @override
  _BackgroundState createState() => _BackgroundState();
}

class _BackgroundState extends State<Background> {
  bool anim = false;

  int animFrame = 1, posneg = 1, maxFrame = 60;
  int millisecPause;
  Random rand;

  @override
  void initState() {
    super.initState();
    millisecPause = 1000 ~/ maxFrame;
    /*Timer.periodic(Duration(milliseconds: millisecPause), (timer) {
      if (animFrame == maxFrame) {
        setState(() {
          posneg = -1;
        });
      } else if (animFrame == 1) {
        setState(() {
          posneg = 1;
        });
      }
      setState(() {
        animFrame += posneg;
      });
      print(animFrame);
    });*/
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: size.height,
      width: double.infinity,
      // Here i can use size.width but use double.infinity because both work as a same
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          /*AnimatedPositioned(
            curve: Curves.easeInExpo,
            top: animFrame.toDouble(),
            left: animFrame
                .toDouble() /*animFrame == 1
                ? 10
                : animFrame == 2
                    ? 30
                    : animFrame == 3
                        ? 40
                        : animFrame == 4
                            ? 60
                            : null*/
            ,
            duration: Duration(milliseconds: 1),
            child: Image.asset("assets/images/music_note_1.jpg"),
            onEnd: () {
              setState(() {
                anim = !anim;
              });
            },
          ),*/
          Positioned(
            top: 0,
            left: 0,
            child: Image.asset(
              "assets/images/signup_top.png",
              width: size.width * 0.35,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Image.asset(
              "assets/images/main_bottom.png",
              width: size.width * 0.25,
            ),
          ),
          widget.child,
        ],
      ),
    );
  }

  double getTopBasedOnFrame(int frame) {
    return log(frame) * 60;
  }
}
