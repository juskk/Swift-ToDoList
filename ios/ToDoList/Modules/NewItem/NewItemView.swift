//
//  NewItemView.swift
//  ToDoList
//
//  VIPER – View
//  Pure UI. Reads from the Presenter, forwards actions to it.
//  Watches presenter.isDismissed and calls SwiftUI's dismiss() when true —
//  this is a navigation mechanism, not business logic, so it lives here.
//

import SwiftUI

struct NewItemView: View {
    @StateObject private var presenter: NewItemPresenter
    @Environment(\.dismiss) private var dismiss

    init(presenter: NewItemPresenter) {
        _presenter = StateObject(wrappedValue: presenter)
    }

    var body: some View {
        VStack {
            Text("New Item")
                .font(.system(size: 32))
                .bold()
                .padding(.top, 24)

            Form {
                TextField("Title", text: $presenter.title)
                    .textFieldStyle(DefaultTextFieldStyle())

                DatePicker("Due Date", selection: $presenter.dueDate)
                    .datePickerStyle(GraphicalDatePickerStyle())

                TLButton(title: "Save", color: .pink) {
                    presenter.saveTapped()
                }
                .padding(.top, 30)
                .padding(.bottom, 15)
                .padding(.horizontal, 30)
            }
            .alert("Error", isPresented: Binding(
                get: { !presenter.alertMessage.isEmpty },
                set: { if !$0 { presenter.dismissAlert() } }
            )) {
                Button("OK") { presenter.dismissAlert() }
            } message: {
                Text(presenter.alertMessage)
            }
        }
        .onChange(of: presenter.isDismissed) { dismissed in
            if dismissed { dismiss() }
        }
    }
}

#Preview {
    NewItemRouter.createModule()
}
