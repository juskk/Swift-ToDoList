//
//  MainViewViewModel.swift
//  ToDoList
//
//  Created by user on 21.02.2026.
//

import FirebaseAuth
import Foundation

class MainViewViewModel: ObservableObject {
    @Published var currentUserId: String = ""
    @Published var isLoading = true
    private var handler: AuthStateDidChangeListenerHandle?

    init() {
        self.handler = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.currentUserId = user?.uid ?? ""
                self?.isLoading = false
            }
        }
    }

    deinit {
        if let handler = handler {
            Auth.auth().removeStateDidChangeListener(handler)
        }
    }

    var isSignedIn: Bool {
        return Auth.auth().currentUser != nil
    }
}
