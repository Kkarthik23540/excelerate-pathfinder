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

## Table of Contents

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

## Project Overview

One of the biggest challenges for new learners on Excelerate is knowing **where to begin**. With a growing catalogue of programs and opportunities, first-time users often feel overwhelmed and register for courses without a clear sense of direction — leading to low engagement and high dropout rates.

**Excelerate Pathfinder** solves this by acting as a personal guide from the very first screen.

When a new user registers, the app walks them through a smart **Onboarding Quiz** — asking about their current skill level, career goals, and learning preferences. Based on their answers, the app generates a **Personalised Learning Roadmap** — a curated list of recommended programs ordered by relevance to their goals.

From there, learners can:
- Track their progress through each program
- Earn and view digital certificates
- Give real-time feedback to administrators via **Feedback System**
- Explore new opportunities matched to their profile

Administrators also have their own dedicated dashboards — making Pathfinder a complete two-sided platform.

---

## Why Excelerate Pathfinder?

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

## App Structure & User Roles

Excelerate Pathfinder is built as a **two-sided platform**, with a dedicated experience for each type of user.

```
Excelerate Pathfinder
├──  Learner Side
│   ├── Sign Up / Login / Google Sign-In
│   ├── Onboarding Quiz
│   ├── Personalised Home / Roadmap
│   ├── Browse & Explore Programs
│   ├── Learning Hub (Progress Tracker)
│   ├── Verified Certificates (Landscape View)
│   ├── Feedback Submission
│   └── Profile Management
│
└── Admin Side
    ├── Admin Login
    ├── Dashboard Overview & Analytics
    ├── User Management (Student monitoring)
    ├── Program Management (CRUD)
    └── Announcement Management
```

---

## Key Features

### Smart Onboarding Quiz
New users are guided through a short, friendly quiz when they first register. Questions cover:
- Are you a beginner, intermediate, or advanced learner?
- What is your career goal?
- What field are you most interested in?

The app uses these responses to tailor the experience to the learner's specific needs.

---

### Personalised Learning Roadmap
Based on the onboarding quiz, the app generates a curated list of recommended programs — ordered by fit and goal alignment. Learners always know what to do next.

---

### Learning Hub & Progress Tracker
Every enrolled program shows a live progress indicator. Learners can see what they have completed and what percentage remains, keeping motivation high through visual feedback.

---

### Verified Certificates
Upon program completion, learners can view formal certificates. The app includes a specialized landscape-oriented certificate viewer for a professional experience.

---

### Real-time Feedback
A dedicated feedback system allows learners to share their insights and suggestions directly with the platform. This data is stored in Firestore for administrative review.

---

### Admin Dashboard & Program Management
Administrators have a robust portal to:
- View high-level metrics of platform activity (Analytics)
- Create, edit, and manage programs in the live catalog
- Monitor and manage user accounts
- Publish announcements to all learners

---

## Screenshots

*(Upload and link your app screenshots here to showcase the UI)*

---

## Technology Stack

| Layer | Technology |
|---|---|
| **Frontend** | Flutter (Dart) |
| **Backend / Database** | Firebase (Cloud Firestore) |
| **Authentication** | Firebase Authentication + Google Sign-In |
| **Real-time Sync** | Firestore real-time listeners (StreamBuilders) |
| **UI Enhancements** | Flutter Animate, Confetti, Material 3 |

### Flutter & Dart
The entire UI is built with Flutter using a component-based architecture. A centralized theme system (`lib/theme/`) ensures consistent branding across both Admin and Learner roles.

### Firebase
Firebase powers the entire backend:
- **Firebase Auth** — handles email/password and Google OAuth flows.
- **Cloud Firestore** — NoSQL database for users, programs, certificates, and feedback.
- **Real-time Sync** — Ensures dashboards and progress bars update instantly.

---

## Project Dependencies

### `pubspec.yaml` — Key Dependencies

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

## Firebase Configuration

Firebase must be configured for the project to run correctly.

### Required Configuration Files

| Platform | File Location |
|---|---|
| **Android** | `android/app/google-services.json` |
| **iOS** | `ios/Runner/GoogleService-Info.plist` |

---

## Setup & Installation

### Step 1 — Clone the Repository
```bash
git clone https://github.com/Kkarthik23540/excelerate-pathfinder.git
cd excelerate-pathfinder
```

### Step 2 — Add Firebase Config
Place your `google-services.json` in `android/app/` and ensure `firebase_options.dart` is correctly configured in `lib/`.

### Step 3 — Install Dependencies
```bash
flutter pub get
```

### Step 4 — Run the Application
```bash
flutter run
```

---

## Backend Architecture

### Firestore Data Structure

```
firestore/
│
├── users/ (User profiles & roles)
├── programs/ (Learning opportunities)
├── announcements/ (System-wide notices)
├── feedback/ (Learner submissions)
├── achievements/ (User XP, levels, and badges)
└── audit_logs/ (Administrative action tracking)
```

---

## Contribution Log & Changelog

### Version History
**v1.0.0** — Internship Final Submission (June 2024)

### Feature Changelog

| Feature | Description | Status |
|---|---|---|
| **Auth System** | Email/Password & Google login with role-based routing | ✅ Done |
| **Admin CRUD** | Full Create/Read/Update/Delete for programs & announcements | ✅ Done |
| **Onboarding** | Smart quiz system with data persistence | ✅ Done |
| **Learning Hub** | Real-time progress tracking and enrollment management | ✅ Done |
| **Certificates** | Professional landscape certificate generator | ✅ Done |
| **Audit Logs** | Backend tracking of all administrative actions | ✅ Done |
| **UI Polish** | Custom animations, confetti, and unified branding | ✅ Done |

---

## Developer

**K Karthik Reddy**
[GitHub Profile](https://github.com/Kkarthik23540)
*Excelerate Mobile Development Intern*

---

<div align="center">

**Built for the Excelerate Mobile Internship 2024**

[![Flutter](https://img.shields.io/badge/Made%20with-Flutter-02569B?style=flat&logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Powered%20by-Firebase-FFCA28?style=flat&logo=firebase&logoColor=black)](https://firebase.google.com)

</div>
