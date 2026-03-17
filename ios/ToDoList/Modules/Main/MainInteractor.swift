//
//  MainInteractor.swift
//  ToDoList
//
//  VIPER – Interactor
//  Owns the auth-state Firebase listener.
//  Notifies its output (Presenter) whenever the signed-in user changes.
//

import FirebaseAuth
import Foundation

protocol MainInteractorOutput: AnyObject {
    func authStateDidChange(userId: String?)
}

protocol MainInteractorProtocol: AnyObject {
    var output: MainInteractorOutput? { get set }
    func startObservingAuthState()
}

final class MainInteractor: MainInteractorProtocol {
    weak var output: MainInteractorOutput?

    private var listenerHandle: AuthStateDidChangeListenerHandle?

    func startObservingAuthState() {
        listenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.output?.authStateDidChange(userId: user?.uid)
        }
    }

    deinit {
        if let handle = listenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
