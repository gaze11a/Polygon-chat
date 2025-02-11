# 📌 Polygon Chat

A chat application built with Flutter 🚀

## 📂 Project Structure

```
├── lib/
│   ├── lib/
│   ├──     create_profile.dart
│   ├──     main.dart
│   ├──     model.dart
│   ├──     polygon_drawer.dart
│   ├──     reset_password.dart
│   ├──     root.dart
│   ├──     user_login.dart
│   │   ├── drawer/
│   │   ├──     contact.dart
│   │   ├──     contract.dart
│   │   ├──     privacy.dart
│   │   ├──     setting.dart
│   │   ├── first_launch/
│   │   ├──     first_view.dart
│   │   ├── fonts/
│   │   ├──     NotoSerifJP-Black.otf
│   │   ├──     NotoSerifJP-Bold.otf
│   │   ├──     NotoSerifJP-ExtraLight.otf
│   │   ├──     NotoSerifJP-Light.otf
│   │   ├──     NotoSerifJP-Medium.otf
│   │   ├──     NotoSerifJP-Regular.otf
│   │   ├──     NotoSerifJP-SemiBold.otf
│   │   ├──     pupupu-free.otf
│   │   ├── paira/
│   │   ├──     paira.dart
│   │   ├──     paira_model.dart
│   │   ├── routes/
│   │   ├──     bubble.dart
│   │   ├──     chat.dart
│   │   ├──     chatroom.dart
│   │   │   ├── account/
│   │   │   ├──     account.dart
│   │   │   ├──     header_choice.dart
│   │   │   ├──     hobby_menu.dart
│   │   │   ├──     hobby_menu_next.dart
│   │   │   ├──     image_choice.dart
│   │   │   ├── home/
│   │   │   ├──     common_list.dart
│   │   │   ├──     home.dart
│   │   │   ├──     tab_info.dart
│   │   │   ├──     user_list.dart
│   │   │   │   ├── home_grid/
│   │   │   │   ├──     comment.dart
│   │   │   │   ├──     home_tile.dart
│   │   │   │   ├──     image_circle.dart
│   │   │   │   ├──     title_text.dart
│   │   │   │   ├── user_detail/
│   │   │   │   ├──     user_detail.dart
│   │   │   │   ├──     user_header.dart
│   │   │   │   ├──     user_hobby.dart
│   │   │   │   ├──     user_image.dart
│   │   │   │   ├──     user_name.dart
│   │   │   │   ├──     user_name_comment.dart
```

## 📜 File Descriptions

### 🏠 Main Files
- **`main.dart`** → アプリのエントリーポイント。MaterialAppをセットアップし、ルートを管理
- **`root.dart`** → アプリのメインの画面遷移を制御
- **`model.dart`** → ユーザーデータの登録と管理を処理
- **`polygon_drawer.dart`** → UIのカスタムポリゴンドロワーを処理
- **`reset_password.dart`** → パスワードリセット画面

### 🔥 Authentication & User
- **`user_login.dart`** → Firebase認証を使ったログイン処理
- **`create_profile.dart`** → 新規ユーザーのプロフィール作成処理

### 🗂 Drawer (メニュー画面)
- **`drawer/contact.dart`** → お問い合わせ画面
- **`drawer/contract.dart`** → 契約関連のページ
- **`drawer/privacy.dart`** → プライバシーポリシー
- **`drawer/setting.dart`** → アプリの設定画面

### 🏡 Home & Navigation
- **`routes/home.dart`** → ホーム画面のUIとロジック
- **`routes/chat.dart`** → チャット機能のメイン画面
- **`routes/chatroom.dart`** → チャットルームの詳細画面
- **`routes/bubble.dart`** → チャットの吹き出しUIを定義

### 📸 User Detail & Profile
- **`user_detail/user_detail.dart`** → ユーザープロフィール画面
- **`user_detail/user_image.dart`** → ユーザーのプロフィール画像表示
- **`user_detail/user_name.dart`** → ユーザー名の表示
- **`user_detail/user_hobby.dart`** → ユーザーの趣味情報を表示

### 🎨 UI Components & Widgets
- **`home_grid/comment.dart`** → 投稿のコメント表示
- **`home_grid/home_tile.dart`** → ホーム画面のタイルUI
- **`home_grid/image_circle.dart`** → 円形の画像表示ウィジェット
- **`home_grid/title_text.dart`** → タイトルのテキストUI

## 🔄 Flow of Events
1. **User opens the app** → `main.dart` が `root.dart` を起動
2. **User logs in** → `user_login.dart` でFirebase認証
3. **User navigates to home** → `routes/home.dart` に遷移
4. **User enters a chat** → `routes/chat.dart` に移動し、`chatroom.dart` でメッセージ表示
5. **User views a profile** → `user_detail/user_detail.dart` を開く

## 📦 Installation
1. Clone the repository:
   ```sh
   git clone https://github.com/gaze11a/Polygon-chat.git
   ```
2. Install dependencies:
   ```sh
   flutter pub get
   ```
3. Run the app:
   ```sh
   flutter run
   ```

---
