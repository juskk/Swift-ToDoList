//
//  ToDoListItemView.swift
//  ToDoList
//
//  Shared reusable row component. No ViewModel, no Firebase.
//  The toggle action is passed in as a closure by the parent (TodoListView),
//  which routes it through TodoListPresenter → TodoListInteractor.
//

import SwiftUI

struct ToDoListItemView: View {
    let item: ToDoListItem
    let onToggle: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(item.title)
                    .font(.body)
                    .bold()
                Text(Date(timeIntervalSince1970: item.dueDate)
                    .formatted(date: .abbreviated, time: .shortened))
                    .font(.footnote)
                    .foregroundColor(Color(.secondaryLabel))
            }

            Spacer()

            Button(action: onToggle) {
                Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(.blue)
            }
        }
    }
}

#Preview {
    ToDoListItemView(
        item: ToDoListItem(
            id: "1", title: "Buy milk",
            dueDate: Date().timeIntervalSince1970,
            createdDate: Date().timeIntervalSince1970,
            isDone: false
        ),
        onToggle: {}
    )
}
