import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:polygon/paira/paira_model.dart';
import 'package:polygon/routes/bubble.dart';

// ignore: must_be_immutable
class Paira extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final double pairaheight = size.height * 0.57;
    final double pairawidth = pairaheight * 0.32;
    final double smallpairaheight = size.height * 0.4;
    final double smallpairawidth = smallpairaheight * 0.4;

    return ChangeNotifierProvider<PairaModel>(
        create: (_) => PairaModel(),
        child: Consumer<PairaModel>(builder: (context, model, child) {
          return Align(
            alignment: Alignment.bottomRight,
            child: GestureDetector(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                textDirection: TextDirection.rtl,
                children: [
                  model.smallPaira
                      ? Container(
                          margin: EdgeInsets.only(right: 15.0),
                          height: smallpairaheight,
                          width: smallpairawidth,
                          child: Image.asset("assets/small_paira.PNG"),
                        )
                      : Container(
                          height: pairaheight,
                          width: pairawidth,
                          child: Image.asset("assets/paira.PNG"),
                        ),
                  model.pairaText.length != 0
                      ? Padding(
                          padding: const EdgeInsets.only(top: 110),
                          child: Bubble(
                            nip: BubbleNip.rightTop,
                            color: Color.fromRGBO(136, 215, 250, 1.0),
                            child: Text(
                              model.pairaText,
                              textAlign: TextAlign.left,
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                        )
                      : SizedBox(),
                ],
              ),
              onTap: () async {
                model.pairaTalk();
              },
              onLongPress: () async {
                model.pairaChange();
              },
            ),
          );
        }));
  }
}
