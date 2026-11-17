<div align="center">

  <img src="assets/icon/app_icon.jpg" alt="Attendify Logo" width="120" style="border-radius: 24px;" />

  # 🎓 Attendify

  **Smart Attendance Tracker & Future Prediction Engine for Students**

  [![Flutter](https://img.shields.io/badge/Flutter-3.13+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
  [![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
  [![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-4CAF50)](#platform-support)
  [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
  [![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

  *Track subjects, eliminate shortage anxiety, and make informed decisions with real-time future attendance prediction and interactive simulation.*

</div>

---

## 📖 Overview

**Attendify** is a modern, student-first attendance tracker built with Flutter and Dart. Going beyond simple percentage counters, Attendify is equipped with a predictive mathematics engine that answers the critical questions every student faces:

- *"How many classes can I safely miss without dropping below my required attendance?"*
- *"If I'm in shortage, exactly how many consecutive classes must I attend to recover?"*
- *"What will my attendance percentage become if I attend the next 5 classes?"*

Featuring a minimal Material 3 card interface, 1-tap logging, offline persistence, and daylight/OLED dark themes, Attendify keeps students confident and on track throughout the semester.

---

## ✨ Features

- **📊 Comprehensive Student Dashboard**:
  - Clean card interface with rounded corners and distinct subject identity badges.
  - Overall attendance overview with circular radial gauge, breakdown counts, and health status.
  - Quick status filter tabs (**All**, **Safe**, **Warning**, **Shortage**) and instantaneous search.

- **🟢 Intuitive Visual Color Indicators**:
  - **Green (Safe)**: $\ge$ Target requirement (Default: $\ge 75\%$).
  - **Yellow (Warning)**: Attendance within 5% below target ($70\% - 74.9\%$).
  - **Red (Shortage / Danger)**: Attendance $< 70\%$ requiring immediate recovery.

- **🔮 Predictive Attendance Engine**:
  - **Safe Bunk Calculator**: Calculates the exact number of future classes you can miss while staying above your minimum requirement.
  - **Shortage Recovery Tracker**: Calculates the exact number of consecutive classes required to restore attendance above target.
  - **"What-If" Simulator**: Interactive slider ($1$ to $30$ classes) and quick chips (+1, +3, +5, +10, +15) comparing attendance if attended vs. if missed.

- **⚡ 1-Tap Attendance Logging**:
  - Direct `+ Attended` and `+ Missed` buttons on each subject card.
  - Built-in Undo action from the card options menu.

- **🛠️ Subject Customization (CRUD)**:
  - Add, edit, and delete subjects with real-time validation.
  - Optional custom subject-level attendance target override.
  - Color palette selection per subject.

- **💾 Offline-First Local Persistence**:
  - Powered by `shared_preferences` with instant auto-save.
  - Data persists across app restarts without requiring cloud connectivity.

- **🌗 Adaptive Theming**:
  - Light mode, OLED-friendly Dark mode, and System default with instant toggle.

---

## 📸 Screenshots

| Dashboard (Light) | Dashboard (Dark) | What-If Simulator |
| :---: | :---: | :---: |
| ![Dashboard Light](https://via.placeholder.com/300x600/FFFFFF/10B981?text=Dashboard+Light+View) | ![Dashboard Dark](https://via.placeholder.com/300x600/0F172A/10B981?text=Dashboard+Dark+View) | ![Simulator](https://via.placeholder.com/300x600/1E293B/6366F1?text=What-If+Simulator) |

| Add Subject Modal | Safe Bunk Advice | Overall Summary |
| :---: | :---: | :---: |
| ![Add Subject](https://via.placeholder.com/300x600/FFFFFF/4F46E5?text=Add+Subject+Modal) | ![Advice](https://via.placeholder.com/300x600/0F172A/EF4444?text=Recovery+Advice) | ![Summary](https://via.placeholder.com/300x600/FFFFFF/0EA5E9?text=Overall+Summary) |

> *Tip: Replace placeholder URLs with actual app screenshots from your device.*

---

## 🧮 Mathematical Methodology & Formulas

Let:
- $T$: Total classes conducted to date ($T \ge 0$)
- $A$: Attended classes ($0 \le A \le T$)
- $M$: Missed classes ($M = T - A$)
- $R$: Target minimum attendance threshold as a decimal ($0 < R \le 1.0$, default $0.75$)
- $P$: Current attendance percentage ($P = \frac{A}{T} \times 100\%$)

### 1. Basic Attendance Percentage
$$P = \frac{A}{T} \times 100\%$$
*(Handled gracefully as $100\%$ when $T = 0$)*

### 2. Permissible Missed Classes (Safe Bunking)
When $P \ge R \times 100$, find maximum upcoming classes $m$ that can be missed before falling below $R$:
$$\frac{A}{T + m} \ge R \implies m \le \frac{A - R \cdot T}{R} = \frac{A}{R} - T$$
$$m_{\max} = \max\left(0, \left\lfloor \frac{A}{R} - T \right\rfloor\right)$$

*Example:* $T = 40, A = 32, R = 0.75$:
$$m_{\max} = \left\lfloor \frac{32}{0.75} - 40 \right\rfloor = \lfloor 42.66 - 40 \rfloor = \mathbf{2\text{ classes}}$$
- Missing 2 classes: $\frac{32}{42} = 76.19\% \ge 75\%$ (Safe)
- Missing 3 classes: $\frac{32}{43} = 74.41\% < 75\%$ (Violated)

### 3. Consecutive Classes Required to Recover Shortage
When $P < R \times 100$, find minimum consecutive classes $c$ that must be attended to reach $R$:
$$\frac{A + c}{T + c} \ge R \implies c(1 - R) \ge R \cdot T - A \implies c \ge \frac{R \cdot T - A}{1 - R}$$
$$c_{\min} = \left\lceil \frac{R \cdot T - A}{1 - R} \right\rceil$$

*Example:* $T = 20, A = 12$ ($60\%$), $R = 0.75$:
$$c_{\min} = \left\lceil \frac{0.75 \times 20 - 12}{1 - 0.75} \right\rceil = \left\lceil \frac{15 - 12}{0.25} \right\rceil = \left\lceil \frac{3}{0.25} \right\rceil = \mathbf{12\text{ consecutive classes}}$$
After attending 12 classes: $\frac{12 + 12}{20 + 12} = \frac{24}{32} = 75.0\%$ (Target recovered).

### 4. Future Projection After $N$ Classes
- **If student attends next $N$ classes**:
  $$P_{+\text{attend } N} = \frac{A + N}{T + N} \times 100\%$$
- **If student misses next $N$ classes**:
  $$P_{+\text{miss } N} = \frac{A}{T + N} \times 100\%$$

---

## 💻 Tech Stack

- **Framework**: [Flutter](https://flutter.dev) (v3.13+)
- **Language**: [Dart](https://dart.dev) (v3.0+)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Local Persistence**: [shared_preferences](https://pub.dev/packages/shared_preferences)
- **Design System**: Material Design 3 (M3)
- **Icons & Assets**: [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons), Cupertino Icons, Material Icons

---

## 🚀 Getting Started & Installation

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed on your system.
- An editor such as [VS Code](https://code.visualstudio.com) or [Android Studio](https://developer.android.com/studio).
- An Android device, iOS simulator, or Google Chrome for web testing.

### Installation Steps

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-username/attendify.git
   cd attendify
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Verify setup**:
   ```bash
   flutter doctor
   ```

4. **Run the application**:
   ```bash
   # Run on connected phone / emulator
   flutter run

   # Or run on Google Chrome (Web)
   flutter run -d chrome

   # Or run on Windows desktop
   flutter run -d windows
   ```

5. **Run tests**:
   ```bash
   flutter test
   ```

---

## 🏗️ Project Architecture

```
attendify/
├── lib/
│   ├── main.dart                          # App bootstrap & MultiProvider
│   ├── models/
│   │   └── subject.dart                   # Subject data model & serialization
│   ├── providers/
│   │   ├── attendance_provider.dart       # State management & reactive stats
│   │   └── theme_provider.dart            # Light / Dark / System theme state
│   ├── services/
│   │   └── storage_service.dart           # Local storage persistence
│   ├── utils/
│   │   ├── app_theme.dart                 # Color palette & Material 3 themes
│   │   └── attendance_calculator.dart     # Pure mathematical prediction routines
│   ├── widgets/
│   │   ├── overall_summary_card.dart      # Hero card with radial meter & stats
│   │   ├── subject_card.dart              # Subject card with quick +1 actions
│   │   ├── prediction_sheet.dart          # What-If simulator modal
│   │   ├── subject_dialog.dart            # Add/Edit subject bottom sheet
│   │   └── empty_state_view.dart          # Empty & search states
│   └── screens/
│       ├── dashboard_screen.dart          # Primary student dashboard
│       └── settings_screen.dart           # Minimum requirement & formulas
├── test/
│   ├── attendance_calculator_test.dart    # Mathematical formula unit tests
│   └── widget_test.dart                   # UI & state integration tests
└── pubspec.yaml                           # Dependencies & metadata
```

---

## 🤝 Contributing

Contributions, issues, and feature suggestions are always welcome!
Feel free to open an issue or submit a pull request.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
