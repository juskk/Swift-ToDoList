# React Native Integration in ToDoList (iOS)

This document covers three things:

1. **How the integration works** — the architectural overview, the core API chain, and every critical file involved
2. **The TodosScreen module** — a walkthrough of every file in the RN layer and what it does
3. **Step-by-step guide** — how to add a React Native screen to any existing Swift iOS app from scratch

---

## Part 1: How the Integration Works

### The big picture

The app is a hybrid: all screens are Swift/SwiftUI with VIPER architecture, except the Todos list screen which is React Native. The RN screen is embedded inside a native `UIViewController` and communicates back to Swift via a native module and `NSNotificationCenter`.

```
SwiftUI App
  └── TabView
        └── TodoList tab
              └── TodosRNViewController  (UIViewController)
                    └── RN UIView  ←  "TodosScreen" component
                          └── AddButton (RN)
                                └── TodosNativeModule (ObjC)
                                      └── NSNotificationCenter
                                            └── TodosRNViewController
                                                  └── NewItemView (Swift sheet)
```

Firebase is accessed from two places independently: the Swift SDK handles auth and the NewItem creation sheet, and the Firebase **JS SDK** handles real-time data in the RN screen. Both talk to the same Firestore project.

---

### Why the old approach crashed

React Native 0.84 has the **New Architecture hardcoded ON**. The file `node_modules/react-native/scripts/react_native_pods.rb` defines `new_arch_enabled` as a function that returns `true` unconditionally — there is no environment variable or flag that disables it.

The classes we were originally using — `RCTBridge` and `RCTRootView` — are dead stubs in 0.84. Their initializers allocate memory but produce objects with a corrupt `isa` pointer. Calling `addSubview` on the returned view triggered `EXC_BAD_ACCESS` every single time.

Setting `ENV['RCT_NEW_ARCH_ENABLED'] = '0'` in the Podfile had no effect. Setting `ENV['RCT_REMOVE_LEGACY_ARCH'] = '0'` kept the legacy class symbols compiled in, but the objects were still broken internally because the New Architecture code path runs inside them regardless.

---

### The correct API chain

The fix was to replace the entire `RCTBridge`/`RCTRootView` approach with the RN 0.84 New Architecture API:

```
RCTDefaultReactNativeFactoryDelegate
  └── RCTReactNativeFactory(delegate:)
        └── factory.rootViewFactory.view(withModuleName:initialProperties:)
              └── embed UIView in UIViewController
```

**Why each layer matters:**

- `RCTDefaultReactNativeFactoryDelegate` — base class that provides `createJSRuntimeFactory` (Hermes engine), turbo module wiring, and Fabric setup. Without it you get a crash: *"Delegate must implement a valid createJSRuntimeFactory method"*.
- `RCTReactNativeFactory(delegate:)` — takes the delegate, sets `configuration.jsRuntimeConfiguratorDelegate = self` (line 337 of `RCTReactNativeFactory.mm`), and creates `RCTRootViewFactory` internally. This is what wires the Hermes runtime into the view factory.
- `factory.rootViewFactory.view(withModuleName:initialProperties:)` — returns a fully initialised UIView that can be safely added to the view hierarchy.

**Why the factory delegate must be kept alive:** `RCTReactNativeFactory` holds the delegate with a `weak` reference. If the delegate is created as a local variable and goes out of scope, the factory crashes. We hold both the delegate and the factory as strong `private var` properties in the `RNBridge` singleton.

---

### Core files (Swift side)

#### `ios/ToDoList/Other/RNBridge.swift`

The single entry point for all React Native setup. Contains two classes:

**`RNFactoryDelegate`** — subclass of `RCTDefaultReactNativeFactoryDelegate`. Overrides only `bundleURL()`: returns the Metro dev server URL in debug builds, or the bundled `.jsbundle` in release. Inherits the Hermes runtime factory and all default wiring from the base class.

**`RNBridge`** — a singleton. Holds strong references to both the delegate and the `RCTReactNativeFactory` (so neither is prematurely deallocated). Exposes two methods:
- `setup()` — called once at app launch. Creates the delegate, attaches `RCTAppDependencyProvider` (the auto-generated Codegen registry for turbo modules and Fabric components), creates the factory.
- `createView(moduleName:initialProperties:)` — called by the view controller to instantiate the RN UIView.

Required Swift imports:
- `import React` — `RCTBundleURLProvider`
- `import React_RCTAppDelegate` — `RCTReactNativeFactory`, `RCTDefaultReactNativeFactoryDelegate`, `RCTRootViewFactory`
- `import ReactAppDependencyProvider` — `RCTAppDependencyProvider` (auto-generated, registers turbo modules + Fabric components)

