import 'package:flutter/material.dart';

//名前のみ

class UserName extends StatelessWidget {
  const UserName(this.title, {super.key});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Container(
          decoration: const BoxDecoration(
            color: Color.fromRGBO(255, 255, 255, 0.5),
          ),
          child: Column(
            children: [
              titleText(title),
            ],
          ),
        ));
  }

  Widget titleText(String title) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      height: 50,
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
