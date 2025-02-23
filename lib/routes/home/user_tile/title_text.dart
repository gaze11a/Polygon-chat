import 'package:flutter/material.dart';

// ignore: must_be_immutable
class TitleText extends StatelessWidget {
  TitleText(this.title, {super.key});
  String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: 40,
      decoration: const BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, 0.5),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 18,
        ),
      ),
    );
  }
}
