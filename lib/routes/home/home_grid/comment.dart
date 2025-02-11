import 'package:flutter/material.dart';

// ignore: must_be_immutable
class Comment extends StatelessWidget {
  Comment(this.commentText);
  String commentText;

  @override
  Widget build(BuildContext context) {
    return Container(
      //alignment: Alignment.center,
      child: Text(
        commentText,
        style: TextStyle(
          color: Colors.black,
          fontSize: 14,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
