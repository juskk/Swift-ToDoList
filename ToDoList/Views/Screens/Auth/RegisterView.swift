//
//  RegisterView.swift
//  ToDoList
//
//  Created by user on 21.02.2026.
//

import SwiftUI

struct RegisterView: View {
    @StateObject var viewModel = RegisterViewViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack {
                HeaderView(title: "Register", subTitle: "Start Organizing Todos", angle: -15, backgroundColor: Color.orange)

                Form {
                    TextField("Name", text: $viewModel.name)
                        .textFieldStyle(DefaultTextFieldStyle())
                        .autocapitalization(.none)
                        .autocorrectionDisabled(true)
                    TextField("Email", text: $viewModel.email)
                        .textFieldStyle(DefaultTextFieldStyle())
                        .autocapitalization(.none)
                        .autocorrectionDisabled(true)
                    SecureField("Password", text: $viewModel.password)
                        .textFieldStyle(DefaultTextFieldStyle())

                    TLButton(title: "Create Account", color: Color.green, action: {
                        viewModel.register()
                    })
                    .padding(.top, 30)
                    .padding(.bottom, 15)
                    .padding(.horizontal, 30)

                    if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .foregroundColor(Color.red)
                            .multilineTextAlignment(.center)
                    }
                }

                Spacer()
            }

            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(.leading, 16)
                    .padding(.top, 10)
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    RegisterView()
}
