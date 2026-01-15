ZenMonitor 

 🧊 Overview

ZenMonitor is a lightweight, native macOS menu bar agent designed to replace heavy activity monitoring suites. Built with Swift 6 and SwiftUI, it offers a distraction-free interface to monitor system performance and manage resources without the overhead of Electron-based apps.

The tool implements a dual-metric system, allowing users to switch between Unix Core Sum (raw CPU usage) and Global System Load (normalized 0-100%), ensuring accurate data interpretation regardless of core count.

 ✨ Key Features

* Real-Time Monitoring: Updates every 2 seconds with negligible footprint.
* Dual Metrics Strategy:
    * *System Load:* Normalized percentage relative to total machine power (Best for general health).
    * *Unix Core Sum:* Raw usage where 100% = 1 full core (Best for debugging specific processes).
* Process Management: Instantly `kill -9` greedy processes directly from the menu.
* Safety First: Automatic filtering of critical system processes (`kernel_task`, `WindowServer`) to prevent accidental system instability.
* Adaptive "Zen" UI: A custom Earth-Tone color logic that adapts to system stress:
    * 🟢 < 10% (Crème): Idle / Zen
    * 🟠 10-50% (Beige): Moderate Load
    * 🔴 > 50% (Marron): Heavy Load

 🛠 Tech Stack

* Language: Swift 6
* Framework: SwiftUI
* Architecture: MVVM with `@Observable` macro.
* Concurrency: Strict concurrency checks using `async/await`, `Task`, and `@MainActor` to ensure thread safety and non-blocking UI.
* System Integration:
    * Agent (LSUIElement): Runs as a background utility without a Dock icon.
    * Shell Integration: Wraps Foundation's `Process()` to interface with `/bin/ps` and `/bin/kill` commands, bypassing standard sandbox limitations for process management.

 🚀 Installation & Build

 Prerequisites
* Xcode 16+
* macOS 15 (Sequoia) or later

 Build from Source
1.  Clone the repository:
    ```bash
    git clone [https://github.com/your-username/zenmonitor.git](https://github.com/your-username/zenmonitor.git)
    ```
2.  Open `ZenMonitor.xcodeproj` in Xcode.
3.  Important: Ensure "App Sandbox" is disabled in the *Signing & Capabilities* tab (Required for process killing).
4.  Build and Run (`Cmd + R`).

To install permanently, Archive the project and move the resulting `.app` to your `/Applications` folder.

 🧠 Engineering Decisions

 Why Non-Sandboxed?
ZenMonitor requires the ability to terminate other running processes (`kill -9`). The standard App Sandbox prevents interaction with processes outside the application's bundle. This app is designed as a developer tool to be side-loaded, prioritizing functionality over App Store distribution constraints.

 Swift 6 Concurrency
The application relies on `ProcessManager`, an `@Observable` actor-isolated class. Data fetching (`ps` command execution and parsing) is offloaded to background threads using `Task`, preventing the "beachball" effect on the UI, while UI updates are strictly marshaled back to the `@MainActor`.

 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
