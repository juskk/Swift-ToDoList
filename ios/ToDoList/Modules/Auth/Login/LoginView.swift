//
//  LoginView.swift
//  ToDoList
//
//  VIPER – View
//  Pure UI. Reads from the Presenter and forwards user actions to it.
//  Does NOT create the Presenter – the Router injects it.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var presenter: LoginPresenter

    init(presenter: LoginPresenter) {
        _presenter = StateObject(wrappedValue: presenter)
    }

    var body: some View {
        NavigationStack {
            VStack {
                HeaderView(
                    title: "To Do List",
                    subTitle: "Get Things Done",
                    angle: 15,
                    backgroundColor: .pink
                )

                Form {
                    TextField("Email Address", text: $presenter.email)
                        .textFieldStyle(DefaultTextFieldStyle())
                        .autocapitalization(.none)
                        .autocorrectionDisabled()

                    SecureField("Password", text: $presenter.password)
                        .textFieldStyle(DefaultTextFieldStyle())

                    TLButton(title: "Log In", color: .blue) {
                        presenter.loginTapped()
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

                VStack {
                    Text("New account here?")
                    Button {
                        presenter.showRegisterTapped()
                    } label: {
                        Text("Create an Account")
                            .foregroundColor(.blue)
                            .underline()
                    }
                }
                .padding(.bottom, 30)

                Spacer()
            }
            .navigationDestination(isPresented: $presenter.showRegister) {
                LoginRouter.makeRegisterView()
            }
        }
        .accentColor(.white)
    }
}

#Preview {
    LoginRouter.createModule()
}
