# Excelerate Pathfinder 🚀

Excelerate Pathfinder is a comprehensive learning management application built with Flutter and Firebase. It serves two primary user roles: **Learners**, who can explore and enroll in various programs, and **Admins**, who manage the curriculum and monitor system activity.

## 🌟 Key Features

### For Learners
- **Personalized Dashboard**: Real-time progress tracking, level-based XP system, and active program status.
- **Dynamic Program Discovery**: Browse and search through programs fetched live from Firebase Firestore.
- **Program Details**: View curriculum, instructor details, and enroll with a single tap.
- **Achievements & Badges**: Unlockable badges with confetti celebrations upon reaching milestones.
- **Feedback System**: Integrated form with validation to provide feedback directly to the administration.
- **Real-time Announcements**: Stay updated with the latest news and notifications fetched live from Cloud Firestore.

### For Admins
- **Program Management**: Full CRUD capabilities to add, view, and delete programs from the live catalog.
- **Admin Portal**: Secure login and dedicated navigation for managing the platform.
- **Audit Logs**: Backend tracking of administrative actions for security.

## 🛠 Tech Stack
- **Frontend**: Flutter (Dart)
- **Backend**: Firebase Authentication & Cloud Firestore
- **Data Management**: Firebase Firestore for all dynamic content (Programs, Announcements, User Data)
- **Animations**: Flutter Animate, Confetti, and Custom Tween Animations
- **State Management**: StatefulWidget with StreamBuilders for real-time updates

## 📂 Project Structure
- `lib/screens/`: Contains all UI screens for both Admin and Learner roles.
- `lib/widgets/`: Reusable UI components like navigation bars.
- `lib/theme/`: Centralized design tokens and app-wide styling configuration.
- `lib/main.dart`: Application entry point and theme configuration.

## 🚀 Getting Started

### Prerequisites
- Flutter SDK installed
- Android Studio / VS Code
- Firebase Project setup

### Setup Instructions
1. **Clone the repository**:
   ```bash
   git clone https://github.com/Kkarthik23540/excelerate-pathfinder.git
   ```
2. **Install dependencies**:
   ```bash
   flutter pub get
   ```
3. **Configure Firebase**:
   - Ensure `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) are in their respective directories.
4. **Run the app**:
   ```bash
   flutter run
   ```

## 📜 Changelog

### Week 4 (Final Release)
- Finalized Admin Portal with full Program Management (CRUD).
- Enhanced UX with logo animations and confetti effects.
- Implemented landscape-only Certificate View.
- Completed final documentation and README polishing.

### Week 3
- Integrated Firebase Authentication (Email/Password & Google Sign-in).
- Connected UI to live Firestore collections for Programs and Announcements.
- Added Feedback Form with real-time validation and Firestore submission.

### Week 2
- Built core UI screens for Learners (Home, Browse, Profile, Learning Hub).
- Implemented role-based navigation logic in SplashScreen.
- Applied consistent branding using a centralized theme.

### Week 1
- Initialized Flutter project and GitHub repository.
- Defined app architecture and project proposal.

## 📸 Screenshots
*(Add your app screenshots here to showcase your hard work!)*

---
*Developed as part of the Excelerate Internship Program.*
