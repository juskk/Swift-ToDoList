//
//  TodoListPresenter.swift
//  ToDoList
//
//  VIPER – Presenter
//  Owns all observable state for the todo list screen.
//  Receives raw data from the Interactor and exposes it to the View.
//  Never imports Firebase.
//

import Foundation

protocol TodoListPresenterProtocol: AnyObject {
    var items: [ToDoListItem] { get }
    var showingNewItem: Bool { get set }
    func deleteTapped(id: String)
    func toggleDoneTapped(item: ToDoListItem)
    func addTapped()
}

final class TodoListPresenter: ObservableObject, TodoListPresenterProtocol {
    @Published private(set) var items: [ToDoListItem] = []
    @Published var showingNewItem: Bool = false

    private let interactor: TodoListInteractorProtocol

    init(interactor: TodoListInteractorProtocol, userId: String) {
        self.interactor = interactor
        self.interactor.output = self
        self.interactor.startObserving(userId: userId)
    }

    func deleteTapped(id: String) {
        interactor.delete(id: id)
    }

    func toggleDoneTapped(item: ToDoListItem) {
        interactor.toggleDone(item: item)
    }

    func addTapped() {
        showingNewItem = true
    }
}

extension TodoListPresenter: TodoListInteractorOutput {
    func itemsDidUpdate(_ items: [ToDoListItem]) {
        self.items = items
    }

    func deleteDidFail(message _: String) {
        // TODO: surface error alert when needed
    }

    func toggleDidFail(message _: String) {
        // TODO: surface error alert when needed
    }
}
