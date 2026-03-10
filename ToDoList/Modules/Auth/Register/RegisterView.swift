//
//  RegisterView.swift
//  ToDoList
//
//  VIPER – View
//  Pure UI. Reads from the Presenter and forwards user actions to it.
//  Does NOT create the Presenter – the Router injects it.
//  Uses @Environment(\.dismiss) to go back – this is a SwiftUI navigation
//  mechanism, not business logic, so it belongs in the View.
//

import SwiftUI

struct RegisterView: View {
    @StateObject private var presenter: RegisterPresenter
    @Environment(\.dismiss) private var dismiss

    init(presenter: RegisterPresenter) {
        _presenter = StateObject(wrappedValue: presenter)
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack {
                HeaderView(
                    title: "Register",
                    subTitle: "Start Organizing Todos",
                    angle: -15,
                    backgroundColor: .orange
                )

                Form {
                    TextField("Name", text: $presenter.name)
                        .textFieldStyle(DefaultTextFieldStyle())
                        .autocapitalization(.none)
                        .autocorrectionDisabled()

                    TextField("Email", text: $presenter.email)
                        .textFieldStyle(DefaultTextFieldStyle())
                        .autocapitalization(.none)
                        .autocorrectionDisabled()

                    SecureField("Password", text: $presenter.password)
                        .textFieldStyle(DefaultTextFieldStyle())

                    TLButton(title: "Create Account", color: .green) {
                        presenter.registerTapped()
                    }
                    .padding(.top, 30)
                    .padding(.bottom, 15)
                    .padding(.horizontal, 30)

                    if !presenter.errorMessage.isEmpty {
                        Text(presenter.errorMessage)
                            .foregroundColor(.red)
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
    RegisterRouter.createModule()
}
