//
//  ProfileInteractor.swift
//  ToDoList
//
//  VIPER – Interactor
//  Only place that touches FirebaseAuth and Firestore for the Profile feature.
//  Handles two use cases: fetching the user document and signing out.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

protocol ProfileInteractorOutput: AnyObject {
    func fetchDidSucceed(user: User)
    func fetchDidFail(message: String)
    func logoutDidSucceed()
    func logoutDidFail(message: String)
}

protocol ProfileInteractorProtocol: AnyObject {
    var output: ProfileInteractorOutput? { get set }
    func fetchUser()
    func logOut()
}

final class ProfileInteractor: ProfileInteractorProtocol {
    weak var output: ProfileInteractorOutput?

    func fetchUser() {
        guard let userId = Auth.auth().currentUser?.uid else {
            output?.fetchDidFail(message: "No signed-in user found.")
            return
        }

        Firestore.firestore()
            .collection("users")
            .document(userId)
            .getDocument { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    if let error {
                        self?.output?.fetchDidFail(message: error.localizedDescription)
                        return
                    }
                    guard let data = snapshot?.data() else {
                        self?.output?.fetchDidFail(message: "Could not load profile.")
                        return
                    }
                    let user = User(
                        id: data["id"] as? String ?? "",
                        name: data["name"] as? String ?? "",
                        email: data["email"] as? String ?? "",
                        joined: data["joined"] as? TimeInterval ?? 0
                    )
                    self?.output?.fetchDidSucceed(user: user)
                }
            }
    }

    func logOut() {
        do {
            try Auth.auth().signOut()
            output?.logoutDidSucceed()
        } catch {
            output?.logoutDidFail(message: error.localizedDescription)
        }
    }
}