#### `ios/ToDoList/Other/AppDelegate.swift`

A minimal `UIApplicationDelegate` that calls `RNBridge.shared.setup()` in `didFinishLaunchingWithOptions`. Connected to the SwiftUI app entry point via `@UIApplicationDelegateAdaptor(AppDelegate.self)` in `ToDoListApp.swift`. Calling `setup()` here ensures the JS runtime and bundle are fully loaded before any screen tries to embed an RN view.

#### `ios/ToDoList/Modules/TodoList/TodosRNViewController.swift`

The UIViewController that hosts the RN view. In `viewDidLoad` it calls `RNBridge.shared.createView("TodosScreen", initialProperties: ["userId": userId])` and pins the returned `UIView` to all four edges with Auto Layout constraints.

It also registers an `NSNotificationCenter` observer for `"TodosOpenNewItem"`. When that notification fires (posted by the ObjC native module), it presents `NewItemRouter.createModule()` wrapped in a `UIHostingController` as a `.pageSheet`.

The file also contains `TodosRNView`, a `UIViewControllerRepresentable` wrapper so the VIPER router can instantiate and return the VC as a SwiftUI view.

#### `ios/ToDoList/Modules/TodoList/TodosNativeModule.m`

An ObjC file that exports a native module to React Native using `RCT_EXPORT_MODULE()`. The single exported method `openNewItem` dispatches back to the main queue and posts the `"TodosOpenNewItem"` notification. The module name in JS is `NativeModules.TodosNativeModule` — it matches the class name because `RCT_EXPORT_MODULE()` with no arguments uses the class name directly.

This pattern works in both old and new architecture via the interop layer — no TurboModule spec file is needed for simple methods.

---

### Firebase config and secrets

The Firebase JS SDK is initialised in `src/config/firebase.ts`. Rather than hardcoding the API key, values are loaded from a `.env` file at Metro bundle time using `react-native-dotenv` (a Babel plugin):

```
.env  →  babel-plugin (react-native-dotenv)  →  @env  →  firebase.ts
```

The `.env` file is in `.gitignore`. Anyone cloning the repo copies `.env.example` to `.env` and fills in their Firebase project values. TypeScript declarations for the `@env` module live in `src/env.d.ts`.

---

### Data flow (app startup to screen render)

```
1. ToDoListApp.init()
   └── FirebaseApp.configure()   (native Swift SDK)

2. @UIApplicationDelegateAdaptor → AppDelegate.didFinishLaunchingWithOptions
   └── RNBridge.shared.setup()   (JS runtime + bundle load begins)

3. Firebase Auth resolves → user signed in → TabView appears

4. Home tab → TodoListRouter.createModule(userId:) → TodosRNView(userId:)
   └── TodosRNViewController.viewDidLoad
         └── RNBridge.shared.createView("TodosScreen", ["userId": userId])
               └── RN renders <TodosScreen userId="..."> component
                     └── onSnapshot listener subscribes to Firestore
```

---

## Part 2: The TodosScreen Module

### iOS-side files (`ios/ToDoList/Modules/TodoList/`)

| File | What it does |
|---|---|
| `TodoListRouter.swift` | VIPER router. Creates `TodosRNView(userId:)` and returns it as a SwiftUI view. The only entry point called by the Main module. |
| `TodosRNViewController.swift` | Hosts the RN UIView. Handles the `"TodosOpenNewItem"` notification to present the NewItem sheet. Also contains the `UIViewControllerRepresentable` wrapper. |
| `TodosNativeModule.m` | ObjC native module. Exposes `openNewItem()` to JS. Posts `NSNotificationCenter` event on the main queue. |
| `_Deprecated/` | Old Swift VIPER files (`TodoListView.swift`, `TodoListInteractor.swift`, `TodoListPresenter.swift`) superseded by the RN screen. Kept for reference, not compiled into the app in a meaningful way. |

### JS-side files

#### Entry point

**`index.js`** (repo root) — registers the component with React Native's runtime:
```js
AppRegistry.registerComponent('TodosScreen', () => TodosScreen);
```
The string `'TodosScreen'` must match the `moduleName` passed to `createView` in Swift. If you ever add a second RN screen, call `AppRegistry.registerComponent` again with a new string and a new module name.

#### Screen (`src/screens/TodosScreen/`)

