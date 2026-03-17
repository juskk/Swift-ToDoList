//
//  RegisterInteractor.swift
//  ToDoList
//
//  VIPER – Interactor
//  The only layer that touches FirebaseAuth and Firestore for the register use case.
//  1. Creates the Firebase Auth user.
//  2. Writes the User document to Firestore.
//  Reports the result back to the Presenter via RegisterInteractorOutput.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

protocol RegisterInteractorOutput: AnyObject {
    func registerDidSucceed()
    func registerDidFail(message: String)
}

protocol RegisterInteractorProtocol: AnyObject {
    var output: RegisterInteractorOutput? { get set }
    func register(name: String, email: String, password: String)
}

final class RegisterInteractor: RegisterInteractorProtocol {
    weak var output: RegisterInteractorOutput?

    func register(name: String, email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error {
                    self?.output?.registerDidFail(message: error.localizedDescription)
                    return
                }
                guard let userId = result?.user.uid else {
                    self?.output?.registerDidFail(message: "Something went wrong. Please try again.")
                    return
                }
                self?.insertUserRecord(id: userId, name: name, email: email)
            }
        }
    }

    private func insertUserRecord(id: String, name: String, email: String) {
        let newUser = User(
            id: id,
            name: name,
            email: email,
            joined: Date().timeIntervalSince1970
        )

        Firestore.firestore()
            .collection("users")
            .document(id)
            .setData(newUser.asDictionary()) { [weak self] error in
                DispatchQueue.main.async {
                    if let error {
                        self?.output?.registerDidFail(message: error.localizedDescription)
                    } else {
                        self?.output?.registerDidSucceed()
                    }
                }
            }
    }
}
