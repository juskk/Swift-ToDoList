//
//  ProfileRouter.swift
//  ToDoList
//
//  VIPER – Router
//  Assembles the Profile module.
//

import SwiftUI

enum ProfileRouter {
    static func createModule() -> ProfileView {
        let interactor = ProfileInteractor()
        let presenter = ProfilePresenter(interactor: interactor)
        return ProfileView(presenter: presenter)
    }
}
