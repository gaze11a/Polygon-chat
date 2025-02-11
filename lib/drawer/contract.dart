import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ContractPage extends StatefulWidget {
  @override
  ContractPageState createState() => new ContractPageState();
}

class ContractPageState extends State<ContractPage> {
  String _out = '';
  bool agree = false;

  Future<String> loadAsset(BuildContext context) async {
    return await DefaultAssetBundle.of(context)
        .loadString('assets/contract.txt');
  }

  @override
  Widget build(BuildContext context) {
    loadAsset(context).then((value) {
      setState(() {
        _out = value;
      });
    });

    var size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('利用規約'),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(68, 114, 196, 1.0),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(children: [
        Container(
          margin: EdgeInsets.all(10),
          height: size.height / 1.3,
          child: SingleChildScrollView(
            child: Text(_out),
          ),
          decoration: BoxDecoration(
            border: Border.all(color: Color.fromRGBO(68, 114, 196, 1.0), width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ]),
    );
  }
}
