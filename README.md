# ToDoList

A iOS to-do list app built with **SwiftUI**, **UIKit**, **React Native**, and **Firebase**.

## Requirements

- Xcode 16.2+
- iOS 16.0+
- Node.js 18+
- A Firebase project with **Authentication** (Email/Password) and **Firestore** enabled

## How to Run

1. Clone the repository
2. Install JS dependencies from the repo root:
   ```bash
   npm install
   ```
3. Copy `ios/ToDoList/Other/GoogleService-Info.plist.example` to `ios/ToDoList/Other/GoogleService-Info.plist` and fill in your Firebase credentials from the [Firebase Console](https://console.firebase.google.com/)
4. Copy `.env.example` to `.env` and fill in the same Firebase values for the React Native layer:
   ```bash
   cp .env.example .env
   ```
5. In the Firebase Console, enable **Email/Password** sign-in under Authentication
6. Install iOS pods:
   ```bash
   cd ios && pod install
   ```
7. Open **`ios/ToDoList.xcworkspace`** in Xcode (not `.xcodeproj`)
8. Start the Metro bundler:
   ```bash
   npx react-native start
   ```
9. Build and run on a simulator or device (Cmd+R)

> **Note:** `GoogleService-Info.plist` and `.env` are in `.gitignore` and are not included in the repository. Both are required — copy their `.example` counterparts and fill in your Firebase project values.

## Features

### Authentication
- **Register** — create an account with name, email, and password (stored in Firebase Auth + Firestore)
- **Login** — sign in with email and password
- **Logout** — sign out from the Profile screen
- Input validation and error messages for both login and registration

### To-Do List (React Native screen)
- **View todos** — real-time list via Firestore `onSnapshot`
- **Toggle done** — tap a row to toggle completion, optimistic update with rollback on failure
- **Add new item** — tap the + button to open the native Swift creation sheet

### Profile
- View user name, email, and join date
- Error handling with retry on load failure
- Log out

### Settings (UIKit)
- **Appearance** — switch between System, Light, and Dark mode
- Preference is persisted across app launches via UserDefaults
- Built with UIKit (UITableViewController), bridged into SwiftUI via UIViewControllerRepresentable

## Tech Stack

- **SwiftUI** — Auth, Main, Profile, Settings screens
- **UIKit** — Settings screen + React Native host view controller
- **React Native 0.84** (New Architecture) — Todos list screen
- **Firebase Auth** — authentication
- **Firebase Firestore** — data storage and real-time sync (native SDK for Swift, JS SDK for React Native)
- **VIPER** — architecture pattern for Swift modules

## Architecture

### Swift — VIPER

All Swift screens follow the **VIPER** pattern. Each feature is an independent module:

| Layer | Responsibility |
|-------|----------------|
| **View** | Pure UI. Reads state from the Presenter, forwards user actions to it. |
| **Interactor** | Use cases and data access. All Firebase/Auth/UserDefaults calls live here. |
| **Presenter** | Orchestrator. Owns observable state, validates input, calls Interactor, drives navigation. |
| **Entity** | Plain data models (`User`, `ToDoListItem`). No logic. |
| **Router** | Assembles the module and owns navigation to other modules. |

```
View  ──calls──▶  Presenter  ──calls──▶  Interactor
 ▲                    ▲                       │
 │                    └───────callbacks────────┘
 └──binds to @Published state
```

### React Native integration

The Todos screen is fully React Native, embedded inside a native `UIViewController`. The integration uses **RN 0.84 New Architecture** (Fabric + TurboModules + Bridgeless — always on in 0.84):

```
RNFactoryDelegate            ← provides Hermes JS runtime + bundle URL
  └── RCTReactNativeFactory  ← wires delegate, sets up feature flags
        └── RCTRootViewFactory.view(withModuleName:)  ← returns UIView
              └── TodosRNViewController  ← embeds the view full-screen
```

The **+** button in RN calls a native module (`TodosNativeModule`) which posts an `NSNotificationCenter` event. `TodosRNViewController` catches it and presents the Swift `NewItemView` as a page sheet.

## Project Structure

```
ToDoList/                         ← repo root
├── index.js                      RN entry point — AppRegistry.registerComponent
├── src/
│   ├── screens/
│   │   └── TodosScreen/          Todos list screen
│   │       ├── TodosScreen.tsx   Firestore listener + toggle logic
│   │       ├── styles.ts         Screen-level styles
│   │       └── index.ts
│   ├── components/
│   │   ├── TodoItem/             Single todo row
│   │   ├── EmptyState/           Empty list placeholder
│   │   └── AddButton/            FAB — calls native module to open NewItem
│   ├── config/firebase.ts        Firebase JS SDK init (reads from .env via react-native-dotenv)
│   ├── env.d.ts                  TypeScript declarations for @env module
│   ├── constants/colors.ts       Shared colour palette
│   ├── types/todo.ts             TodoItem interface
│   └── utils/date.ts             Date formatting helper
├── .env                          Firebase config secrets — gitignored, copy from .env.example
├── .env.example                  Template: copy to .env and fill in values
└── ios/
    └── ToDoList/
        ├── Entities/             User, ToDoListItem (Codable structs)
        ├── Modules/
        │   ├── Main/             Auth gate + tab bar
        │   ├── Auth/Login/       Login screen
        │   ├── Auth/Register/    Registration screen
        │   ├── TodoList/         RN host + native module
        │   │   ├── TodoListRouter.swift        Entry point (called by Main)
        │   │   ├── TodosRNViewController.swift  UIViewController hosting RN view
        │   │   ├── TodosNativeModule.m          Exposes openNewItem() to RN
        │   │   └── _Deprecated/                Old Swift VIPER files (superseded by RN)
        │   ├── NewItem/          New todo sheet (Swift)
        │   ├── Profile/          User profile screen
        │   └── Settings/         Appearance settings (UIKit)
        ├── Shared/               Reusable components + extensions
        └── Other/                App entry, RNBridge, assets, Firebase plist
```
