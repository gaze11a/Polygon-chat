import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      return imageURL;
    } catch (e) {
      print("[ERROR] Firebase upload failed: $e");
      endLoading();
      return "";
    }
  }

  Future<void> deleteAccount(BuildContext context, String password) async {
    print("[DEBUG] deleteAccount() called!");

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("[ERROR] No user signed in.");
        dialog(context, "ユーザーが見つかりません。");
        return;
      }

      String uid = user.uid;
      String email = user.email ?? "";
      print("[DEBUG] User ID: $uid");
      print("[DEBUG] User Email: $email");

      // 🔹 受け取ったパスワードで認証
      try {
        AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
        await user.reauthenticateWithCredential(credential);
        print("[DEBUG] User reauthenticated successfully.");
      } catch (e) {
        print("[ERROR] Reauthentication failed: $e");
        dialog(context, "パスワードが間違っています。再入力してください。");
        return;
      }

      // 🔹 Firestore の `user` コレクションからデータを削除
      try {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('user')
            .where('mail', isEqualTo: email)
            .get();

        for (var doc in snapshot.docs) {
          await FirebaseFirestore.instance.collection('user').doc(doc.id).delete();
          print("[DEBUG] Deleted Firestore user document: ${doc.id}");
        }
      } catch (e) {
        print("[ERROR] Failed to delete Firestore user document: $e");
      }

      // 🔹 Firebase Storage の画像削除
      try {
        await FirebaseStorage.instance.ref().child("user/$uid").delete();
        await FirebaseStorage.instance.ref().child("headers/$uid").delete();
        print("[DEBUG] Storage images deleted");
      } catch (e) {
        print("[WARNING] Storage images not found: $e");
      }

      // 🔹 Firebase Authentication のアカウント削除
      try {
        await user.delete();
        print("[DEBUG] Firebase Auth user deleted");
      } catch (e) {
        print("[ERROR] Firebase Auth user delete failed: $e");
        dialog(context, "アカウント削除に失敗しました。もう一度お試しください。");
        return;
      }

      // 🔹 Firestore のキャッシュをクリア
      await FirebaseFirestore.instance.clearPersistence();
      print("[DEBUG] Firestore cache cleared");

      // 🔹 SharedPreferences をクリア
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print("[DEBUG] SharedPreferences cleared");

      // 🔹 削除完了ダイアログを表示
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("アカウント削除完了"),
            content: Text("アカウントを削除しました。ログアウトします。"),
            actions: <Widget>[
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );

      // 🔹 1秒待機して Firestore の削除を確実に適用
      await Future.delayed(Duration(seconds: 1));

      // 🔹 確実にログアウト
      await FirebaseAuth.instance.signOut();
      print("[DEBUG] User signed out");

    } catch (e) {
      print("[ERROR] Failed to delete account: $e");
      dialog(context, "アカウント削除に失敗しました。もう一度お試しください。");
    }
  }



  // 🔹 パスワード入力用のダイアログ
  Future<String?> showPasswordDialog(BuildContext context) async {
    String password = "";
    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("パスワードを入力"),
          content: TextField(
            obscureText: true,
            decoration: InputDecoration(hintText: "パスワード"),
            onChanged: (value) {
              password = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text("キャンセル"),
              onPressed: () => Navigator.of(context).pop(null),
            ),
            TextButton(
              child: Text("OK"),
              onPressed: () => Navigator.of(context).pop(password),
            ),
          ],
        );
      },
    );
  }

  // 🔹 汎用的なダイアログ表示メソッド
  Future<bool> dialog(BuildContext context, String message) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("確認"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("キャンセル"),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text("OK", style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    ) ?? false;
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
