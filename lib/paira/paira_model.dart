import 'package:flutter/foundation.dart';
import 'dart:math' as math;

class PairaModel extends ChangeNotifier {
  String pairaText = '';
  String explainText = 'はじめまして。\nポリゴンチャットへ\nようこそ。\n\n(タップして次へ) 1/5';
  bool smallPaira = true;
  bool isExplain = true;
  bool isFirstChoice = true;
  var random = math.Random();
  var counter = 0;

  bool isLoading = false;

  // Function to handle explanation text
  pairaExplain() {
    switch (counter) {
      case 0:
        explainText = '私はパイラ。\nここのガイドを\nしています。\n\n(タップして次へ) 2/5';
        break;
      case 1:
        explainText = 'ポリゴンチャットでは、\nシュミが同じ人どうしで\nツナガルことができます。\n\n(タップして次へ) 3/5';
        break;
      case 2:
        explainText = 'あなたの好きなことを\n登録してみましょう。\n\n(タップして次へ) 4/5';
        break;
      case 3:
        explainText = 'シュミは最大で\n５つまで選択できます。\n\n 5/5';
        break;
      case 4:
        counter = 0;
        break;
    }
    counter++;
    notifyListeners();
  }

  // Function to handle paira talking logic
  pairaTalk() async {
    if (pairaText.isEmpty) {
      switch (counter) {
        case 0:
          pairaText = ['おつかれですか？', '今日もいい一日になると\nいいですね。', 'いつも頑張ってますね。'][random.nextInt(3)];
          break;
        case 1:
          pairaText = '今日はどうでしたか？何か特別なことがあったりしますか？';
          break;
        case 2:
          pairaText = 'もっとリラックスしたいですか？それとも、何かチャレンジしたいですか？';
          break;
        case 3:
          pairaText = 'もしも、今できることで一番楽しいことがあったら、それは何ですか？';
          break;
      }
      counter++;
      notifyListeners();
    } else {
      pairaText = '';
      notifyListeners();
    }
  }

  // Toggle between small and large Paira
  pairaChange() {
    smallPaira = !smallPaira;
    notifyListeners();
  }

  // Start loading animation
  startLoading() {
    isLoading = true;
    notifyListeners();
  }

  // End loading animation
  endLoading() {
    isLoading = false;
    notifyListeners();
  }
}
