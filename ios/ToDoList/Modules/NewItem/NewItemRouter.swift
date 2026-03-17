//
//  NewItemRouter.swift
//  ToDoList
//
//  VIPER – Router
//  Assembles the NewItem module.
//  Called by TodoListRouter when the user taps "+".
//

import SwiftUI

enum NewItemRouter {
    static func createModule() -> NewItemView {
        let interactor = NewItemInteractor()
        let presenter = NewItemPresenter(interactor: interactor)
        return NewItemView(presenter: presenter)
    }
}
