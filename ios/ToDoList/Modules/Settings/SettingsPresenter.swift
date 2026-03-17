//
//  SettingsPresenter.swift
//  ToDoList
//
//  VIPER – Presenter (UIKit flavour)
//  Because Settings uses UIKit (UITableViewController), the classic VIPER
//  delegate pattern is used instead of @Published bindings:
//    - Presenter holds a weak reference to a SettingsViewProtocol.
//    - View calls Presenter methods for user actions.
//    - Presenter tells the View to reload when state changes.
//

import UIKit

// MARK: - View protocol (Presenter → View)

protocol SettingsViewProtocol: AnyObject {
    func reloadData()
}

// MARK: - Presenter protocol

protocol SettingsPresenterProtocol: AnyObject {
    var selectedAppearance: UIUserInterfaceStyle { get }
    func didSelectAppearance(_ style: UIUserInterfaceStyle)
}

// MARK: - Implementation

final class SettingsPresenter: SettingsPresenterProtocol {
    weak var view: SettingsViewProtocol?
    private let interactor: SettingsInteractorProtocol

    init(interactor: SettingsInteractorProtocol) {
        self.interactor = interactor
        self.interactor.output = self
    }

    // MARK: - SettingsPresenterProtocol

    var selectedAppearance: UIUserInterfaceStyle {
        interactor.savedAppearance
    }

    func didSelectAppearance(_ style: UIUserInterfaceStyle) {
        interactor.setAppearance(style)
    }
}

// MARK: - SettingsInteractorOutput

extension SettingsPresenter: SettingsInteractorOutput {
    func appearanceDidChange() {
        view?.reloadData()
    }
}
