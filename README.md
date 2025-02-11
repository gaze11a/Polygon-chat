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
- **`main.dart`** → Determines whether to show the login screen or first-time launch setup
- **`root.dart`** → Handles bottom navigation and main screen transitions, manages Firebase Messaging (FCM) tokens for notifications
- **`model.dart`** → Manages user input, image uploads, and form validation, including image compression for Firebase Storage
- **`polygon_drawer.dart`** → Controls the app's side navigation drawer, providing access to settings, contact, and logout functionality
- **`reset_password.dart`** → Handles password reset by sending a reset link to the user's registered email

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
1. **User opens the app** → `main.dart` checks session data
2. **If it's the first launch** → The app navigates to `FirstView()` (e.g., contract or onboarding screen)
3. **If the user is logged in** → The app navigates to `RootWidget(usermail: mail!)`
4. **If no login data is found** → The app redirects to `UserLogin()`
5. **User enters profile information** → `model.dart` handles text input, stores values, and validates required fields
6. **User uploads a profile image** → `model.dart` compresses and uploads the image to Firebase Storage
7. **User accesses settings or contacts** → `polygon_drawer.dart` manages navigation to `Setting()` and `Contact()`
8. **User logs out** → `polygon_drawer.dart` clears session data and removes Firebase Cloud Messaging (FCM) tokens
9. **User requests a password reset** → `reset_password.dart` sends a reset link using Firebase Authentication
10. **User logs in** → `user_login.dart` handles authentication
11. **User navigates between screens** → `root.dart` manages bottom navigation transitions
12. **User receives a notification** → `root.dart` processes Firebase Cloud Messaging (FCM) token updates

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
