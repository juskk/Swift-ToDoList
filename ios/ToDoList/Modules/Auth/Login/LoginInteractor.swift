//
//  LoginInteractor.swift
//  ToDoList
//
//  VIPER – Interactor
//  The only layer that touches FirebaseAuth for the login use case.
//  Receives a plain email/password, executes the Firebase call,
//  and reports the result back to the Presenter via LoginInteractorOutput.
//

import FirebaseAuth
import Foundation

protocol LoginInteractorOutput: AnyObject {
    func loginDidSucceed()
    func loginDidFail(message: String)
}

protocol LoginInteractorProtocol: AnyObject {
    var output: LoginInteractorOutput? { get set }
    func login(email: String, password: String)
}

final class LoginInteractor: LoginInteractorProtocol {
    weak var output: LoginInteractorOutput?

    func login(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] _, error in
            DispatchQueue.main.async {
                if let error {
                    self?.output?.loginDidFail(message: error.localizedDescription)
                } else {
                    self?.output?.loginDidSucceed()
                }
            }
        }
    }
}
