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
- **`main.dart`** → The entry point of the app, setting up `MaterialApp` and managing routes
- **`root.dart`** → Handles the main navigation flow of the app
- **`model.dart`** → Manages user data registration and storage
- **`polygon_drawer.dart`** → Handles custom polygon drawer UI
- **`reset_password.dart`** → Password reset screen

### 🔥 Authentication & User
- **`user_login.dart`** → Handles user authentication via Firebase
- **`create_profile.dart`** → Manages new user profile creation

### 🗂 Drawer (Navigation Menu)
- **`drawer/contact.dart`** → Contact page
- **`drawer/contract.dart`** → Terms and conditions page
- **`drawer/privacy.dart`** → Privacy policy page
- **`drawer/setting.dart`** → App settings screen

### 🏡 Home & Navigation
- **`routes/home.dart`** → Main home screen UI and logic
- **`routes/chat.dart`** → Main chat screen
- **`routes/chatroom.dart`** → Chat room detail screen
- **`routes/bubble.dart`** → UI for chat message bubbles

### 📸 User Detail & Profile
- **`user_detail/user_detail.dart`** → User profile screen
- **`user_detail/user_image.dart`** → Displays user profile images
- **`user_detail/user_name.dart`** → Displays user names
- **`user_detail/user_hobby.dart`** → Displays user hobbies

### 🎨 UI Components & Widgets
- **`home_grid/comment.dart`** → UI for post comments
- **`home_grid/home_tile.dart`** → Tile UI for home screen
- **`home_grid/image_circle.dart`** → Circular image display widget
- **`home_grid/title_text.dart`** → UI component for title text

## 🔄 Flow of Events
1. **User opens the app** → `main.dart` loads `root.dart`
2. **User logs in** → `user_login.dart` handles Firebase authentication
3. **User navigates to home** → Moves to `routes/home.dart`
4. **User enters a chat** → Moves to `routes/chat.dart` and displays messages in `chatroom.dart`
5. **User views a profile** → Opens `user_detail/user_detail.dart`

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
