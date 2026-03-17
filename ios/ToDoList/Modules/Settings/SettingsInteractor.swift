//
//  SettingsInteractor.swift
//  ToDoList
//
//  VIPER – Interactor
//  Owns UserDefaults persistence and UIWindow appearance changes.
//  This is the only place in the Settings feature that reads/writes UserDefaults
//  and applies the overrideUserInterfaceStyle to the app window.
//

import UIKit

// MARK: - Output (Interactor → Presenter)

protocol SettingsInteractorOutput: AnyObject {
    func appearanceDidChange()
}

// MARK: - Protocol

protocol SettingsInteractorProtocol: AnyObject {
    var output: SettingsInteractorOutput? { get set }
    var savedAppearance: UIUserInterfaceStyle { get }
    func setAppearance(_ style: UIUserInterfaceStyle)
}

// MARK: - Implementation

final class SettingsInteractor: SettingsInteractorProtocol {
    weak var output: SettingsInteractorOutput?

    private let defaultsKey = "app_interface_style"

    var savedAppearance: UIUserInterfaceStyle {
        let raw = UserDefaults.standard.integer(forKey: defaultsKey)
        return UIUserInterfaceStyle(rawValue: raw) ?? .unspecified
    }

    func setAppearance(_ style: UIUserInterfaceStyle) {
        UserDefaults.standard.set(style.rawValue, forKey: defaultsKey)
        applyToWindow(style)
        output?.appearanceDidChange()
    }

    // MARK: - Static helper called at launch from MainView

    /// Applies the persisted appearance preference to the key window.
    /// Called once on app launch (from MainView.onAppear) before the
    /// Settings module is instantiated.
    static func applySavedAppearance() {
        let raw = UserDefaults.standard.integer(forKey: "app_interface_style")
        let style = UIUserInterfaceStyle(rawValue: raw) ?? .unspecified
        guard let window = keyWindow else { return }
        window.overrideUserInterfaceStyle = style
    }

    // MARK: - Private

    private func applyToWindow(_ style: UIUserInterfaceStyle) {
        guard let window = Self.keyWindow else { return }
        window.overrideUserInterfaceStyle = style
    }

    private static var keyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
}
