# Chronos - Timetable Planner 🚀

Chronos is a premium, beautiful, and highly responsive timetable management application built with **Flutter** and **Dart**. It features a modern, dark-themed UI with smooth gradients, animated micro-interactions, day-by-day scheduling, progress tracking, and persistence.

---

## 🛠️ Tech Stack & Architecture

- **Framework:** [Flutter](https://flutter.dev) & [Dart](https://dart.dev)
- **State Management:** [Riverpod](https://riverpod.dev) (`flutter_riverpod`) - Modern, compile-safe, and highly readable state management.
- **Local Database:** [Hive](https://pub.dev/packages/hive) & [Hive Flutter](https://pub.dev/packages/hive_flutter) - Lightweight, pure-Dart NoSQL database for ultra-fast local object storage.
- **UI Design System:** Custom Material 3 Dark theme featuring vibrant gradients, neon highlights, and premium card layouts.
- **Data Model:** Direct Map-based serialization to bypass code generation (`build_runner`), ensuring the app runs immediately.

---

## 📂 Project Structure

```text
timetable_app/
├── lib/
│   ├── main.dart                      # App entry point (initializes Hive database)
│   ├── models/
│   │   └── timetable_class.dart       # Timetable data model & serialization logic
│   ├── providers/
│   │   └── timetable_provider.dart    # Riverpod state notifier for Hive DB sync
│   └── views/
│       ├── timetable_screen.dart      # Main Screen (holds header, day selector, class list)
│       └── widgets/
│           ├── add_edit_class_sheet.dart # Form sheet with time pickers & colors
│           ├── class_card.dart        # Custom card representing a single class item
│           ├── day_selector.dart      # Horizontal weekday picker with micro-animations
│           └── progress_header.dart   # Interactive daily progress bar & motivation header
├── pubspec.yaml                       # App metadata & dependencies configuration
└── README.md                          # Project guide & instructions
```

---

## 🚀 Setup & Running Instructions

Since this is a new separate directory, you can generate platform-specific files (like Android, iOS, Windows, Web, etc.) and run the project by following these steps:

### 1. Ensure Flutter is Installed
Make sure the Flutter SDK is installed and added to your system's PATH:
- Download the installer from the [Flutter Official Website](https://docs.flutter.dev/get-started/install).
- Run `flutter doctor` in your terminal to verify the setup is complete.

### 2. Generate Platform Folders
Navigate to the `timetable_app` directory in your terminal and run the following command to generate the platform-specific boilerplate folders (Android, iOS, Web):
```bash
cd timetable_app
flutter create --overwrite .
```

### 3. Fetch Dependencies
Install the required packages (Riverpod, Hive, Uuid, etc.):
```bash
flutter pub get
```

### 4. Run the Application
Connect an Android device (via USB Debugging) or start an Android Emulator, then run:
```bash
flutter run
```

To run specifically on Android in release mode:
```bash
flutter run --release
```

To build the APK:
```bash
flutter build apk --release
```

---

## 🌐 Vercel Web Deployment

This project contains a customized build setup for [Vercel](https://vercel.com) that automatically compiles Flutter Web on their build environment.

### Deployment Steps:
1. **Push to Git:** Push this repository to GitHub, GitLab, or Bitbucket.
2. **Import to Vercel:** 
   - Log in to Vercel and click **Add New Project**.
   - Import your repository.
3. **Select Root Directory:** 
   - If `timetable_app` is a sub-directory in your repository, set the **Root Directory** setting to `timetable_app`.
4. **Deploy:**
   - Click **Deploy**! Vercel will automatically read [vercel.json](file:///C:/Users/rissh/OneDrive/Documents/AntiGravity/timetable_app/vercel.json) to execute [build-vercel.sh](file:///C:/Users/rissh/OneDrive/Documents/AntiGravity/timetable_app/build-vercel.sh), install Flutter SDK, build the Web client, and publish it live!

---

## ✨ Features Implemented
1. **Interactive Day Selector:** Horizontal scroll bar to view schedules for Monday through Sunday.
2. **Dynamic Progress Tracking:** Calculates daily progress (completed vs. total classes) and updates the top status bar with customized motivational quotes.
3. **Class Schedule Management:**
   - Subject Name
   - Teacher/Professor
   - Room/Lab location
   - Start and End times (using native time pickers)
   - Custom category tag colors (6 premium color options)
   - Extra details or notes/todo items
4. **Fading Completed Items:** Checking off a class scales down its opacity, crosses out the subject, and updates the daily progress bar.
5. **Full CRUD Support:** Long-press or click the vertical three-dot menu on any card to edit details or delete classes permanently.
