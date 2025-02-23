import 'package:flutter/material.dart';
import 'package:polygon/routes/home/home_grid/comment.dart';
import 'package:polygon/routes/home/home_grid/image_circle.dart';
import 'package:polygon/routes/home/home_grid/title_text.dart';

// ignore: must_be_immutable
class HomeTile extends StatelessWidget {
  final String title;
  final String imageURL;
  final String commentText;

  const HomeTile(this.title, this.imageURL, this.commentText, {super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
              color: Colors.white,
              image: const DecorationImage(
                image: AssetImage('assets/polygon.jpg'),
                fit: BoxFit.fill,
              ),
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black26,
                    spreadRadius: 1.0,
                    blurRadius: 10.0,
                    offset: Offset(7, 7)),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: TitleText(title),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: ImageCircle(imageURL),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Comment(commentText),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget shortText(String item) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        height: 30,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(0, 0, 0, 0.1),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                item,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget longText(String item, BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemWidth = size.width / 5.5;

    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        height: 30,
        width: itemWidth,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(0, 0, 0, 0.1),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  item,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
