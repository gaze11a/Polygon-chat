import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:polygon/loading_dialog.dart';

import '../../main.dart';

class ImageChoice extends StatefulWidget {
  final String username;
  final String userImage;

  const ImageChoice(this.username, this.userImage, {super.key});

  @override
  ImageChoiceState createState() => ImageChoiceState();
}

class ImageChoiceState extends State<ImageChoice> {
  late String userImage;

  @override
  void initState() {
    super.initState();
    userImage = widget.userImage;
    getData(); // `SharedPreferences` から画像を取得
  }

  Future<void> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        userImage = prefs.getString('image') ?? ''; // 画像があれば使う
      });
    }
  }

  /// **画像圧縮処理**
  Future<File?> _compressImage(File imageFile, int quality) async {
    final XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
      imageFile.absolute.path,
      '${imageFile.path}_compressed.jpg',
      quality: quality,
    );

    return compressedFile != null ? File(compressedFile.path) : null;
  }

  /// **画像を選択 → 圧縮 → Firebase にアップロード**
  Future<void> _handleImageSelection() async {
    try {
      loadingDialog(context);

      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile == null) {
        debugPrint("[DEBUG] No image selected.");
        closeLoadingDialog(navigatorKey.currentContext!);
        return;
      }

      File imageFile = File(pickedFile.path);
      debugPrint("[DEBUG] Image picked: ${imageFile.path}");

      File? compressedFile = await _compressImage(imageFile, 50);
      if (compressedFile == null) {
        debugPrint("[DEBUG] Image compression failed.");
        closeLoadingDialog(navigatorKey.currentContext!);
        return;
      }

      Reference ref = FirebaseStorage.instance.ref().child('user').child("${widget.username}-image");
      UploadTask uploadTask = ref.putFile(compressedFile);
      TaskSnapshot snapshot = await uploadTask;
      String imageURL = await snapshot.ref.getDownloadURL();

      debugPrint("[DEBUG] Upload successful. Image URL: $imageURL");

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('image', imageURL);

      if (mounted) {
        setState(() {
          userImage = imageURL; // UI 更新
        });
      }

      closeLoadingDialog(navigatorKey.currentContext!);
    } catch (e) {
      debugPrint("[ERROR] Firebase upload failed: $e");
      closeLoadingDialog(navigatorKey.currentContext!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _handleImageSelection, // 🔥 画像選択→圧縮→アップロードを実行
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
