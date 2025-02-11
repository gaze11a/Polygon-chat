import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

class Model extends ChangeNotifier {
  String userName = '';
  String userMail = '';
  String userImage = '';
  String userHeader = '';
  String userPassword = '';
  String infoText = '';
  bool isLoading = false;

  startLoading() {
    isLoading = true;
    notifyListeners();
  }

  endLoading() {
    isLoading = false;
    notifyListeners();
  }

  Future<File?> compressImage(File imageFile, int quality) async {
    final XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
      imageFile.absolute.path,
      '${imageFile.path}_compressed.jpg',
      quality: quality,
    );

    return compressedFile != null ? File(compressedFile.path) : null;
  }

  setImage(String filename) async {
    String imageURL;

    startLoading();
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      endLoading();
      return null;
    }

    File imageFile = File(pickedFile.path);
    var decodedImage = await decodeImageFromList(imageFile.readAsBytesSync());
    var quality;
    if (decodedImage.width >= 4320 && decodedImage.height >= 7680) {
      quality = 2;
    } else if (decodedImage.width >= 2160 && decodedImage.height >= 3840) {
      quality = 10;
    } else if (decodedImage.width >= 1080 && decodedImage.height >= 1920) {
      quality = 25;
    } else {
      quality = 100;
    }

    File? compressedFile = await compressImage(imageFile, quality);
    if (compressedFile == null) {
      endLoading();
      return null;
    }

    Reference ref = FirebaseStorage.instance.ref().child('user').child(filename);
    UploadTask uploadTask = ref.putFile(compressedFile);
    TaskSnapshot snapshot = await uploadTask;
    imageURL = await snapshot.ref.getDownloadURL();

    endLoading();
    return imageURL;
  }

  Future<dynamic> dialog(BuildContext context, title) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  checkform(BuildContext context) {
    if (userName.isEmpty) {
      endLoading();
      dialog(context, 'ユーザー名を入力してください');
    } else if (userMail.isEmpty) {
      endLoading();
      dialog(context, 'メールアドレスを入力してください');
    } else if (userPassword.isEmpty) {
      endLoading();
      dialog(context, 'パスワードを入力してください');
    }
  }

  Widget textForm(BuildContext context, String title, String hinttext) {
    Size size = MediaQuery.of(context).size;

    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 12.0, right: 5.0),
          child: Text(title, style: const TextStyle(fontSize: 15)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: size.width * 0.6,
            height: 50,
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black),
                borderRadius: const BorderRadius.all(Radius.circular(8.0))),
            child: TextField(
              maxLength: (title == 'ユーザー名') ? 8 : null,
              obscureText: (title == 'パスワード') ? true : false,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.only(
                      top: 5.0, bottom: 5.0, left: 10.0, right: 5.0),
                  hintText: hinttext),
              onChanged: (text) {
                switch (title) {
                  case 'ユーザー名':
                    userName = text;
                    break;
                  case 'Eメール':
                    userMail = text;
                    break;
                  case 'パスワード':
                    userPassword = text;
                    break;
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
