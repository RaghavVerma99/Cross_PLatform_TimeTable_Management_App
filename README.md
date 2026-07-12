# ⚡ TaskFlow — Developer & Deployment Manual

TaskFlow is a production-grade, minimalist task management client compiled in **Flutter 3.x / Dart 3.x**. It implements **Riverpod** for declarative state, **Hive** for zero-latency local storage, and **Render** blueprint pipelines for static web hosting.

---

## 🛠️ Technical Stack Specification

| Layer | Technology / Package | Version | Purpose |
| :--- | :--- | :--- | :--- |
| **SDK** | Dart & Flutter | `>=3.0.0 <4.0.0` | Core compiler & runtime |
| **State** | `flutter_riverpod` | `^2.5.1` | Decoupled reactive view-models & filtering state |
| **Database** | `hive_flutter` | `^1.1.0` | In-memory key-value/document store with disk sync |
| **Utils** | `uuid` & `intl` | `^4.3.3` / `^0.19.0` | Unique ID generation & localized date presentation |
| **CI/CD** | Render Static Sites | `Blueprints` | Automated Git-triggered cloud web builds |

---

## 📂 Project Architecture & Data Flow

```text
[UI Widgets] ──(reads)──> [filteredTasksProvider] <──(filters)── [taskFilterProvider]
      │                               ▲
 (triggers)                        (notifies)
      ▼                               │
[User Action] ──(invokes)──> [TaskNotifier] ──(saves)──> [Hive DB Box ('tasks')]
```

### File Hierarchy Mapping
- [main.dart](file:///C:/Users/rissh/OneDrive/Documents/AntiGravity/timetable_app/lib/main.dart) — Initializes `Hive.initFlutter()`, opens the `'tasks'` database box, and mounts the root `ProviderScope`.
- [task.dart](file:///C:/Users/rissh/OneDrive/Documents/AntiGravity/timetable_app/lib/models/task.dart) — Defines the `Task` entity structure. Performs database serialization through `toMap()` and `fromMap()` to bypass reflection and code-generation overhead.
- [task_provider.dart](file:///C:/Users/rissh/OneDrive/Documents/AntiGravity/timetable_app/lib/providers/task_provider.dart) — Houses the `TaskNotifier` (managing state and database writes) and custom filters (`All`, `Active`, `Completed`).
- [task_screen.dart](file:///C:/Users/rissh/OneDrive/Documents/AntiGravity/timetable_app/lib/views/task_screen.dart) — Primary viewport scaffold displaying headers, filter chips, and task lists.
- **[widgets/](file:///C:/Users/rissh/OneDrive/Documents/AntiGravity/timetable_app/lib/views/widgets/)** — Contains isolated atomic presentation units:
  - [task_header.dart](file:///C:/Users/rissh/OneDrive/Documents/AntiGravity/timetable_app/lib/views/widgets/task_header.dart): Calculates live execution ratios and controls the status bar.
  - [task_card.dart](file:///C:/Users/rissh/OneDrive/Documents/AntiGravity/timetable_app/lib/views/widgets/task_card.dart): Handles touch gestures (tap to edit, long-press/icon to delete, toggle checkbox).

---

## 🚀 Execution & Cloud Deployment Runbook

### Local Development Setup
Ensure the Flutter SDK is installed and added to your environmental `$PATH`. Run:
```bash
cd timetable_app
flutter create --overwrite .      # Regenerates platform folders (android/ios/web)
flutter pub get                  # Resolves and downloads packages
flutter run -d chrome            # Launches web development server
flutter run                      # Compiles and runs on connected device/emulator
```

### Native Mobile Builds
```bash
flutter build apk --release      # Outputs optimized Android APK to build/app/outputs/flutter-apk/
flutter build appbundle --release # Outputs optimized AAB for Google Play Store upload
```

### 🌐 Cloud Deployment (Render Static Site)
This repository includes a Blueprint configuration for [Render](https://render.com) to build and host Flutter Web automatically.

#### How to Deploy:
1. Push this workspace folder to a remote repository on GitHub, GitLab, or Bitbucket.
2. Log in to the [Render Dashboard](https://dashboard.render.com).
3. Click **New +** and select **Blueprint**.
4. Connect your Git repository.
5. Render will automatically read [render.yaml](file:///C:/Users/rissh/OneDrive/Documents/AntiGravity/timetable_app/render.yaml), execute [build-render.sh](file:///C:/Users/rissh/OneDrive/Documents/AntiGravity/timetable_app/build-render.sh) to compile the client, and serve the output folder live!
