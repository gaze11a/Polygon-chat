import 'package:flutter/material.dart';

void loadingDialog(BuildContext context) {
  showDialog(
    barrierDismissible: false, // ユーザーが手動で閉じられないようにする
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    },
  );
}

void closeLoadingDialog(BuildContext context) {
  Future.delayed(Duration.zero, () {
    if (context.mounted && Navigator.of(context, rootNavigator: true).canPop()) {
      debugPrint("[DEBUG] Closing loading dialog...");
      Navigator.of(context, rootNavigator: true).pop();
    } else {
      debugPrint("[WARNING] Tried to close loading dialog but couldn't.");
    }
  });
}

