import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:polygon/model.dart';
import 'package:polygon/routes/account/image_choice.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class HeaderChoice extends StatelessWidget {
  String username;
  String? userHeader; // Make userHeader nullable
  String userImage;

  HeaderChoice(this.username,
      {super.key, this.userHeader, required this.userImage});

  Future<void> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userHeader = prefs.getString('header'); // userHeader can be null now
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Consumer<Model>(builder: (context, model, child) {
      return InkWell(
        onTap: () async {
          // Fetch image from the model
          userHeader = await model.setImage(context, "$username-header");

          // If the image is null or empty, fetch the default one
          if (userHeader == null || userHeader!.isEmpty) {
            await getData();
          }

          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('header',
              userHeader ?? ''); // Save header image to SharedPreferences
        },
        child: FutureBuilder(
            future: getData(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              return Stack(
                children: <Widget>[
                  Container(
                    color: Colors.white,
                    height: size.height / 4,
                    width: size.width,
                  ),
                  // Apply the header image with ColorFilter.mode
                  Container(
                    height: size.height / 4,
                    width: size.width,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.fill,
                        image: userHeader?.isNotEmpty ?? false
                            ? NetworkImage(userHeader!)
                            : const AssetImage('assets/preheader.jpg')
                                as ImageProvider,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withValues(),
                          // Updated with `withValues()`
                          BlendMode.dstATop,
                        ),
                      ),
                    ),
                    child: const Icon(Icons.collections),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 100.0),
                      child: ImageChoice(username, userImage),
                    ),
                  ),
                ],
              );
            }),
      );
    });
  }
}
