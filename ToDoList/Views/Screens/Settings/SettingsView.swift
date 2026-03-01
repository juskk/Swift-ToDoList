//
//  SettingsView.swift
//  ToDoList
//
//  Created by user on 21.02.2026.
//

import SwiftUI
import UIKit

/// SwiftUI wrapper so the UIKit Settings screen can be used in the SwiftUI tab bar.
struct SettingsView: View {
    var body: some View {
        SettingsViewControllerRepresentable()
    }
}

// MARK: - UIViewControllerRepresentable

private struct SettingsViewControllerRepresentable: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> UINavigationController {
        let viewModel = SettingsViewViewModel()
        let settingsVC = SettingsViewController(viewModel: viewModel)
        return UINavigationController(rootViewController: settingsVC)
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}

#Preview {
    SettingsView()
}
