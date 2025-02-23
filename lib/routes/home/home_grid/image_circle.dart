import 'package:flutter/material.dart';

class ImageCircle extends StatelessWidget {
  final String userimage; // ✅ Make it final

  // ✅ Pass Key and initialize correctly
  ImageCircle(this.userimage, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 7),
        shape: BoxShape.circle,
        image: DecorationImage(
          fit: BoxFit.fill,
          image: userimage.isNotEmpty
              ? NetworkImage(userimage) as ImageProvider<Object> // ✅ Fix type issue
              : const AssetImage('assets/preimage.JPG') as ImageProvider<Object>,
        ),
      ),
    );
  }
}
