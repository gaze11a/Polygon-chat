import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:polygon/routes/account/image_choice.dart';

class HeaderChoice extends StatefulWidget {
  final String username;
  final String userImage;

  const HeaderChoice(this.username, {super.key, required this.userImage});

  @override
  HeaderChoiceState createState() => HeaderChoiceState();
}

class HeaderChoiceState extends State<HeaderChoice> {
  String? userHeader;

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userHeader = prefs.getString('header') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Stack(
      children: <Widget>[
        Container(
          color: Colors.white,
          height: size.height / 4,
          width: size.width,
        ),
        Container(
          height: size.height / 4,
          width: size.width,
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.fill,
              image: userHeader?.isNotEmpty ?? false
                  ? NetworkImage(userHeader!)
                  : const AssetImage('assets/preheader.jpg') as ImageProvider,
              colorFilter: ColorFilter.mode(
                Colors.grey.withValues(alpha: 0.5),
                BlendMode.dstATop,
              ),
            ),
          ),
          child: const Icon(Icons.collections),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 100.0),
            child: ImageChoice(widget.username, userHeader ?? ''),
          ),
        ),
      ],
    );
  }
}
