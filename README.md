# ToDoList

A simple iOS to-do list app built with **SwiftUI**, **UIKit**, and **Firebase**.

## Requirements

- Xcode 16.2+
- iOS 16.0+
- A Firebase project with **Authentication** (Email/Password) and **Firestore** enabled

## How to Run

1. Clone the repository
2. Open `ToDoList.xcodeproj` in Xcode
3. Xcode will automatically resolve the Firebase SDK dependency via Swift Package Manager
4. Copy `ToDoList/Other/GoogleService-Info.plist.example` to `ToDoList/Other/GoogleService-Info.plist` and fill in your own Firebase credentials from the [Firebase Console](https://console.firebase.google.com/)
5. In the Firebase Console, enable **Email/Password** sign-in under Authentication
6. Build and run on a simulator or device (Cmd+R)

> **Note:** `GoogleService-Info.plist` is in `.gitignore` and is not included in the repository. You must provide your own.

## Features

### Authentication
- **Register** — create an account with name, email, and password (stored in Firebase Auth + Firestore)
- **Login** — sign in with email and password
- **Logout** — sign out from the Profile screen
- Input validation and error messages for both login and registration

### To-Do List
- **View todos** — real-time list powered by a Firestore snapshot listener
- **Add new item** — title and due date with validation
- **Mark as done** — toggle completion status
- **Delete** — swipe to delete

### Profile
- View user name, email, and join date
- Error handling with retry on load failure
- Log out

### Settings (UIKit)
- **Appearance** — switch between System, Light, and Dark mode
- Preference is persisted across app launches via UserDefaults
- Built with UIKit (UITableViewController), bridged into SwiftUI via UIViewControllerRepresentable

## Tech Stack

- **SwiftUI** — all screens except Settings
- **UIKit** — Settings screen (demonstrating UIKit in a SwiftUI app)
- **Firebase Auth** — authentication
- **Firebase Firestore** — data storage and real-time sync
- **VIPER** — architecture pattern used throughout

## Architecture

The app follows the **VIPER** architecture pattern. Each feature is an independent module with five layers:

| Layer | Responsibility |
|-------|----------------|
| **View** | Pure UI. Reads state from the Presenter, forwards user actions to it. No business logic. |
| **Interactor** | Use cases and data access. All Firebase/Auth/UserDefaults calls live here. Reports results back to the Presenter via an Output protocol. |
| **Presenter** | Orchestrator. Owns the observable state the View binds to. Validates input, calls the Interactor, reacts to its callbacks, and tells the Router when to navigate. |
| **Entity** | Plain data models (`User`, `ToDoListItem`). No logic. |
| **Router** | Assembles the module (wires Interactor → Presenter → View) and owns navigation to other modules. |

### Module communication

```
View  ──calls──▶  Presenter  ──calls──▶  Interactor
 ▲                    ▲                       │
 │                    └───────callbacks────────┘
 └──binds to @Published state
```

The Router is the only layer that knows about other modules. Every other layer communicates only with its direct neighbour, always via a protocol — making each layer independently testable.

### Settings (UIKit VIPER)

Because Settings uses `UITableViewController` instead of SwiftUI, it uses the classic UIKit VIPER delegate pattern:
- Presenter holds a `weak var view: SettingsViewProtocol?`
- View conforms to `SettingsViewProtocol` and calls Presenter methods for user actions
- Presenter calls `view?.reloadData()` when state changes

## Project Structure

```
ToDoList/
├── Entities/                    Shared data models (User, ToDoListItem)
├── Modules/
│   ├── Main/                    Root module — auth gate + tab bar
│   │   ├── MainInteractor.swift
│   │   ├── MainPresenter.swift
│   │   ├── MainRouter.swift
│   │   └── MainView.swift
│   ├── Auth/
│   │   ├── Login/               Login module
│   │   └── Register/            Register module
│   ├── TodoList/                Todo list module (real-time Firestore listener)
│   ├── NewItem/                 New item sheet module
│   ├── Profile/                 Profile module
│   └── Settings/                Settings module (UIKit + SwiftUI bridge)
├── Shared/
│   ├── Components/              Reusable UI (HeaderView, TLButton, ToDoListItemView)
│   └── Extensions/              Swift extensions (Encodable+asDictionary)
└── Other/                       App entry point, assets, launch screen
```
