# 🍅 Pomodori
A simple Pomodoro App for Mac

## Prerequisites

- macOS 13 (Ventura) or later
- Swift 5.9+ (included with Xcode 15+)

## Build & Run

### Using Swift Package Manager (command line)

Build:
```sh
swift build
```

Run:
```sh
swift run
```

The app runs as a menu bar item — look for the 🍅 icon in your macOS menu bar.

### Using Xcode

1. Open the project: `open Package.swift`
2. Select the `Pomodori` scheme and a "My Mac" destination
3. Press **Cmd+R** to build and run

## Usage

Click the 🍅 icon in the menu bar to:

- **Start/Pause/Resume** a 25-minute work session
- **Reset** the current timer
- **Skip** to the next session (work or break)
- **Quit** the app

When a session ends you'll get a macOS notification and a beep sound. The app alternates between 25-minute work sessions and 5-minute breaks.
