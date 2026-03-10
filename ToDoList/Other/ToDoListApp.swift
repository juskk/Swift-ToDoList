//
//  ToDoListApp.swift
//  ToDoList
//

import FirebaseCore
import SwiftUI

@main
struct ToDoListApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            MainRouter.createModule()
        }
    }
}
