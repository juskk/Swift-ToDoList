//
//  TodoListRouter.swift
//  ToDoList
//
//  VIPER – Router
//  Assembles the TodoList module.
//  Also knows how to build the NewItem module (navigation destination).
//

import SwiftUI

enum TodoListRouter {
    static func createModule(userId: String) -> TodoListView {
        let interactor = TodoListInteractor()
        let presenter = TodoListPresenter(interactor: interactor, userId: userId)
        return TodoListView(presenter: presenter)
    }

    static func makeNewItemView() -> NewItemView {
        NewItemRouter.createModule()
    }
}
