//
//  MainView.swift
//  ToDoList
//
//  VIPER – View
//  Pure UI: it only reads from the Presenter and forwards user events to it.
//  Does NOT instantiate the Presenter itself – the Router injects it.
//

import SwiftUI

struct MainView: View {
    @StateObject private var presenter: MainPresenter

    init(presenter: MainPresenter) {
        _presenter = StateObject(wrappedValue: presenter)
    }

    private var accountView: some View {
        TabView {
            TodoListRouter.createModule(userId: presenter.currentUserId)
                .tabItem { Label("Home", systemImage: "house") }

            ProfileRouter.createModule()
                .tabItem { Label("Profile", systemImage: "person.circle") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }

    private var authView: some View {
        LoginRouter.createModule()
    }

    var body: some View {
        Group {
            if presenter.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            } else if presenter.isSignedIn {
                accountView

            } else {
                authView
            }
        }
        .onAppear {
            SettingsInteractor.applySavedAppearance()
        }
    }
}

#Preview {
    MainRouter.createModule()
}
