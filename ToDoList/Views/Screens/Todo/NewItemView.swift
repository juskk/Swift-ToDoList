//
//  NewItemView.swift
//  ToDoList
//
//  Created by user on 21.02.2026.
//

import SwiftUI

struct NewItemView: View {
    @StateObject var viewModel = NewItemViewViewModel()
    @Binding var newItemPresented: Bool
    
    var body: some View {
        VStack {
            Text("New Item")
                .font(.system(size: 32))
                .bold()
                .padding(.top, 24)
            
            Form {
                TextField("Title", text: $viewModel.title)
                    .textFieldStyle(DefaultTextFieldStyle())
                
                DatePicker("DueDate", selection: $viewModel.dueDate)
                    .datePickerStyle(GraphicalDatePickerStyle())
                
                TLButton(title: "Save", color: .pink) {
                    if viewModel.canSave {
                        viewModel.save { result in
                            switch result {
                                case .success:
                                    newItemPresented = false
                                case .failure(let error):
                                    viewModel.alertMessage = error.localizedDescription
                                    viewModel.showAlert = true
                            }
                        }
                    } else {
                        viewModel.alertMessage = viewModel.validationMessage
                        viewModel.showAlert = true
                    }
                }
                    .padding(.top, 30)
                    .padding(.bottom, 15)
                    .padding(.horizontal, 30)
            }
            .alert("Error", isPresented: $viewModel.showAlert) {
                Button("OK") {}
            } message: {
                Text(viewModel.alertMessage)
            }
        }
    }
}

#Preview {
    NewItemView(newItemPresented: Binding(get: { return true }, set: { _ in }))
}
