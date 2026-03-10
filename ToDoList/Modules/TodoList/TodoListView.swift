//
//  TodoListView.swift
//  ToDoList
//
//  VIPER – View
//  Pure UI. Reads from the Presenter, forwards actions to it.
//  The toggle action is passed as a closure to ToDoListItemView so the
//  row has no ViewModel of its own — all mutations go through this Presenter.
//

import SwiftUI

struct TodoListView: View {
    @StateObject private var presenter: TodoListPresenter

    init(presenter: TodoListPresenter) {
        _presenter = StateObject(wrappedValue: presenter)
    }

    var body: some View {
        NavigationView {
            List(presenter.items) { item in
                ToDoListItemView(item: item) {
                    presenter.toggleDoneTapped(item: item)
                }
                .swipeActions {
                    Button("Delete") {
                        presenter.deleteTapped(id: item.id)
                    }
                    .tint(.red)
                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle("To Do List")
            .toolbar {
                Button {
                    presenter.addTapped()
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $presenter.showingNewItem) {
                TodoListRouter.makeNewItemView()
            }
        }
    }
}

#Preview {
    TodoListRouter.createModule(userId: "id")
}
