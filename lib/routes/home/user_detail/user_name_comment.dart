import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//名前とひとこと

class UserNameComment extends StatelessWidget {
  UserNameComment(this.title, this.comment);
  final String title;
  final String comment;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Container(
          decoration: BoxDecoration(
            color: Color.fromRGBO(255, 255, 255, 0.5),
          ),
          child: Column(
            children: [
              titleText(title),
              commentText(comment),
            ],
          ),
        ));
  }

  Widget titleText(String title) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: 8.0),
      height: 45,
      child: Text(
        title,
        style: TextStyle(
          color: Colors.black,
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget commentText(String comment) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(bottom: 7.0),
      height: 35,
      child: Text(
        comment,
        style: TextStyle(
          color: Colors.black,
          fontSize: 16,
        ),
      ),
    );
  }
}
