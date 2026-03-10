//
//  ProfileView.swift
//  ToDoList
//
//  VIPER – View
//  Pure UI. Reads from the Presenter, forwards actions to it.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var presenter: ProfilePresenter

    init(presenter: ProfilePresenter) {
        _presenter = StateObject(wrappedValue: presenter)
    }

    @ViewBuilder
    private func profileContent(user: User) -> some View {
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
                Text(Date(timeIntervalSince1970: user.joined)
                    .formatted(date: .abbreviated, time: .shortened))
            }
        }
        .padding()

        Button("Log Out") {
            presenter.logOutTapped()
        }
        .tint(.red)
    }

    var body: some View {
        NavigationView {
            VStack {
                if let user = presenter.user {
                    profileContent(user: user)

                } else if presenter.isLoading {
                    Text("Loading Profile...")

                } else if !presenter.errorMessage.isEmpty {
                    VStack(spacing: 16) {
                        Text(presenter.errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                        Button("Retry") {
                            presenter.retryTapped()
                        }
                    }
                    .padding()
                }

                Spacer()
            }
            .navigationTitle("Profile")
            .alert("Log Out Failed", isPresented: Binding(
                get: { presenter.logoutErrorMessage != nil },
                set: { if !$0 { presenter.clearLogoutError() } }
            )) {
                Button("OK") { presenter.clearLogoutError() }
            } message: {
                Text(presenter.logoutErrorMessage ?? "")
            }
        }
        .onAppear {
            presenter.viewDidAppear()
        }
    }
}

#Preview {
    ProfileRouter.createModule()
}
