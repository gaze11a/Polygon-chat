import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:polygon/paira/paira_model.dart';
import 'package:polygon/routes/account/hobby_menu_next.dart';
import 'package:polygon/routes/bubble.dart';
import 'package:polygon/user_login.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class HobbyMenu extends StatelessWidget {
  HobbyMenu({Key? key, required this.username}) : super(key: key);
  String username;

  String hobby = '';
  List<String> hobbylist = [];
  bool isExplain = true;
  bool isFirstChoice = true;

  List<String> entertainment = [
    "お笑い", "スポーツ観戦", "テレビドラマ", "海外ドラマ", "韓ドラ", "邦画", "洋画", "舞台",
    "一般アニメ", "漫画", "ラノベ"
  ];
  List<String> game = [
    "PCゲーム", "スマホゲーム", "PS4", "XBOX", "Nintendo Switch", "Nintendo 2DS/3DS",
    "PSP/PS Vita", "ボードゲーム", "カードゲーム", "将棋/囲碁"
  ];
  List<String> music = ["J-POP", "K-POP", "アニメソング", "VOCALOID", "ロック", "ジャズ", "演歌"];
  List<String> instrument = [
    "弦楽器", "管楽器", "打楽器", "鍵盤楽器", "電子楽器", "和楽器/民族楽器", "作曲"
  ];
  List<String> sport = [
    "野球", "サッカー", "テニス", "バレーボール", "ラグビー", "卓球", "水泳", "ゴルフ",
    "プロレス", "相撲", "陸上", "体操"
  ];
  List<String> outdoor = [
    "登山", "サイクリング", "ツーリング", "サーフィン", "釣り", "スキー/スノーボード", "キャンプ",
    "BBQ", "旅行", "温泉巡り"
  ];
  List<String> gourmet = [
    "和食", "洋食", "中華", "ラーメン", "コンビニスイーツ", "ビール", "日本酒", "ワイン", "食べ歩き"
  ];
  List<String> lifestyle = [
    "料理", "お菓子作り", "小説", "筋トレ", "ダイエット", "ガーデニング", "DIY", "刺繍",
    "占い", "スピリチュアル", "風水"
  ];
  List<String> others = [
    "車", "電車", "ミリタリー", "イラスト", "コスプレ", "パソコン", "カメラ", "特撮", "アイドル",
    "深夜アニメ", "BL"
  ];

  Future<void> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    hobby = prefs.getString('hobby') ?? '';
    hobbylist = hobby.split(',');
    if (hobbylist[0] == "") hobbylist.removeAt(0);
    isFirstChoice = prefs.getBool('isFirstChoice') ?? true;
    isExplain = prefs.getBool('isExplain') ?? true;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final double pairaheight = size.height * 0.57;
    final double pairawidth = pairaheight * 0.32;

    return FutureBuilder(
      future: getData(),
      builder: (context, snapshot) {
        return ChangeNotifierProvider<PairaModel>(
          create: (_) => PairaModel(),
          child: Stack(
            children: [
              Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
                  backgroundColor: Colors.black,
                  title: const Text("シュミを選択"),
                  centerTitle: true,
                  automaticallyImplyLeading: false,
                  actions: [
                    Consumer<PairaModel>(builder: (context, model, child) {
                      model.isFirstChoice = isFirstChoice;
                      return TextButton(
                        child: Text(
                          model.isFirstChoice ? '保存' : '完了',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () async {
                          if (isFirstChoice) {
                            model.startLoading();

                            SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                            hobby = prefs.getString('hobby') ?? '';
                            hobbylist = hobby.split(',');
                            if (hobbylist[0] == "") hobbylist.removeAt(0);

                            await FirebaseFirestore.instance
                                .collection('user')
                                .doc(username)
                                .update({
                              'hobby': hobbylist,
                              'createdAt': Timestamp.now(),
                            });

                            prefs.setBool('isFirstChoice', false);

                            model.endLoading();

                            model.isFirstChoice = false;
                            isFirstChoice = false;

                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => UserLogin(),
                              ),
                            );
                          } else {
                            Navigator.of(context).pop();
                          }
                        },
                      );
                    })
                  ],
                ),
                body: Stack(
                  children: [
                    Column(
                      children: [
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 60.0),
                            child: ListView(children: [
                              _menuItem(
                                  "エンタメ",
                                  "テレビ、映画、漫画",
                                  Icon(
                                    Icons.live_tv,
                                    color: Colors.red,
                                  ),
                                  entertainment,
                                  context),
                              _menuItem(
                                  "ゲーム",
                                  "家庭用ゲーム、ボードゲームなど",
                                  Icon(
                                    Icons.videogame_asset,
                                    color: Colors.green,
                                  ),
                                  game,
                                  context),
                              _menuItem(
                                  "音楽",
                                  "曲のジャンル",
                                  Icon(
                                    Icons.music_note,
                                    color: Colors.lightBlue,
                                  ),
                                  music,
                                  context),
                              _menuItem(
                                  "楽器/作曲",
                                  "弦楽器、管楽器など",
                                  Icon(
                                    Icons.queue_music,
                                    color: Colors.deepPurpleAccent,
                                  ),
                                  instrument,
                                  context),
                              _menuItem(
                                  "スポーツ",
                                  "メジャーなスポーツ",
                                  Icon(
                                    Icons.directions_run,
                                    color: Colors.black,
                                  ),
                                  sport,
                                  context),
                              _menuItem(
                                  "アウトドア",
                                  "登山から温泉巡りまで",
                                  Icon(
                                    Icons.landscape,
                                    color: Colors.lightGreen,
                                  ),
                                  outdoor,
                                  context),
                              _menuItem(
                                  "グルメ",
                                  "食べ物、飲み物",
                                  Icon(
                                    Icons.restaurant,
                                    color: Colors.orange,
                                  ),
                                  gourmet,
                                  context),
                              _menuItem(
                                  "ライフスタイル",
                                  "生活の中のこだわり",
                                  Icon(
                                    Icons.favorite,
                                    color: Colors.pinkAccent,
                                  ),
                                  lifestyle,
                                  context),
                              _menuItem(
                                  "その他",
                                  "オタクな君へ",
                                  Icon(
                                    Icons.more_horiz,
                                    color: Colors.grey,
                                  ),
                                  others,
                                  context),
                            ]),
                          ),
                        ),
                      ],
                    ),
                    Consumer<PairaModel>(builder: (context, model, child) {
                      model.isExplain = isExplain;

                      return model.isExplain
                          ? Container(
                        color: Colors.grey.withOpacity(0.5),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: GestureDetector(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              textDirection: TextDirection.rtl,
                              children: [
                                Container(
                                  height: pairaheight,
                                  width: pairawidth,
                                  child: Image.asset("assets/paira.PNG"),
                                ),
                                model.explainText.length != 0
                                    ? Padding(
                                  padding:
                                  const EdgeInsets.only(top: 110),
                                  child: Bubble(
                                    nip: BubbleNip.rightTop,
                                    color: Color.fromRGBO(
                                        136, 215, 250, 1.0),
                                    child: Text(
                                      model.explainText,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ),
                                )
                                    : SizedBox(),
                              ],
                            ),
                            onTap: () async {
                              model.pairaExplain();

                              if (model.counter == 0) {
                                SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                                prefs.setBool('isExplain', false);

                                isExplain = false;
                                model.isExplain = false;
                              }
                            },
                          ),
                        ),
                      )
                          : SizedBox();
                    }),
                  ],
                ),
              ),
              Consumer<PairaModel>(builder: (context, model, child) {
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
      },
    );
  }

  Widget _menuItem(
      String title, String subtitle, Icon icon, List<String> menulist, BuildContext context) {
    return GestureDetector(
      child: Card(
        child: ListTile(
          leading: icon,
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: Icon(Icons.navigate_next),
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HobbyMenuNext(menulist, title, icon),
          ),
        );
      },
    );
  }
}
