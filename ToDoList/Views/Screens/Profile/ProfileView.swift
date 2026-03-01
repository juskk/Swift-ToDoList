//
//  ProfileView.swift
//  ToDoList
//
//  Created by user on 21.02.2026.
//

import SwiftUI

struct ProfileView: View {
    @StateObject var viewModel = ProfileViewViewModel()
    
    @ViewBuilder
    func profile(user: User) -> some View {
        Image(systemName: "person.circle")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundStyle(Color.blue)
            .frame(width: 125, height: 125)
            .padding()
        
        VStack {
            HStack {
                Text("Name: ")
                Text(user.name)
            }
            HStack {
                Text("Email: ")
                Text(user.email)
            }
            HStack {
                Text("Member Since: ")
                Text("\(Date(timeIntervalSince1970: user.joined).formatted(date: .abbreviated, time: .shortened))")
            }
        }.padding()
        
        Button("Log Out") {
            viewModel.logOut()
        }
        .tint(.red)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if let user = viewModel.user {
                    profile(user: user)
                } else if viewModel.isLoading {
                    Text("Loading Profile...")
                } else if !viewModel.errorMessage.isEmpty {
                    VStack(spacing: 16) {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                        Button("Retry") {
                            viewModel.fetchUser()
                        }
                    }
                    .padding()
                }

                Spacer()
            }
            .navigationTitle("Profile")
            .alert("Log Out Failed", isPresented: Binding(
                get: { viewModel.logoutErrorMessage != nil },
                set: { if !$0 { viewModel.clearLogoutError() } }
            )) {
                Button("OK") {
                    viewModel.clearLogoutError()
                }
            } message: {
                Text(viewModel.logoutErrorMessage ?? "")
            }
        }
        .onAppear {
            viewModel.fetchUser()
        }
    }
}

#Preview {
    ProfileView()
}
