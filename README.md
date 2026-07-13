# 📱 TaskFlow & Schedule Manager — Technical Manual

TaskFlow is a production-grade, minimalist task and schedule management client built with **Flutter** and **Dart**.  Backed by **Riverpod** for reactive state propagation and **Hive** for zero-latency local document caching.

---

## 🛠️ Technical Stack & Architecture

### Stack Specifications
- **Framework**: `Flutter SDK (>=3.0.0)` — Cross-platform rendering engine.
- **State Management**: `flutter_riverpod (v2.x)` — Decoupled unidirectional state-notifier pattern with reactive filtering providers.
- **Database/Caching**: `hive_flutter (v1.x)` — Lightweight, zero-dependency NoSQL key-value store syncing binary payloads directly to disk.

---

## 📂 Project Topology & Directory Architecture

```text
lib/
├── main.dart                 # App bootstrap, database box initialization, ProviderScope mount
├── models/
│   ├── task.dart             # Task data schema with direct map serialization (bypasses reflection)
│   └── timetable_slot.dart   # Schedule slot entity with active-state runtime evaluation logic
├── providers/
│   ├── task_provider.dart    # Riverpod StateNotifier for CRUD operations & filter states
│   └── timetable_provider.dart# Riverpod StateNotifier for weekly slot filtering & active slot polling
└── views/
    ├── home_screen.dart      # Navigation controller displaying iOS-style translucent bottom tab bar
    ├── dashboard_page.dart   # Main view housing Apple Fitness-style circular activity ring
    ├── tasks_page.dart       # Task view with Cupertino Sliding Segmented Control filter chips
    ├── timetable_page.dart   # Weekly scheduler showing circular iOS Calendar style day badges
    └── widgets/
        ├── task_card.dart    # iOS Reminders-style checklist widget with check animation
        ├── task_header.dart  # Top bar task statistics calculation and Indigo progress bar
        ├── timetable_card.dart# Sleek Gray 6 slot card containing active pulse state indicators
        └── add_slot_dialog.dart# Apple Form style modal editor with custom iOS color presets
```

---

## ⚙️ Core Technical Workflows

### 1. State Management & Filtering Pipeline
Riverpod selectors are optimized to prevent unnecessary widget rebuilds. For example, `filteredTasksProvider` listens to changes in both the raw `taskProvider` and `taskFilterProvider` using:
```dart
final filteredTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(taskProvider);
  final filter = ref.watch(taskFilterProvider);
  // Evaluates and returns filtered lists dynamically
});
```

### 2. Local Database Synchronization (Hive)
Both tasks and timetable slots are saved locally. Serialization maps are handled directly inside the data models to optimize memory and load speeds:
```dart
// Native Hive box transactions bypass heavy ORM engines
final taskBox = Hive.box('tasks');
taskBox.put(task.id, task.toMap());
```

### 3. Active-Slot Telemetry & Pulse Indicators
The application dynamically calculates if a schedule slot is currently running based on the user's local time:
```dart
bool isActiveAt(DateTime time) {
  final nowMinutes = time.hour * 60 + time.minute;
  // Convert slot start/end strings to minutes & compare
  return nowMinutes >= startMin && nowMinutes < endMin;
}
```

---

## 🚀 Setup & Cloud Compilation

### Local Development Setup
Run the following inside the `timetable_app/` directory:
```bash
flutter pub get                  # Resolves dependencies
flutter run -d chrome            # Boots Web CanvasKit preview
flutter run                      # Compiles to native target (Android/iOS)
```

### Cloud Compilation via Vercel Pipeline
Deployments are automated through a Vercel-compatible shell pipeline:
- `vercel.json` maps Vercel builders to trigger [build-vercel.sh](file:///C:/Users/rissh/OneDrive/Documents/AntiGravity/timetable_app/build-vercel.sh)
- The shell script builds the application using the **CanvasKit renderer** (`flutter build web --release --web-renderer canvaskit`) to guarantee high-performance anti-aliasing and pixel-perfect drawing of the Apple design system elements.
