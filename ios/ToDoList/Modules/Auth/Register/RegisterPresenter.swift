//
//  RegisterPresenter.swift
//  ToDoList
//
//  VIPER – Presenter
//  Owns all state the RegisterView binds to.
//  Validates the form fields before delegating to the Interactor.
//  On success, MainInteractor's auth-state listener fires automatically,
//  so no explicit navigation back is needed.
//

import Foundation

protocol RegisterPresenterProtocol: AnyObject {
    var name: String { get set }
    var email: String { get set }
    var password: String { get set }
    var errorMessage: String { get }
    func registerTapped()
}

final class RegisterPresenter: ObservableObject, RegisterPresenterProtocol {
    /// Two-way bound by the View's TextFields
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""

    /// Read-only from the View's perspective
    @Published private(set) var errorMessage: String = ""

    private let interactor: RegisterInteractorProtocol

    init(interactor: RegisterInteractorProtocol) {
        self.interactor = interactor
        self.interactor.output = self
    }

    func registerTapped() {
        guard validate() else { return }
        errorMessage = ""
        interactor.register(name: name, email: email, password: password)
    }

    private func validate() -> Bool {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty,
              !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty
        else {
            errorMessage = "Please fill in all fields!"
            return false
        }
        guard email.contains("@"), email.contains(".") else {
            errorMessage = "Please enter a valid email!"
            return false
        }
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."
            return false
        }
        return true
    }
}

extension RegisterPresenter: RegisterInteractorOutput {
    func registerDidSucceed() {
        // MainInteractor's auth-state listener fires automatically after
        // Firebase creates the user. MainPresenter picks up the new userId
        // and MainView switches to the tabs. Nothing extra needed here.
    }

    func registerDidFail(message: String) {
        errorMessage = message
    }
}
