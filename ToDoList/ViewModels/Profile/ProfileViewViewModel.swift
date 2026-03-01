//
//  ProfileViewViewModel.swift
//  ToDoList
//
//  Created by user on 21.02.2026.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

class ProfileViewViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var logoutErrorMessage: String?

    init() {}

    func fetchUser() {
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }

        DispatchQueue.main.async { [weak self] in
            self?.isLoading = true
            self?.errorMessage = ""
        }

        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { [weak self] snapshot, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                guard let userData = snapshot?.data() else {
                    self?.errorMessage = "Could not load profile."
                    return
                }
                self?.user = User(
                    id: userData["id"] as? String ?? "",
                    name: userData["name"] as? String ?? "",
                    email: userData["email"] as? String ?? "",
                    joined: userData["joined"] as? TimeInterval ?? 0
                )
                self?.errorMessage = ""
            }
        }
    }

    func logOut() {
        do {
            try Auth.auth().signOut()
            logoutErrorMessage = nil
        } catch {
            logoutErrorMessage = error.localizedDescription
        }
    }

    func clearLogoutError() {
        logoutErrorMessage = nil
    }
}
