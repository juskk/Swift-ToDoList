//
//  MainRouter.swift
//  ToDoList
//
//  VIPER – Router
//  Responsible for:
//    1. Assembling the whole Main module (wiring Interactor → Presenter → View).
//    2. Navigation ownership – as we add more modules (Auth, Tabs, etc.)
//       the Router will be the one deciding what to present next.
//

import SwiftUI

enum MainRouter {
    /// Builds the fully-wired Main module and returns its root View.
    /// Called once from ToDoListApp as the window's root content.
    @MainActor
    static func createModule() -> some View {
        let interactor = MainInteractor()
        let presenter = MainPresenter(interactor: interactor)
        return MainView(presenter: presenter)
    }
}
