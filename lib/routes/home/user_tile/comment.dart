import 'package:flutter/material.dart';

// ignore: must_be_immutable
class Comment extends StatelessWidget {
  Comment(this.commentText, {super.key});
  String commentText;

  @override
  Widget build(BuildContext context) {
    return Text(
      commentText,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 14,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}
