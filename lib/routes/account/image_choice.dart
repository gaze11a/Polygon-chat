import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:polygon/loading_dialog.dart';

import '../../main.dart';

// **画像圧縮処理**
Future<File?> compressImage(File imageFile, int quality) async {
  final XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
    imageFile.absolute.path,
    '${imageFile.path}_compressed.jpg',
    quality: quality,
  );

  return compressedFile != null ? File(compressedFile.path) : null;
}

// **画像を選択 → 圧縮 → Firebase にアップロード**
Future<String> setImage(BuildContext context, String filename, String storagePath) async {
  try {
    loadingDialog(context);

    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      debugPrint("[DEBUG] No image selected.");
      closeLoadingDialog(navigatorKey.currentContext!);
      return "";
    }

    File imageFile = File(pickedFile.path);
    debugPrint("[DEBUG] Image picked: ${imageFile.path}");

    File? compressedFile = await compressImage(imageFile, 50);
    if (compressedFile == null) {
      debugPrint("[DEBUG] Image compression failed.");
      closeLoadingDialog(navigatorKey.currentContext!);
      return "";
    }

    Reference ref = FirebaseStorage.instance.ref().child(storagePath).child(filename);
    UploadTask uploadTask = ref.putFile(compressedFile);
    TaskSnapshot snapshot = await uploadTask;
    String imageURL = await snapshot.ref.getDownloadURL();

    debugPrint("[DEBUG] Upload successful. Image URL: $imageURL");

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(storagePath, imageURL);

    closeLoadingDialog(navigatorKey.currentContext!);
    return imageURL;
  } catch (e) {
    debugPrint("[ERROR] Firebase upload failed: $e");
    closeLoadingDialog(navigatorKey.currentContext!);
    return "";
  }
}

// **プロフィール画像選択ウィジェット**
class ProfileImageChoice extends StatefulWidget {
  final String username;
  final String userImage;

  const ProfileImageChoice(this.username, this.userImage, {super.key});

  @override
  ProfileImageChoiceState createState() => ProfileImageChoiceState();
}

class ProfileImageChoiceState extends State<ProfileImageChoice> {
  late String userImage;

  @override
  void initState() {
    super.initState();
    userImage = widget.userImage;
    getData();
  }

  Future<void> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userImage = prefs.getString('user') ?? ''; // 🔹 プロフィール画像のキー
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        String newImage = await setImage(context, "${widget.username}-image", "user");

        if (newImage.isNotEmpty) {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('user', newImage);
          setState(() {
            userImage = newImage;
          });
        }
      },
      child: Container(
        width: 130.0,
        height: 130.0,
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 7),
          shape: BoxShape.circle,
          image: DecorationImage(
            fit: BoxFit.fill,
            image: userImage.isNotEmpty
                ? NetworkImage(userImage)
                : const AssetImage('assets/preimage.JPG') as ImageProvider,
            colorFilter: ColorFilter.mode(
              Colors.black.withAlpha(100),
              BlendMode.dstATop,
            ),
          ),
        ),
      ),
    );
  }
}

// **ヘッダー画像選択ウィジェット**
class HeaderImageChoice extends StatefulWidget {
  final String username;
  final String userHeader;

  const HeaderImageChoice(this.username, this.userHeader, {super.key});

  @override
  HeaderImageChoiceState createState() => HeaderImageChoiceState();
}

class HeaderImageChoiceState extends State<HeaderImageChoice> {
  late String userHeader;

  @override
  void initState() {
    super.initState();
    userHeader = widget.userHeader;
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

    return InkWell(
      onTap: () async {
        String newHeader = await setImage(context, "${widget.username}-header", "header");

        if (newHeader.isNotEmpty) {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('header', newHeader);
          setState(() {
            userHeader = newHeader;
          });
        }
      },
      child: Container(
        height: size.height / 4,
        width: size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.fill,
            image: userHeader.isNotEmpty
                ? NetworkImage(userHeader)
                : const AssetImage('assets/preheader.jpg') as ImageProvider,
            colorFilter: ColorFilter.mode(
              Colors.grey.withValues(alpha: 0.5),
              BlendMode.dstATop,
            ),
          ),
        ),
        child: const Center(
          child: Icon(Icons.collections, color: Colors.white),
        ),
      ),
    );
  }
}