| File | What it does |
|---|---|
| `TodosScreen.tsx` | The root component. Subscribes to Firestore with `onSnapshot` for real-time updates. Implements optimistic toggle: updates local state immediately, then writes to Firestore, rolling back on failure. Renders `TodoItem`, `EmptyState`, and `AddButton`. Receives `userId` as a prop from Swift. |
| `styles.ts` | All StyleSheet definitions for the screen layout (container, list, header, etc.). |
| `index.ts` | Barrel re-export: `export { TodosScreen } from './TodosScreen'`. |

#### Components (`src/components/`)

Each component lives in its own folder following the same pattern: `ComponentName.tsx`, `styles.ts`, `index.ts`. A root `src/components/index.ts` re-exports all three.

| Component | What it does |
|---|---|
| `TodoItem` | Renders a single todo row: checkbox, title, optional due date. Calls `onToggle(id)` on tap. Uses `formatDueDate` from utils for the date label. |
| `EmptyState` | Placeholder shown when the todo list is empty. Just an icon and a message. |
| `AddButton` | Floating action button (FAB) fixed to the bottom-right. On press, calls `NativeModules.TodosNativeModule.openNewItem()`. No JS navigation involved — control passes entirely to Swift. |

#### Shared utilities (`src/`)

| File | What it does |
|---|---|
| `config/firebase.ts` | Initialises the Firebase JS SDK once (guarded against Fast Refresh re-runs). Reads config from `.env` via `@env`. Exports `db` (Firestore instance). |
| `env.d.ts` | TypeScript module declaration for `@env` so the IDE resolves `import { FIREBASE_API_KEY } from '@env'` without errors. |
| `constants/colors.ts` | Shared colour palette referenced by all component style files. |
| `types/todo.ts` | `TodoItem` interface: `id`, `title`, `isDone`, optional `dueDate` (Unix timestamp). Matches the Swift `ToDoListItem` struct fields. |
| `utils/date.ts` | `formatDueDate(timestamp: number): string` — converts a Unix timestamp to a human-readable string. |

---

## Part 3: Adding a React Native Screen to a Swift iOS App

A complete step-by-step guide for **React Native 0.84+** with the New Architecture. Assumes you have an existing Swift/SwiftUI app using CocoaPods.

---

### Step 1 — Initialise the JS project at the repo root

Run these from the folder that contains your `ios/` directory:

```bash
npm init -y
npm install react-native
npm install --save-exact react@$(node -p "require('./node_modules/react-native/package.json').peerDependencies.react")
```

> **Important:** `react` must be pinned to the exact version that `react-native` expects — no `^` prefix. A version mismatch between `react` and `react-native-renderer` will cause a runtime crash. The command above reads the exact version from `react-native`'s peer dependency and installs it.

Create `index.js` at the repo root:

```js
import { AppRegistry } from 'react-native';
import { TodosScreen } from './src/screens/TodosScreen';

AppRegistry.registerComponent('TodosScreen', () => TodosScreen);
```

If you plan to add more RN screens later, call `AppRegistry.registerComponent` once per screen with a unique string name. Each name becomes the `moduleName` you pass from Swift.

---

### Step 2 — Create your React Native component

Create `src/screens/TodosScreen/TodosScreen.tsx`:

```tsx
import React from 'react';
import { View, Text, StyleSheet } from 'react-native';

type Props = { userId: string };

export const TodosScreen: React.FC<Props> = ({ userId }) => (
  <View style={styles.container}>
    <Text>Todos for {userId}</Text>
  </View>
);

const styles = StyleSheet.create({
  container: { flex: 1, justifyContent: 'center', alignItems: 'center' },
});
```

Create `src/screens/TodosScreen/index.ts`:

```ts
export { TodosScreen } from './TodosScreen';
```

Props you pass via `initialProperties` in Swift arrive as top-level React props.

---

### Step 3 — Add TypeScript support (optional but recommended)

Install TypeScript and the RN config:

```bash
npm install --save-dev typescript @react-native/typescript-config @types/react
```

Create `tsconfig.json` at the repo root:

```json
{
  "extends": "@react-native/typescript-config/tsconfig.json",
  "compilerOptions": {
    "jsx": "react-native",
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true
  },
  "include": ["src/**/*", "index.js", "index.ts", "*.ts", "*.tsx"]
}
```

> The explicit `jsx` and `esModuleInterop` overrides are needed because VS Code can't fully resolve these from the package-level config reference.

---

### Step 4 — Configure the Podfile

Edit `ios/Podfile`. The full required structure:

