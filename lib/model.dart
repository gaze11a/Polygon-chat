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

  Future<String> setImage(String filename) async {
    try {
      startLoading();
      print("[DEBUG] setImage() called for filename: $filename");

      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile == null) {
        print("[DEBUG] No image selected.");
        endLoading();
        return ""; // 空文字を返す（AssetImage を使う）
      }

      File imageFile = File(pickedFile.path);
      print("[DEBUG] Image picked: ${imageFile.path}");

      File? compressedFile = await compressImage(imageFile, 50);
      if (compressedFile == null) {
        print("[DEBUG] Image compression failed.");
        endLoading();
        return ""; // 空文字を返す（AssetImage を使う）
      }

      Reference ref = FirebaseStorage.instance.ref().child('user').child(filename);
      UploadTask uploadTask = ref.putFile(compressedFile);
      TaskSnapshot snapshot = await uploadTask;
      String imageURL = await snapshot.ref.getDownloadURL();

      print("[DEBUG] Upload successful. Image URL: $imageURL");
      endLoading();
      return imageURL; // 成功時はURLを返す
    } catch (e) {
      print("[ERROR] Firebase upload failed: $e");
      endLoading();
      return ""; // エラー時も AssetImage を使う
    }
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
