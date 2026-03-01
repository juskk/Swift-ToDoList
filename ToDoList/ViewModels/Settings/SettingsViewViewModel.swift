//
//  SettingsViewViewModel.swift
//  ToDoList
//
//  Created by user on 21.02.2026.
//

import UIKit

/// ViewModel for the Settings screen (UIKit). Handles appearance preference and applies it to the app window.
final class SettingsViewViewModel {

    private let userDefaultsKey = "app_interface_style"

    /// Called when the user changes appearance so the UI can refresh (e.g. checkmarks).
    var onAppearanceChanged: (() -> Void)?

    /// Current appearance style (persisted).
    var selectedAppearance: UIUserInterfaceStyle {
        get {
            let raw = UserDefaults.standard.integer(forKey: userDefaultsKey)
            return UIUserInterfaceStyle(rawValue: raw) ?? .unspecified
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: userDefaultsKey)
            applyAppearance(newValue)
            onAppearanceChanged?()
        }
    }

    init() {}

    /// Apply the given style to the key window. Call at launch to apply saved preference.
    func applyAppearance(_ style: UIUserInterfaceStyle) {
        guard let window = Self.keyWindow else { return }
        window.overrideUserInterfaceStyle = style
    }

    /// Apply the saved appearance to the key window. Call once when the app becomes active (e.g. from MainView).
    static func applySavedAppearance() {
        let raw = UserDefaults.standard.integer(forKey: "app_interface_style")
        let style = UIUserInterfaceStyle(rawValue: raw)
        guard let window = keyWindow else { return }
        window.overrideUserInterfaceStyle = style ?? .unspecified
    }

    private static var keyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
}
