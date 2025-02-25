## 📱 App Screenshots

### 🔒 Secure & Real-Time Chat with Firestore
<img src="./assets/screenshots/chat_screen.png" alt="Chat Screen" width="300">  

- Chat with confidence using **Firebase Firestore** for real-time and secure messaging.
- Messages are stored safely, ensuring privacy and reliability.
- Seamless experience with instant message delivery.

---

### 📝 AI-Powered Chat Summaries
<img src="./assets/screenshots/summary.png" alt="Chat Summary Screen" width="300">  

- **AI-generated chat summaries** help you remember key moments effortlessly.
- OpenAI analyzes conversations and creates daily recaps automatically.
- Easily browse past interactions in a structured way.

---

### 🎨 Simple & Clean Home Screen
<img src="./assets/screenshots/home_screen.png" alt="Home Screen" width="300">  

- A minimalistic design that makes navigation easy.
- Quickly access chats with users who share your interests.
- Smooth and intuitive UI for a great user experience.

---


## 📂 Project Structure

```
lib/
│  main.dart                           # Checks session data and starts the app
│  root.dart                           # Manages bottom navigation and notifications
│  
├─fonts/
│  
├─login/
│      create_profile.dart             # Manages new user profile creation
│      first_view.dart                 # Displays Terms of Service and Privacy Policy
│      reset_password.dart             # Sends password reset emails via Firebase
│      user_login.dart                 # Handles Firebase Authentication login
│      
└─routes/
    ├─account/
    │      account.dart                # User profile page
    │      
    ├─chat/
    │      bubble.dart                 # Chat message bubbles
    │      chat.dart                   # Main chat screen
    │      chatroom.dart               # Individual chat rooms
    │      chat_summary.dart           # Handles message summarization logic using OpenAI API
    │      chat_summary_page.dart      # UI for viewing chat summaries in list or calendar format
    │      
    ├─home/
    │  │  home.dart                   # Main home screen
    │  │  polygon_drawer.dart         # Side menu (settings, contact, logout)
    │  │  tab_info.dart               # Manages home screen tabs
    │  │  user_list.dart              # User list in home screen
    │  │  
    │  ├─drawer/
    │  │      contact.dart            # Contact page
    │  │      contract.dart           # Terms & conditions
    │  │      privacy.dart            # Privacy policy
    │  │      setting.dart            # Settings page
    │  │      
    │  ├─user_detail/
    │  │      user_detail.dart        # Full user profile screen
    │  │      user_header.dart        # Displays header images
    │  │      user_image.dart         # Profile images
    │  │      user_name.dart          # Displays user names
    │  │      user_name_comment.dart  # User name with comments
    │  │      
    │  └─user_tile/
    │          comment.dart            # User comment section
    │          home_tile.dart          # Tile UI for displaying users
    │          image_circle.dart       # Circular profile images
    │          title_text.dart         # UI component for text titles
    │          
    └─utils/
            image_choice.dart           # User profile image selection
            loading_dialog.dart         # Shows loading dialog during async operations
            model.dart                  # Handles user input and Firebase Storage uploads
```


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
