import 'package:flutter/material.dart';

class UserImage extends StatelessWidget {
  final String userimage;

  const UserImage({required this.userimage, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 7),
        shape: BoxShape.circle,
        image: DecorationImage(
          fit: BoxFit.cover,
          image: userimage.isNotEmpty
              ? NetworkImage(userimage) as ImageProvider<Object>
              : const AssetImage('assets/preimage.JPG'),
        ),
      ),
    );
  }
}