```ruby
# Keep legacy arch API symbols compiled in (harmless, prevents linker issues)
ENV['RCT_REMOVE_LEGACY_ARCH'] = '0'

require Pod::Executable.execute_command('node', ['-p',
  'require.resolve("react-native/scripts/react_native_pods.rb", {paths: [process.argv[1]]})',
  __dir__]).strip

platform :ios, min_ios_version_supported
prepare_react_native_project!

target 'YourApp' do
  rn_path = '../node_modules/react-native'
  use_react_native!(
    :path => rn_path,
    :app_path => "#{Pod::Config.instance.installation_root}/.."
  )

  post_install do |installer|
    react_native_post_install(installer, rn_path, :mac_catalyst_enabled => false)
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['ENABLE_USER_SCRIPT_SANDBOXING'] = 'NO'
      end
    end
  end
end
```

Then run:

```bash
cd ios && pod install
```

> After `pod install`, always open `YourApp.xcworkspace`, not `YourApp.xcodeproj`.

---

### Step 5 — Set the Node binary path for Xcode

Create `ios/.xcode.env.local`:

```bash
export NODE_BINARY=$(which node)
```

If you use nvm, `which node` may not resolve correctly inside Xcode's build environment. In that case, use the absolute path:

```bash
export NODE_BINARY=/Users/you/.nvm/versions/node/v20.x.x/bin/node
```

---

### Step 6 — Create `RNBridge.swift`

Create `ios/YourApp/RNBridge.swift`:

```swift
import UIKit
import React
import React_RCTAppDelegate
import ReactAppDependencyProvider

/// Subclass provides Hermes JS runtime + bundle URL.
/// Inherits turbo module wiring and Fabric setup from the base class.
final class RNFactoryDelegate: RCTDefaultReactNativeFactoryDelegate {
    override func bundleURL() -> URL? {
#if DEBUG
        return RCTBundleURLProvider.sharedSettings()
            .jsBundleURL(forBundleRoot: "index")
#else
        return Bundle.main.url(forResource: "main", withExtension: "jsbundle")
#endif
    }
}

/// Singleton that owns the factory and its delegate.
/// Both must be kept alive for the lifetime of the app —
/// the factory holds the delegate weakly.
final class RNBridge {
    static let shared = RNBridge()
    private init() {}

    private var factoryDelegate: RNFactoryDelegate?
    private var reactNativeFactory: RCTReactNativeFactory?

    var isReady: Bool { reactNativeFactory != nil }

    func setup() {
        let delegate = RNFactoryDelegate()
        delegate.dependencyProvider = RCTAppDependencyProvider()
        let factory = RCTReactNativeFactory(delegate: delegate)
        self.factoryDelegate = delegate   // keep alive (factory holds it weakly)
        self.reactNativeFactory = factory
    }

    func createView(moduleName: String, initialProperties: [String: Any]? = nil) -> UIView {
        guard let factory = reactNativeFactory else {
            fatalError("Call RNBridge.setup() before creating views")
        }
        return factory.rootViewFactory
            .view(withModuleName: moduleName, initialProperties: initialProperties)
    }
}
```

**Why each import is needed:**

| Import | Provides |
|---|---|
| `React` | `RCTBundleURLProvider` |
| `React_RCTAppDelegate` | `RCTReactNativeFactory`, `RCTDefaultReactNativeFactoryDelegate`, `RCTRootViewFactory` |
| `ReactAppDependencyProvider` | `RCTAppDependencyProvider` — auto-generated by Codegen; registers all turbo modules and Fabric components |

---

### Step 7 — Create `AppDelegate.swift`

Create or edit `ios/YourApp/AppDelegate.swift`:

```swift
import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        RNBridge.shared.setup()
        return true
    }
}
```

In your SwiftUI `@main` struct, wire it up:

```swift
@main
struct YourApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup { ContentView() }
    }
}
```

> Calling `setup()` here starts the JS runtime and bundle load in the background, so the RN view is ready by the time the user navigates to it.

---

### Step 8 — Create the hosting `UIViewController`

Create `ios/YourApp/TodosRNViewController.swift`:

```swift
import UIKit
import SwiftUI

final class TodosRNViewController: UIViewController {
    private let userId: String

    init(userId: String) {
        self.userId = userId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard RNBridge.shared.isReady else { return }

        let rnView = RNBridge.shared.createView(
            moduleName: "TodosScreen",
            initialProperties: ["userId": userId]
        )
        rnView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(rnView)
        NSLayoutConstraint.activate([
            rnView.topAnchor.constraint(equalTo: view.topAnchor),
            rnView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            rnView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rnView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

// SwiftUI wrapper — use this anywhere in your SwiftUI view hierarchy
struct TodosRNView: UIViewControllerRepresentable {
    let userId: String

    func makeUIViewController(context: Context) -> TodosRNViewController {
        TodosRNViewController(userId: userId)
    }
    func updateUIViewController(_ vc: TodosRNViewController, context: Context) {}
}
```

