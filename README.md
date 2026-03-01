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
- **View todos** — real-time list powered by Firestore
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
- Built with UIKit (UITableViewController) using MVVM, bridged into SwiftUI via UIViewControllerRepresentable

## Tech Stack

- **SwiftUI** — all screens except Settings
- **UIKit** — Settings screen (demonstrating UIKit + MVVM in a SwiftUI app)
- **Firebase Auth** — authentication
- **Firebase Firestore** — data storage and real-time sync
- **MVVM** — architecture pattern used throughout

## Project Structure

```
ToDoList/
├── Models/              Data models (User, ToDoListItem)
├── ViewModels/
│   ├── Auth/            Login & Register view models
│   ├── Todo/            List, item, and new item view models
│   ├── Profile/         Profile view model
│   ├── Settings/        Settings view model (theme persistence)
│   └── Main/            Main view model (auth state)
├── Views/
│   ├── Screens/
│   │   ├── Auth/        Login & Register screens
│   │   ├── Todo/        To-do list & new item screens
│   │   ├── Profile/     Profile screen
│   │   ├── Settings/    Settings screen (UIKit + SwiftUI bridge)
│   │   └── Main/        Root view (auth gate + tabs)
│   └── Components/      Reusable UI (HeaderView, TLButton, ToDoListItemView)
└── Other/               App entry point, extensions, assets, launch screen
```
