# ⚡ TaskFlow — Developer & Deployment Manual

TaskFlow is a production-grade, minimalist task management client compiled in **Flutter 3.x / Dart 3.x**. It implements **Riverpod** for declarative state, **Hive** for zero-latency local storage, and **Vercel** serverless pipelines for static web delivery.

---

## 🛠️ Technical Stack Specification

| Layer | Technology / Package | Version | Purpose |
| :--- | :--- | :--- | :--- |
| **SDK** | Dart & Flutter | `>=3.0.0 <4.0.0` | Core compiler & runtime |
| **State** | `flutter_riverpod` | `^2.5.1` | Decoupled reactive view-models & filtering state |
| **Database** | `hive_flutter` | `^1.1.0` | In-memory key-value/document store with disk sync |
| **Utils** | `uuid` & `intl` | `^4.3.3` / `^0.19.0` | Unique ID generation & localized date presentation |
| **CI/CD** | Vercel Static hosting | `V2` | Automated Git-triggered cloud web builds |

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

## 🚀 Execution & Deployment Runbook

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

### 🌐 Vercel Cloud Pipeline Configuration
Deployments are fully automated via `vercel.json` pointing to a customized runtime shell script.

#### Configuration File: [vercel.json](file:///C:/Users/rissh/OneDrive/Documents/AntiGravity/timetable_app/vercel.json)
Directs Vercel to route virtual paths to `index.html` (supporting routing) and overrides commands:
```json
{
  "cleanUrls": true,
  "buildCommand": "bash build-vercel.sh",
  "outputDirectory": "build/web"
}
```

#### Build Shell Script: [build-vercel.sh](file:///C:/Users/rissh/OneDrive/Documents/AntiGravity/timetable_app/build-vercel.sh)
Executed by Vercel's build VM. You do not need to pre-configure or install Flutter on your dashboard:
1. Clones the stable Flutter SDK (`--depth 1` shallow clone to speed up builds).
2. Sets environment `$PATH` configuration.
3. Automatically triggers template configuration (`flutter create .`).
4. Compiles the static web bundle using the CanvasKit engine (`flutter build web --release --web-renderer canvaskit`).

To deploy, push the workspace to your Git provider, connect Vercel, set the project's **Root Directory** to `timetable_app`, and click **Deploy**.
