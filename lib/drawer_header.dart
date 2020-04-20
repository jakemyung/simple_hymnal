import 'package:flutter/material.dart';

class DrawerHeaderWidget extends StatelessWidget {
  DrawerHeaderWidget({this.text, this.fontSize, this.color, this.fontFamily});

  final String text;
  final double fontSize;
  final Color color;
  final String fontFamily;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.lightBlue,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 0),
        child: Text(
          text,
          style: TextStyle(
              fontSize: fontSize, color: color, fontFamily: fontFamily),
        ),
      ),
    );
  }
}
