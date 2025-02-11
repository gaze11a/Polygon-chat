import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:polygon/model.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Change to StatefulWidget since you have asynchronous logic and state updates
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
    setState(() {
      userimage = prefs.getString('image') ?? ''; // Update user image if found in preferences
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Model>(builder: (context, model, child) {
      return InkWell(
        onTap: () async {
          // Get user-specific image
          userimage = await model.setImage(widget.username + 'image');

          // If no image is found, try getting the default data
          if (userimage.isEmpty) getData();

          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('image', userimage); // Store image in SharedPreferences
          setState(() {}); // Trigger rebuild to reflect the new image
        },
        child: Container(
          child: Icon(Icons.collections),
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
                Colors.black.withValues(), // Updated line with `withValues()`
                BlendMode.dstATop,
              ),
            ),
          ),
        ),
      );
    });
  }
}
