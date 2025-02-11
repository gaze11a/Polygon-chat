import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class HobbyMenuNext extends StatelessWidget {
  HobbyMenuNext(this.menulist, this.title, this.icon);
  String title;
  Icon icon;
  List menulist;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HobbyMenuNextPage(menulist, title, icon),
    );
  }
}

// ignore: must_be_immutable
class HobbyMenuNextPage extends StatefulWidget {
  HobbyMenuNextPage(this.menulist, this.title, this.icon);
  String title;
  Icon icon;
  List menulist;

  @override
  _HobbyMenuNextPageState createState() =>
      _HobbyMenuNextPageState(menulist, title, icon);
}

class _HobbyMenuNextPageState extends State<HobbyMenuNextPage> {
  _HobbyMenuNextPageState(this.menulist, this.title, this.icon);
  String title;
  Icon icon;
  List menulist;

  String hobby = '';
  List hobbylist = [];
  bool choice = false;

  Future getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    hobby = prefs.getString('hobby') ?? '';
    hobbylist = hobby.split(',');
    if (hobbylist[0] == "") hobbylist.removeAt(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(title),
        //centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            child: Text(
              '全てリセット',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              final SharedPreferences prefs =
                  await SharedPreferences.getInstance();
              prefs.remove('hobby');
              prefs.setString('hobby', "");
              setState(() {
                choice = false;
              });
            },
          )
        ],
      ),
      body: FutureBuilder(
          future: getData(),
          builder: (context, snapshot) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 60.0),
              child: ListView(children: [
                for (var index in menulist)
                  _menuItem(index, icon, context, hobbylist),
              ]),
            );
          }),
    );
  }

  Widget _menuItem(String title, Icon icon, BuildContext context, List hobby) {
    choice = hobby.contains(title);
    return GestureDetector(
        child: Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
                color:
                    choice ? Color.fromRGBO(203, 248, 255, 0.5) : Colors.white,
                border:
                    Border(bottom: BorderSide(width: 1.0, color: Colors.grey))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: [
                    Container(
                      margin: EdgeInsets.all(10.0),
                      child: icon,
                    ),
                    Text(
                      title,
                      style: TextStyle(color: Colors.black, fontSize: 18.0),
                    ),
                  ],
                ),
                if (choice)
                  Icon(
                    Icons.check,
                    color: Colors.green,
                  )
              ],
            )),
        onTap: () async {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          if (hobby.contains(title)) {
            hobby.remove(title);
            prefs.remove('hobby');
            prefs.setString('hobby', hobby.join(','));
            setState(() {
              choice = hobby.contains(title);
            });
          } else {
            if (hobby.length < 5) {
              hobby.add(title);
              prefs.remove('hobby');
              prefs.setString('hobby', hobby.join(','));
              setState(() {
                choice = hobby.contains(title);
              });
            } else {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    //backgroundColor: Colors.grey,
                    title: Text(
                      'シュミは5つ以上登録できません',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: Text('OK'),
                        onPressed: () async {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            }
          }
        });
  }
}

/*
              Scaffold.of(context).showSnackBar(new SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.grey,
                content: new Container(
                  child: Text(
                    'シュミは5つ以上登録できません',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                duration: Duration(seconds: 2),
              ));*/
