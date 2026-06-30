<div align="center">

# Excelerate Pathfinder

### *Know where to start. Own your learning journey.*

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

**Excelerate Pathfinder** is a smart onboarding and career-guidance mobile app built for the [Excelerate](https://excelerate.africa) platform — designed to help new learners and career-changers discover the right programs, track their growth, and stay connected with administrators, all from one place.

> Built during the **Excelerate Mobile Internship** | `excelerate-pathfinder`

</div>

---

## 📑 Table of Contents

- [Project Overview](#-project-overview)
- [Why Excelerate Pathfinder?](#-why-excelerate-pathfinder)
- [App Structure & User Roles](#-app-structure--user-roles)
- [Key Features](#-key-features)
- [Screenshots](#-screenshots)
- [Technology Stack](#-technology-stack)
- [Project Dependencies](#-project-dependencies)
- [Firebase Configuration](#-firebase-configuration)
- [Setup & Installation](#-setup--installation)
- [Backend Architecture](#-backend-architecture)
- [Contribution Log & Changelog](#-contribution-log--changelog)
- [Developer](#-developer)

---

## 🚀 Project Overview

One of the biggest challenges for new learners on Excelerate is knowing **where to begin**. With a growing catalogue of programs and opportunities, first-time users often feel overwhelmed and register for courses without a clear sense of direction — leading to low engagement and high dropout rates.

**Excelerate Pathfinder** solves this by acting as a personal guide from the very first screen.

When a new user registers, the app walks them through a smart **Onboarding Quiz** — asking about their current skill level, career goals, and learning preferences. Based on their answers, the app generates a **Personalised Learning Roadmap** — a curated list of recommended programs ordered by relevance to their goals.

From there, learners can:
- Track their progress through each program
- Earn and view digital certificates
- Give real-time feedback to administrators
- Explore new opportunities matched to their profile

Administrators have their own dedicated dashboards — making Pathfinder a complete two-sided platform.

---

## 💡 Why Excelerate Pathfinder?

### Benefits to Excelerate (the Platform)

| Benefit | How Pathfinder Delivers It |
|---|---|
|  **Higher learner retention** | Personalised roadmaps reduce overwhelm and keep learners on the right track from day one |
|  **Better program-learner matching** | Onboarding quiz data ensures learners join programs they are actually ready for and interested in |
|  **Real-time quality feedback** | Feedback system gives admins instant insight into program effectiveness |
|  **Improved learner visibility** | Admins can monitor progress, manage users, and identify learners who need support |
|  **Simplified Onboarding** | Self-guided onboarding means fewer learners asking "where do I start?" |

### Benefits to Learners

-  **Clarity from day one** — Never again stare at a catalogue wondering what to pick
-  **A personalised path** — Programs recommended for *your* goals and *your* level
-  **Visible progress** — See exactly how far you've come in every program
-  **Verified Credentials** — View your achievements in a formal certificate format
-  **Your voice matters** — Dedicated feedback system lets you rate your experience
-  **Your own profile** — Manage your journey, credentials, and learning history in one place

---

## 🏗 App Structure & User Roles

Excelerate Pathfinder is built as a **two-sided platform**, with a dedicated experience for each type of user.

```
Excelerate Pathfinder
├──  Learner Side
│   ├── Sign Up / Login (Email & Google)
│   ├── Onboarding Quiz
│   ├── Personalised Dashboard (Roadmap)
│   ├── Explore & Browse Programs
│   ├── Learning Hub (Enrolled Courses)
│   ├── Program Progress Tracker
│   ├── Announcements & Notifications
│   ├── Verified Certificates (Landscape View)
│   ├── Feedback Submission
│   └── Profile Management
│
└── Admin Side
    ├── Admin Login
    ├── Dashboard Overview (Stats)
    ├── User Management (Student Directory)
    ├── Program Management (Full CRUD)
    ├── Announcement Management
    ├── Audit Logs (Action Tracking)
    └── Admin Profile & Settings
```

---

## 🛠 Key Features

### Smart Onboarding Quiz
New users are guided through a short, friendly quiz when they first register. The results are stored in Firestore and used to calculate a personalized entry point into the Excelerate ecosystem.

---

### Personalised Learning Roadmap
The Home screen serves as a dynamic roadmap, highlighting programs that match the user's skill level and career field identified during onboarding.

---

### Progress Tracker & Learning Hub
A dedicated "Learning Hub" allows students to track their progress across multiple programs. Visual progress bars and percentage indicators provide immediate feedback on their journey.

---

### Professional Certificates
Upon completion, the app generates a formal certificate. A custom landscape view provides a high-fidelity visual representation of the learner's achievement.

---

### Admin Portal & Audit Logs
Administrators have total control over the platform's content. Every administrative action (Create, Edit, Delete) is logged in an **Audit Trail** for security and transparency.

---

## 📸 Screenshots

*(Add screenshots to the repository and update links below)*

---

## 💻 Technology Stack

| Layer | Technology |
|---|---|
| **Frontend** | Flutter (Dart) |
| **Backend / Database** | Firebase (Cloud Firestore) |
| **Authentication** | Firebase Authentication & Google Sign-In |
| **Real-time Sync** | Firestore StreamBuilder |
| **Theming** | Custom Design System (Material 3) |

---

## 📦 Project Dependencies

### `pubspec.yaml`

```yaml
dependencies:
  firebase_core: ^4.10.0
  cloud_firestore: ^6.5.0
  firebase_auth: ^6.5.2
  google_sign_in: ^6.1.5
  confetti: ^0.7.0
  url_launcher: ^6.2.0
  intl: ^0.18.0
  cupertino_icons: ^1.0.8
```

---

## 🔥 Firebase Configuration

### Required Configuration Files

| Platform | File Location |
|---|---|
| **Android** | `android/app/google-services.json` |
| **iOS** | `ios/Runner/GoogleService-Info.plist` |
| **Dart Config** | `lib/firebase_options.dart` |

---

## ⚙️ Setup & Installation

### Step 1 — Clone the Repository
```bash
git clone https://github.com/Kkarthik23540/excelerate-pathfinder.git
cd excelerate-pathfinder
```

### Step 2 — Add Configuration
Add your `google-services.json` to the `android/app/` folder.

### Step 3 — Install & Run
```bash
flutter pub get
flutter run
```

---

## 🏛 Backend Architecture

### Complete Project Structure (lib/)

```
lib/
├── firebase_options.dart
├── main.dart
├── screens/
│   ├── splash_screen.dart
│   ├── admin/
│   │   ├── admin_analytics_screen.dart
│   │   ├── admin_announcements_screen.dart
│   │   ├── admin_home_screen.dart
│   │   ├── admin_login_screen.dart
│   │   ├── admin_profile_screen.dart
│   │   ├── admin_programs_screen.dart
│   │   ├── admin_users_screen.dart
│   │   └── admin_user_details_screen.dart
│   └── learner/
│       ├── learner_announcements_screen.dart
│       ├── learner_browse_programs_screen.dart
│       ├── learner_explore_screen.dart
│       ├── learner_feedback_screen.dart
│       ├── learner_forgot_password_screen.dart
│       ├── learner_home_screen.dart
│       ├── learner_learning_screen.dart
│       ├── learner_login_screen.dart
│       ├── learner_onboarding_quiz_screen.dart
│       ├── learner_profile_screen.dart
│       ├── learner_program_details_screen.dart
│       ├── learner_progress_screen.dart
│       ├── learner_quick_links_screen.dart
│       └── learner_signup_screen.dart
├── theme/
│   └── app_theme_splash.dart
└── widgets/
    ├── admin_bottom_nav.dart
    └── learner_bottom_nav.dart
```

### Firestore Data Structure

```
firestore/
│
├── users/            # User profiles, authentication data, and roles
├── programs/         # Comprehensive catalog of learning opportunities (Full CRUD)
├── announcements/    # Real-time system-wide notices and updates
├── achievements/     # Learner XP, levels, and unlocked milestones
├── certificates/     # Issued digital credentials and completion data
├── enrollments/      # Mapping of learners to their active programs
├── feedback/         # Direct learner insights and program ratings
├── learnerProfiles/  # Specialized data from the onboarding quiz
└── audit_logs/       # Immutable history of administrative actions
```

---

## 📝 Contribution Log & Changelog

### Feature Roadmap (v1.0.0)

| Feature | Description | Status |
|---|---|---|
| **Auth** | Dual authentication flows (Learner/Admin) | ✅ Done |
| **Quiz** | Onboarding system with Firestore persistence | ✅ Done |
| **CRUD** | Program management portal for Administrators | ✅ Done |
| **Hub** | Real-time progress and enrollment tracking | ✅ Done |
| **Cert** | Specialized landscape certificate viewer | ✅ Done |
| **Logs** | Security-focused audit logging system | ✅ Done |

---

## 👤 Developer

**K Karthik Reddy**
[GitHub Profile](https://github.com/Kkarthik23540)
*Excelerate Mobile Development Intern*

---

<div align="center">

**Built for the Excelerate Mobile Internship 2026**

[![Flutter](https://img.shields.io/badge/Made%20with-Flutter-02569B?style=flat&logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Powered%20by-Firebase-FFCA28?style=flat&logo=firebase&logoColor=black)](https://firebase.google.com)

</div>
