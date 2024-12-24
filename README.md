# Village App Pratappur (v1.0.0)

A Flutter application for village community management with features like photo gallery, emergency services, government schemes information, and more.

## Current Version Features (v1.0.0)

- 🏠 Home Screen with Auto-sliding Image Gallery
- 📸 Middle School Photo Collection
- 🎯 Smooth Image Transitions
- 📱 Touch-enabled Controls
- 🔄 Automatic Image Looping
- 📢 News and Notifications Section
- 🎨 Modern Material Design UI

## Planned Features

- 🔐 Authentication with Email/Password and Google Sign In
- 📸 Complete Photo Gallery
- 🚑 Emergency Services
- 📜 Government Schemes Information
- 📝 Grievance Portal
- 📞 Important Contacts
- 🎯 Talent Corner
- 📢 Enhanced Notifications

## Setup Instructions

### Prerequisites

- Flutter SDK (latest version)
- Android Studio / VS Code
- Firebase Account
- Git

### Installation Steps

1. **Clone the Repository**
   ```bash
   git clone https://github.com/yourusername/villageapp.git
   cd villageapp
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   
   a. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   
   b. Add Android & iOS apps in your Firebase project:
      - Use package name: `com.example.villageapp`
      - Download `google-services.json` for Android
      - Download `GoogleService-Info.plist` for iOS
   
   c. Place configuration files:
      - Put `google-services.json` in `android/app/`
      - Put `GoogleService-Info.plist` in `ios/Runner/`

4. **Enable Authentication Methods in Firebase**
   - Go to Authentication > Sign-in methods
   - Enable Email/Password
   - Enable Google Sign-in

5. **Setup Google Sign In**
   
   For Android:
   - Get your SHA-1 and SHA-256 fingerprints:
     ```bash
     cd android
     ./gradlew signingReport
     ```
   - Add these fingerprints in Firebase Console under your Android app

   For iOS:
   - Update your `Runner` target's `Bundle Identifier` in Xcode
   - Add `GoogleService-Info.plist` to Runner target

6. **Generate Firebase Options**
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

### Running the App

```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart
├── firebase_options.dart
├── services/
│   └── auth_service.dart
└── village/
    └── screens/
        ├── auth/
        │   └── login_screen.dart
        ├── home_screen.dart
        ├── photo_gallery_home.dart
        ├── emergency_services.dart
        ├── government_schemes.dart
        ├── grievance_portal.dart
        ├── important_contacts.dart
        ├── notifications.dart
        └── talent_corner.dart
```

## Security

- All Firebase configuration files are ignored in `.gitignore`
- Make sure to never commit sensitive information
- Use environment variables for API keys
- Keep your `google-services.json` and `GoogleService-Info.plist` private

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details
