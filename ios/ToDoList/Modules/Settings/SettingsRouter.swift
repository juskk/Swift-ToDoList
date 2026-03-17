//
//  SettingsRouter.swift
//  ToDoList
//
//  VIPER – Router
//  Assembles the Settings module and wraps it in a UINavigationController
//  so it can be embedded in the SwiftUI tab bar via UIViewControllerRepresentable.
//

import UIKit

enum SettingsRouter {
    static func createModule() -> UINavigationController {
        let interactor = SettingsInteractor()
        let presenter = SettingsPresenter(interactor: interactor)
        let viewController = SettingsViewController(presenter: presenter)
        presenter.view = viewController
        return UINavigationController(rootViewController: viewController)
    }
}
