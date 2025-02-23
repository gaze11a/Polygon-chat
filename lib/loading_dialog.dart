import 'package:flutter/material.dart';

void loadingDialog(BuildContext context) {
  showDialog(
    barrierDismissible: false,
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
  if (Navigator.of(context, rootNavigator: true).canPop()) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}

