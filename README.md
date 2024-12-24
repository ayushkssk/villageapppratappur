# Village App

A comprehensive Flutter application for managing village-related information and services.

## Latest Updates (v1.1.0)

### Navigation Improvements
- Implemented unified bottom navigation across all screens
- Smooth transitions between Home, Chat, Events, and Reels sections
- Consistent UI/UX experience throughout the app

### Authentication
- Email/Password login and signup
- Google Sign-in integration
- Secure authentication using Firebase Auth
- Persistent login state
- Improved error handling

### Admin Panel
- News Updates Management
- Event Management
- Emergency Alerts System
- User Management

### Home Screen
- Image Slider with auto-scroll and page indicators
- Quick Access Menu
- News Updates Section
- Upcoming Events
- Emergency Alerts Display

### Data Management
- Firebase Firestore Integration
- Real-time Updates
- Efficient Data Caching
- Optimized Image Loading

## Technical Details

### Architecture
- Provider State Management
- Clean Architecture Pattern
- Modular Code Structure
- Reusable Components

### Navigation System
The app uses a unified bottom navigation system implemented in `common_navbar.dart`:
- Consistent navigation experience
- Four main sections: Home, Chat, Events, and Reels
- State preservation across navigation
- Smooth transitions

### Firebase Integration
- Authentication
- Cloud Firestore
- Real-time Updates
- Security Rules

### Performance Optimizations
- Lazy Loading
- Image Caching
- Efficient State Management
- Error Handling

## Setup Instructions

1. Clone the repository:
```bash
git clone https://github.com/yourusername/villageapp.git
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase:
   - Create a new Firebase project
   - Add Android/iOS apps in Firebase console
   - Download and add configuration files
   - Enable Authentication methods (Email/Password, Google)
   - Set up Firestore database

4. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
  ├── village/
  │   ├── auth/
  │   │   ├── models/
  │   │   ├── providers/
  │   │   ├── screens/
  │   │   └── services/
  │   ├── screens/
  │   │   ├── admin/
  │   │   ├── home_screen.dart
  │   │   ├── chat_screen.dart
  │   │   ├── events_screen.dart
  │   │   └── reels_screen.dart
  │   ├── widgets/
  │   │   └── common_navbar.dart
  │   └── services/
  └── main.dart
```

## Dependencies

- firebase_core: ^2.24.2
- firebase_auth: ^4.15.3
- cloud_firestore: ^4.13.6
- provider: ^6.1.1
- google_sign_in: ^6.2.1
- flutter_svg: ^2.0.9

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
