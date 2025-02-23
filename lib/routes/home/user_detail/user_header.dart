import 'package:flutter/material.dart';
import 'package:polygon/routes/home/user_detail/user_image.dart';

class UserHeader extends StatelessWidget {
  final String userheader;
  final String userimage;

  const UserHeader({required this.userheader, required this.userimage, super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Image(
          image: userheader.isNotEmpty
              ? NetworkImage(userheader) as ImageProvider<Object>
              : const AssetImage('assets/preheader.jpg'),
          height: size.height / 4,
          width: size.width,
          fit: BoxFit.cover,
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 100.0),
            child: UserImage(userimage: userimage),
          ),
        ),
      ],
    );
  }
}
