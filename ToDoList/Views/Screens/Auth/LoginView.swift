//
//  LoginView.swift
//  ToDoList
//
//  Created by user on 21.02.2026.
//

import SwiftUI

struct LoginView: View {
    @StateObject var viewModel = LoginViewViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                HeaderView(title: "To Do List", subTitle: "Get Things Done", angle: 15, backgroundColor: Color.pink)

                Form {
                    TextField("Email Address", text: $viewModel.email)
                        .textFieldStyle(DefaultTextFieldStyle())
                        .autocapitalization(.none)
                        .autocorrectionDisabled(true)
                    SecureField("Password", text: $viewModel.password)
                        .textFieldStyle(DefaultTextFieldStyle())

                    TLButton(title: "Log In", color: Color.blue, action: {
                        viewModel.login()
                    })
                    .padding(.top, 30)
                    .padding(.bottom, 15)
                    .padding(.horizontal, 30)

                    if !viewModel.errorMessage.isEmpty {
                        VStack {
                            Text(viewModel.errorMessage)
                                .foregroundColor(Color.red)
                                .multilineTextAlignment(.center)
                        }
                    }
                }

                VStack {
                    Text("New account here?")
                    NavigationLink(destination: RegisterView()) {
                        Text("Create an Account")
                            .foregroundColor(.blue)
                            .underline()
                    }
                }
                .padding(.bottom, 30)

                Spacer()
            }
        }
        .accentColor(.white)
    }
}


#Preview {
    LoginView()
}
