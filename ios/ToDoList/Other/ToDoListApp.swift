//
//  ToDoListApp.swift
//  ToDoList
//

import FirebaseCore
import SwiftUI

@main
struct ToDoListApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            MainRouter.createModule()
        }
    }
}
