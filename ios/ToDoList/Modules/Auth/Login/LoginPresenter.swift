//
//  LoginPresenter.swift
//  ToDoList
//
//  VIPER – Presenter
//  Owns all state the LoginView binds to.
//  Handles input validation (presentation-layer concern: deciding when/what
//  error to show). Delegates the actual Firebase call to the Interactor.
//  Tells the Router when navigation to Register is requested.
//

import Foundation

protocol LoginPresenterProtocol: AnyObject {
    var email: String { get set }
    var password: String { get set }
    var errorMessage: String { get }
    var showRegister: Bool { get set }
    func loginTapped()
    func showRegisterTapped()
}

final class LoginPresenter: ObservableObject, LoginPresenterProtocol {
    /// Two-way bound by the View's TextFields
    @Published var email: String = ""
    @Published var password: String = ""

    /// Read-only from the View's perspective
    @Published private(set) var errorMessage: String = ""

    /// Drives navigation to Register
    @Published var showRegister: Bool = false

    private let interactor: LoginInteractorProtocol

    init(interactor: LoginInteractorProtocol) {
        self.interactor = interactor
        self.interactor.output = self
    }

    func loginTapped() {
        guard validate() else { return }
        errorMessage = ""
        interactor.login(email: email, password: password)
    }

    func showRegisterTapped() {
        showRegister = true
    }

    private func validate() -> Bool {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty
        else {
            errorMessage = "Please fill in all fields!"
            return false
        }
        guard email.contains("@"), email.contains(".") else {
            errorMessage = "Please enter a valid email!"
            return false
        }
        return true
    }
}

extension LoginPresenter: LoginInteractorOutput {
    func loginDidSucceed() {
        // MainInteractor's auth-state listener fires automatically.
        // MainPresenter sees the new userId and MainView switches to the tabs.
        // No explicit navigation needed here.
    }

    func loginDidFail(message: String) {
        errorMessage = message
    }
}
