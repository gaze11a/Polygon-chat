import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:polygon/model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageChoice extends StatefulWidget {
  final String username;
  final String userimage;

  ImageChoice(this.username, this.userimage);

  @override
  _ImageChoiceState createState() => _ImageChoiceState();
}

class _ImageChoiceState extends State<ImageChoice> {
  late String userimage;

  @override
  void initState() {
    super.initState();
    userimage = widget.userimage;
    getData(); // Load image from SharedPreferences on widget load
  }

  Future<void> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        userimage = prefs.getString('image') ?? ''; // Update user image if found in preferences
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Model>(builder: (context, model, child) {
      return InkWell(
        onTap: () async {
          String newImage = await model.setImage(widget.username + 'image');

          if (newImage.isNotEmpty) {
            final SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('image', newImage);

            if (mounted) {
              setState(() {
                userimage = newImage; // Update user image
              });
            }
          }
        },
        child: Container(
          width: 130.0,
          height: 130.0,
          margin: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 7),
            shape: BoxShape.circle,
            image: DecorationImage(
              fit: BoxFit.fill,
              image: userimage.isNotEmpty
                  ? NetworkImage(userimage)
                  : AssetImage('assets/preimage.JPG') as ImageProvider,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.6), // `withValues()` → `withOpacity()`
                BlendMode.dstATop,
              ),
            ),
          ),
        ),
      );
    });
  }
}
