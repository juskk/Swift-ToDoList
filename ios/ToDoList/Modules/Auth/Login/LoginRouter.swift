//
//  LoginRouter.swift
//  ToDoList
//
//  VIPER – Router
//  Responsible for:
//    1. Assembling the Login module (wires Interactor → Presenter → View).
//    2. Building the Register module when the user wants to create an account.
//       The View drives the navigation trigger; the Router owns what is shown.
//

import SwiftUI

enum LoginRouter {
    /// Builds the fully-wired Login module.
    static func createModule() -> LoginView {
        let interactor = LoginInteractor()
        let presenter = LoginPresenter(interactor: interactor)
        return LoginView(presenter: presenter)
    }

    /// Builds the Register module that Login navigates to.
    static func makeRegisterView() -> RegisterView {
        RegisterRouter.createModule()
    }
}
