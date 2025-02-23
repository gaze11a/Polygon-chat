import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:polygon/model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageChoice extends StatefulWidget {
  final String username;
  final String userImage;

  const ImageChoice(this.username, this.userImage, {super.key});

  @override
  ImageChoiceState createState() => ImageChoiceState();
}

class ImageChoiceState extends State<ImageChoice> {
  late String userImage;

  @override
  void initState() {
    super.initState();
    userImage = widget.userImage;
    getData(); // Load image from SharedPreferences on widget load
  }

  Future<void> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        userImage = prefs.getString('image') ?? ''; // Update user image if found in preferences
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Model>(builder: (context, model, child) {
      return InkWell(
        onTap: () async {
          String newImage = await model.setImage(context, "${widget.username}-image");

          if (newImage.isNotEmpty) {
            final SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('image', newImage);

            if (mounted) {
              setState(() {
                userImage = newImage; // Update user image
              });
            }
          }
        },
        child: Container(
          width: 130.0,
          height: 130.0,
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 7),
            shape: BoxShape.circle,
            image: DecorationImage(
              fit: BoxFit.fill,
              image: userImage.isNotEmpty
                  ? NetworkImage(userImage)
                  : const AssetImage('assets/preimage.JPG') as ImageProvider,
              colorFilter: ColorFilter.mode(
                Colors.grey.withValues(alpha: 0.5),
                BlendMode.dstATop,
              ),
            ),
          ),
        ),
      );
    });
  }
}
