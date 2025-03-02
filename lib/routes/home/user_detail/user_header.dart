import 'package:flutter/material.dart';
import 'package:polygon/routes/home/user_detail/user_image.dart';

class UserHeader extends StatelessWidget {
  final String userHeader;
  final String userImage;

  const UserHeader({required this.userHeader, required this.userImage, super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Image(
          image: userHeader.isNotEmpty
              ? NetworkImage(userHeader) as ImageProvider<Object>
              : const AssetImage('assets/preheader.jpg'),
          height: size.height / 4,
          width: size.width,
          fit: BoxFit.cover,
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 100.0),
            child: UserImage(userImage: userImage),
          ),
        ),
      ],
    );
  }
}
