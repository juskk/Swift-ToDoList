//
//  SettingsView.swift
//  ToDoList
//
//  VIPER – SwiftUI bridge
//  Thin UIViewControllerRepresentable wrapper so the fully-assembled
//  Settings module (UINavigationController from SettingsRouter) can live
//  inside the SwiftUI tab bar.
//

import SwiftUI
import UIKit

struct SettingsView: View {
    var body: some View {
        SettingsRepresentable()
    }
}

// MARK: - UIViewControllerRepresentable

private struct SettingsRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context _: Context) -> UINavigationController {
        SettingsRouter.createModule()
    }

    func updateUIViewController(_: UINavigationController,
                                context _: Context) {}
}

// MARK: - Preview

#Preview {
    SettingsView()
}
