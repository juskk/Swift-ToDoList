//
//  RegisterRouter.swift
//  ToDoList
//
//  VIPER – Router
//  Assembles the Register module (wires Interactor → Presenter → View).
//  Called by LoginRouter when the user taps "Create an Account".
//

import SwiftUI

enum RegisterRouter {
    /// Builds the fully-wired Register module.
    static func createModule() -> RegisterView {
        let interactor = RegisterInteractor()
        let presenter = RegisterPresenter(interactor: interactor)
        return RegisterView(presenter: presenter)
    }
}