Use it in SwiftUI:

```swift
TodosRNView(userId: currentUser.id)
```

---

### Step 9 — Call back to Swift from RN (optional)

If your RN screen needs to trigger native actions (open a sheet, navigate back, etc.), create an ObjC native module.

Create `ios/YourApp/YourNativeModule.m`:

```objc
#import <React/RCTBridgeModule.h>

@interface YourNativeModule : NSObject <RCTBridgeModule>
@end

@implementation YourNativeModule

RCT_EXPORT_MODULE();  // JS name: NativeModules.YourNativeModule

RCT_EXPORT_METHOD(openNewItem) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]
            postNotificationName:@"YourActionName" object:nil];
    });
}

+ (BOOL)requiresMainQueueSetup { return NO; }

@end
```

In your `UIViewController`, observe the notification:

```swift
NotificationCenter.default.addObserver(
    self,
    selector: #selector(handleAction),
    name: NSNotification.Name("YourActionName"),
    object: nil
)

@objc private func handleAction() {
    // present a sheet, push a VC, etc.
}
```

In your RN component:

```tsx
import { NativeModules } from 'react-native';

NativeModules.YourNativeModule.openNewItem();
```

> `RCT_EXPORT_MODULE()` with no arguments uses the ObjC class name as the JS module name. Make sure they match.

---

### Step 10 — Keep Firebase config out of source control

If your RN screen uses Firebase (or any secret), use `react-native-dotenv` instead of hardcoding values:

```bash
npm install --save-dev react-native-dotenv
```

Update `babel.config.js`:

```js
module.exports = {
  presets: ['module:@react-native/babel-preset'],
  plugins: [
    ['module:react-native-dotenv', {
      moduleName: '@env',
      path: '.env',
      safe: true,
      allowUndefined: false,
    }],
  ],
};
```

Create `.env` (gitignored) and `.env.example` (committed):

```
FIREBASE_API_KEY=your-key-here
FIREBASE_PROJECT_ID=your-project-id
```

Create `src/env.d.ts` for TypeScript:

```ts
declare module '@env' {
  export const FIREBASE_API_KEY: string;
  export const FIREBASE_PROJECT_ID: string;
}
```

Use in your config:

```ts
import { FIREBASE_API_KEY, FIREBASE_PROJECT_ID } from '@env';
```

---

### Step 11 — Build and run

Start Metro bundler from the repo root:

```bash
npx react-native start
```

Open `ios/YourApp.xcworkspace` in Xcode (not `.xcodeproj`), then:

1. Clean the build folder: **Cmd+Shift+K**
2. Build and run: **Cmd+R**

---

### Common errors and fixes

**`EXC_BAD_ACCESS` on `addSubview(rnView)`**
You are using `RCTBridge` + `RCTRootView`. These are dead stubs in RN 0.84. Replace them entirely with `RCTReactNativeFactory` + `RCTRootViewFactory` as shown in Step 6.

**"Delegate must implement a valid `createJSRuntimeFactory` method"**
You created `RCTRootViewFactory` directly without going through `RCTReactNativeFactory`. The factory sets up `jsRuntimeConfiguratorDelegate` internally — use `RCTDefaultReactNativeFactoryDelegate` as your delegate base class and let `RCTReactNativeFactory` wrap it.

**`pod install` re-injects `-DRCT_REMOVE_LEGACY_ARCH=1`**
Set `ENV['RCT_REMOVE_LEGACY_ARCH'] = '0'` at the very top of your Podfile, before any `require` statements.

**Xcode crashes on project open (SourceKit crash)**
Clean DerivedData (`~/Library/Developer/Xcode/DerivedData/`), delete any `.xcuserdatad` files from the `.xcodeproj`, then reopen the workspace.

**React version mismatch crash at runtime**
`react` was installed with a `^` prefix and npm resolved a newer patch version than `react-native-renderer` expects. Pin the version exactly — no caret: `"react": "19.2.3"`.

**Named vs default export mismatch in `index.js`**
If your component uses a named export (`export const TodosScreen`), import it with braces: `import { TodosScreen } from './src/screens/TodosScreen'`. Using `import TodosScreen from` (default import) with a named export gives you `undefined` at registration time.

**`.xcodeproj` vs `.xcworkspace`**
Always open `.xcworkspace` when CocoaPods is involved. The `.xcodeproj` does not include pod dependencies and the build will fail.
