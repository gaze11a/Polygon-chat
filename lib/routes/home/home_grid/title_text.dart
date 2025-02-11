import 'package:flutter/material.dart';

// ignore: must_be_immutable
class TitleText extends StatelessWidget {
  TitleText(this.title);
  String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: 40,
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, 0.5),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
        ),
      ),
    );
  }
}
