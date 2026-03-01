//
//  MainView.swift
//  ToDoList
//
//  Created by user on 21.02.2026.
//

import SwiftUI

struct MainView: View {
    @StateObject var viewModel = MainViewViewModel()
    
    @ViewBuilder
    var accountView: some View {
        TabView {
            ToDoListView(userId: viewModel.currentUserId)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
    
    var authView: some View {
        LoginView()
    }
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.isSignedIn, !viewModel.currentUserId.isEmpty {
                accountView
            } else {
                authView
            }
        }
        .onAppear {
            SettingsViewViewModel.applySavedAppearance()
        }
    }
}

#Preview {
    MainView()
}
