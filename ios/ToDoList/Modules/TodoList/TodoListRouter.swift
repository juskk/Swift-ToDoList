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
    /// Returns the React Native host as the TodoList View layer.
    /// RN owns list UI and data; Swift passes only the userId.
    static func createModule(userId: String) -> some View {
        TodosRNView(userId: userId)
    }

    static func makeNewItemView() -> NewItemView {
        NewItemRouter.createModule()
    }
}
