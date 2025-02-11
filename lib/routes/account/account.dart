import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:polygon/model.dart';
import 'package:polygon/routes/account/header_choice.dart';
import 'package:polygon/routes/account/hobby_menu.dart';
import 'package:polygon/routes/home/user_detail/user_header.dart';
import 'package:polygon/routes/home/user_detail/user_hobby.dart';
import 'package:polygon/routes/home/user_detail/user_name.dart';
import 'package:polygon/routes/home/user_detail/user_name_comment.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Account extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AccountPage(),
    );
  }
}

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late String username;
  late String usermail;
  late String userimage;
  late String userheader;
  late String comment;
  late String hobby;
  late List hobbylist;

  bool edit = false;

  Future getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString('name') ?? '';
    usermail = prefs.getString('mail') ?? '';
    userimage = prefs.getString('image') ?? '';
    userheader = prefs.getString('header') ?? '';
    comment = prefs.getString('comment') ?? '';
    hobby = prefs.getString('hobby') ?? '';
    hobbylist = hobby.split(',');
    if (hobbylist[0] == "") hobbylist.removeAt(0);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: edit
              ? Text(
            "アカウントを編集",
            style: TextStyle(color: Colors.black),
          )
              : Text(
            "アカウント",
            style: TextStyle(
              color: Color.fromRGBO(100, 205, 250, 1.0),
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          leading: edit
              ? InkWell(
            onTap: () {
              setState(() {
                edit = false;
              });
            },
            child: Icon(
              Icons.close,
              color: Colors.blueGrey,
            ),
          )
              : SizedBox(),
          actions: [
            edit
                ? ChangeNotifierProvider<Model>(
                create: (_) => Model(),
                child: Consumer<Model>(builder: (context, model, child) {
                  return TextButton(
                    child: Text(
                      "保存",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    onPressed: () async {
                      model.startLoading();

                      getData();

                      await FirebaseFirestore.instance
                          .collection('user')
                          .doc(username)
                          .update({
                        'title': username,
                        'imageURL': userimage,
                        'headerURL': userheader,
                        'comment': comment,
                        'hobby': hobbylist,
                        'mail': usermail,
                        'createdAt': Timestamp.now(),
                      });

                      model.endLoading();

                      await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('保存完了'),
                            actions: <Widget>[
                              TextButton(
                                child: Text('OK'),
                                onPressed: () async {
                                  setState(() {
                                    edit = false;
                                    Navigator.of(context).pop();
                                  });
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                }))
                : TextButton(
              child: Text(
                "編集",
                style: TextStyle(color: Colors.black, fontSize: 15),
              ),
              onPressed: () {
                setState(() {
                  edit = true;
                });
              },
            )
          ],
        ),
        body: edit
            ? editbuilder(context)
            : FutureBuilder(
          future: getData(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return SingleChildScrollView(
                child: Stack(
                  children: [
                    Container(
                        width: size.width,
                        height: size.height,
                        child: Image.asset('assets/polygon.jpg')),
                    Column(
                      children: [
                        UserHeader(userheader: userheader, userimage: userimage),
                        comment.length != 0
                            ? UserNameComment(username, comment)
                            : UserName(username),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                          child: UserHobby(hobbylist),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Center(
                            child: Text(
                              usermail
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            } else {
              return Container(
                decoration: new BoxDecoration(color: Colors.white),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  // 編集画面
  Widget editbuilder(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final _controller = TextEditingController();
    _controller.text = comment;

    return ChangeNotifierProvider<Model>(
      create: (_) => Model(),
      child: Stack(
        children: <Widget>[
          Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: SingleChildScrollView(
                child: Stack(
                  children: [
                    Container(
                        width: size.width,
                        height: size.height,
                        child: Image.asset('assets/polygon.jpg')),
                    Column(
                      children: <Widget>[
                        HeaderChoice(username, userheader, userimage),
                        UserName(username),
                        Container(
                          margin: const EdgeInsets.all(15.0),
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          ),
                          child: TextField(
                            controller: _controller,
                            maxLength: 20,
                            style: TextStyle(
                              fontSize: 15.0,
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.only(
                                top: 5.0,
                                bottom: 5.0,
                                left: 10.0,
                                right: 5.0,
                              ),
                              hintText: "ひとことを追加(20文字まで)",
                            ),
                            onChanged: (text) async {
                              comment = text;
                              final SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                              prefs.setString('comment', comment);
                            },
                          ),
                        ),
                        UserHobby(hobbylist),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextButton(
                            child: Text('シュミを選択'),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: BorderSide(color: Colors.black, width: 1),
                            ),
                            onPressed: () {
                              Navigator.of(context)
                                  .push(
                                MaterialPageRoute(
                                  builder: (context) => HobbyMenu(username: username),
                                ),
                              )
                                  .then((value) async {
                                SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                                setState(() {
                                  hobby = prefs.getString('hobby') ?? '';
                                  hobbylist = hobby.split(',');
                                  if (hobbylist[0] == "") hobbylist.removeAt(0);
                                });
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Consumer<Model>(builder: (context, model, child) {
            return model.isLoading
                ? Container(
              color: Colors.grey.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
                : SizedBox();
          }),
        ],
      ),
    );
  }
}
