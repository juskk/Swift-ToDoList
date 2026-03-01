//
//  ToDoListApp.swift
//  ToDoList
//
//  Created by user on 21.02.2026.
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
            MainView()
        }
    }
}
