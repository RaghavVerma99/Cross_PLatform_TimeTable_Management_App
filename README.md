# TaskFlow - Simple Task Manager 🚀

TaskFlow is a premium, beautiful, and highly responsive task management (Todo) application built with **Flutter** and **Dart**. It features a modern dark-themed UI with custom gradient progress bars, task category filtering (All, Active, Completed), inline task updates, and local database storage.

---

## 🛠️ Tech Stack & Architecture

- **Framework:** [Flutter](https://flutter.dev) & [Dart](https://dart.dev)
- **State Management:** [Riverpod](https://riverpod.dev) (`flutter_riverpod`) - Used for reactive state management and task filtering.
- **Local Database:** [Hive](https://pub.dev/packages/hive) & [Hive Flutter](https://pub.dev/packages/hive_flutter) - For saving, loading, and persistence.
- **UI Design System:** Custom Material 3 Dark theme featuring deep charcoal surfaces, glowing neon pink/orange gradients, and premium card layouts.

---

## 📂 Project Structure

```text
timetable_app/
├── lib/
│   ├── main.dart                      # App entry point (initializes Hive tasks box)
│   ├── models/
│   │   └── task.dart                  # Task data model & serialization logic
│   ├── providers/
│   │   └── task_provider.dart         # Riverpod notifier & reactive filtering states
│   └── views/
│       ├── task_screen.dart           # Main Screen (holds header, filters list, tasks list)
│       └── widgets/
│           ├── task_card.dart         # Interactive task row item card
│           └── task_header.dart       # Daily statistics & visual progress bar banner
├── build-vercel.sh                    # Automated shell script to deploy on Vercel
├── vercel.json                        # Vercel routing & overrides configuration
├── pubspec.yaml                       # App metadata & dependencies
└── README.md                          # Project documentation
```

---

## 🚀 Setup & Running Instructions

### 1. Run Locally
Navigate to the `timetable_app` directory and generate the platform folders:
```bash
cd timetable_app
flutter create --overwrite .
flutter pub get
flutter run
```

### 2. Deploy to Vercel
Push the code to your GitHub/GitLab/Bitbucket repository, link it in Vercel, set the **Root Directory** to `timetable_app`, and click **Deploy**. Vercel will automatically read `vercel.json` and build the application using `build-vercel.sh`.

---

## ✨ Features Implemented
1. **Visual Progress Dashboard:** Interactive top header showing the percentage of tasks checked off today with an animated gradient status bar.
2. **Category Filtering:** Filter tasks instantly between **All**, **Active**, and **Completed** using animated navigation tabs.
3. **Circular Checkbox Toggles:** Checking/unchecking tasks triggers smooth animations that update completion status and fade the task title.
4. **CRUD Actions:** Simple inline dialogue to edit task names on click, and a quick-delete trash icon for removing items.
