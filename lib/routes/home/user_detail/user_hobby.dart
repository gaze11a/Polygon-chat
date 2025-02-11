import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class UserHobby extends StatelessWidget {
  UserHobby(this.hobbylist);
  List hobbylist;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
      child: Wrap(
        children: <Widget>[for (var item in hobbylist) itemText(item)],
      ),
    );
  }

  Widget itemText(String item) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        height: 45,
        decoration: BoxDecoration(
          color: Colors.white, //趣味のテーマカラーが入る
          border: Border.all(color: Colors.black, width: 1.5),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            Flexible(
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  item,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    //fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
