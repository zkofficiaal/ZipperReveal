<img width="394" height="784" alt="Screenshot 2026-09-12 at 9 30 54 PM" src="https://github.com/user-attachments/assets/6aa87385-d2d9-4e50-a1d6-a8ad78b16c12" />
<img width="392" height="779" alt="Screenshot 2026-09-12 at 9 31 38 PM" src="https://github.com/user-attachments/assets/ba26995d-3b51-449e-b6f8-04a64b48cd72" />


# ZipperReveal 

A smooth, interactive **zipper reveal animation** built with **SwiftUI**. The project recreates a physical zipper-opening effect where the user can drag the zipper vertically to reveal content underneath.

## Features

* Interactive zipper opening and closing
* Gesture-driven drag interaction
* Drag down to open and drag up to close
* V-shaped zipper opening
* Dynamic zipper teeth that follow the opening
* Smooth zipper slider movement
* Phone-style content reveal
* Fully custom zipper rendering using SwiftUI `Canvas`
* Smooth progress-based animation
* Clean separation of Models, Views, ViewModel, Services, and Utilities
* No force unwraps
* Reset functionality

## Technologies

* **Swift**
* **SwiftUI**
* **Combine**
* **MVVM-inspired architecture**

## Project Structure

```text
ZipperReveal/
├── Models/
│   ├── ZipperConfiguration.swift
│   └── ZipperPhase.swift
│
├── Services/
│   └── ZipperAnimationService.swift
│
├── Utilities/
│   └── ZipperGeometry.swift
│
├── ViewModels/
│   └── ZipperRevealViewModel.swift
│
├── Views/
│   ├── PhoneContentView.swift
│   ├── ZipperCanvasView.swift
│   └── ZipperRevealView.swift
│
└── ZipperRevealApp.swift
```

## How It Works

The zipper is controlled through a normalized `progress` value:

```text
0.0 ──────────────── 1.0
Closed               Open
```

The user's vertical drag is converted into this progress value. The progress then controls:

* Zipper slider position
* V-shaped opening
* Fabric separation
* Zipper teeth positions
* Opening edges
* Zipper visibility
* Revealed phone content

### Interaction

| Gesture   | Action                 |
| --------- | ---------------------- |
| Drag Down | Open zipper            |
| Drag Up   | Close zipper           |
| Release   | Keep current position  |
| Reset     | Return to closed state |

## Architecture

The project separates responsibilities to keep the animation maintainable:

**`ZipperRevealViewModel`**
Manages gesture state and zipper progress.

**`ZipperGeometry`**
Handles all calculations for zipper positions, rails, teeth, slider, and opening geometry.

**`ZipperCanvasView`**
Renders the zipper using SwiftUI `Canvas`.

**`PhoneContentView`**
Displays the content underneath the zipper.

**`ZipperConfiguration`**
Contains centralized values for animation timing, dimensions, teeth, slider, fabric, and phone sizing.

**`ZipperAnimationService`**
Provides animation-related functionality.

## Purpose

This project is primarily a **SwiftUI animation and interaction experiment**, demonstrating how complex UI effects can be built using:

* Custom drawing
* Geometry calculations
* Gesture-driven state
* Continuous animation progress
* Layered SwiftUI views
* Reusable configuration

## Getting Started

1. Clone the repository.
2. Open the project in **Xcode**.
3. Select an iOS simulator or device.
4. Build and run.
5. Drag the zipper to reveal the content.

## Learning Focus

This project demonstrates practical SwiftUI concepts such as:

* `GeometryReader`
* `Canvas`
* `GraphicsContext`
* `DragGesture`
* `@Published`
* `ObservableObject`
* `@MainActor`
* Custom `Path` drawing
* Coordinate calculations
* Progress-based animations
* MVVM-style separation

## Designed and Developed by:

**Muhammad Zahid Khan — Z.K **

Built as a SwiftUI animation project focused on creating a realistic, interactive zipper reveal experience.
