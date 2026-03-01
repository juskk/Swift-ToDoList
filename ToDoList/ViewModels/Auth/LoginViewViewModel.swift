//
//  LoginViewViewModel.swift
//  ToDoList
//
//  Created by user on 21.02.2026.
//

import FirebaseAuth
import Foundation

class LoginViewViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    
    @Published var errorMessage: String = ""
    
    init() {}
    
    func login() {
        guard validate() else {
            return
        }

        errorMessage = ""
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] _, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func validate() -> Bool {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please fill in all fields!"
            return false
        }
        
        guard email.contains("@") && email.contains(".") else {
            errorMessage = "Please enter a valid email!"
            return false
        }
        
        return true
    }
}
