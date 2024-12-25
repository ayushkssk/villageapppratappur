# Village App

A comprehensive Flutter application for managing village-related information and services.

## Latest Updates (v1.2.0)

### News Update UI Improvements
- **Enhanced Image Selection**
  - Gallery image picker with preview
  - Asset image selection grid with thumbnails
  - Support for both network and asset images
  - Improved image preview with loading states
  - Remove/change image functionality

- **Admin Panel Enhancements**
  - Redesigned news update cards with better layout
  - Edit functionality for existing news updates
  - Improved delete confirmation dialogs
  - Better error handling and user feedback
  - Loading indicators for async operations

- **UI/UX Improvements**
  - Fixed overflow issues in dialogs
  - Responsive layout adaptations
  - Consistent styling and animations
  - Better input validation and error messages
  - Smooth transitions and loading states

### Previous Updates (v1.1.0)

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

### News Update System
- **Image Management**
  - Support for both local and asset images
  - Automatic image compression and resizing
  - Efficient caching mechanism
  - Fallback images for failed loads

- **State Management**
  - Real-time updates using Firestore streams
  - Optimistic UI updates for better UX
  - Proper error handling and recovery
  - Loading state management

- **UI Components**
  - Reusable image picker dialog
  - Custom card layouts
  - Loading indicators
  - Error message displays

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
  │   │   │   ├── admin_panel.dart        # Admin dashboard with CRUD operations
  │   │   │   └── components/             # Reusable admin components
  │   │   ├── home_screen.dart           # Main home screen
  │   │   └── main_screen.dart           # App shell with navigation
  │   ├── services/
  │   │   ├── auth_service.dart
  │   │   └── firestore_service.dart     # Firebase operations
  │   ├── models/
  │   │   ├── news_update.dart           # News update data model
  │   │   └── event.dart                 # Event data model
  │   └── widgets/
  │       ├── image_picker_dialog.dart    # Custom image picker
  │       └── news_card.dart             # News display card
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

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## Acknowledgments

* Flutter Team for the amazing framework
* Firebase for backend services
* All contributors who helped improve this app
