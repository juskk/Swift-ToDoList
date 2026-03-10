//
//  MainPresenter.swift
//  ToDoList
//
//  VIPER – Presenter
//  Sits between the Interactor and the View.
//  Receives raw data from the Interactor, prepares it for display,
//  and exposes observable state the View binds to.
//  Never imports FirebaseAuth – all auth work stays in the Interactor.
//

import Foundation

protocol MainPresenterProtocol: AnyObject {
    var currentUserId: String { get }
    var isLoading: Bool { get }
    var isSignedIn: Bool { get }
}

final class MainPresenter: ObservableObject, MainPresenterProtocol {
    @Published private(set) var currentUserId: String = ""
    @Published private(set) var isLoading: Bool = true

    private let interactor: MainInteractorProtocol

    init(interactor: MainInteractorProtocol) {
        self.interactor = interactor
        self.interactor.output = self
        self.interactor.startObservingAuthState()
    }

    /// Derived from currentUserId so the View never has to check both
    var isSignedIn: Bool {
        !currentUserId.isEmpty
    }
}

extension MainPresenter: MainInteractorOutput {
    func authStateDidChange(userId: String?) {
        DispatchQueue.main.async {
            self.currentUserId = userId ?? ""
            self.isLoading = false
        }
    }
}
