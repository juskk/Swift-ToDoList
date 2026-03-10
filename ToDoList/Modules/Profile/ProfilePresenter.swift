//
//  ProfilePresenter.swift
//  ToDoList
//
//  VIPER – Presenter
//  Translates Interactor results into observable view state.
//  Never imports Firebase.
//

import Foundation

protocol ProfilePresenterProtocol: AnyObject {
    var user: User? { get }
    var isLoading: Bool { get }
    var errorMessage: String { get }
    var logoutErrorMessage: String? { get }
    func viewDidAppear()
    func retryTapped()
    func logOutTapped()
    func clearLogoutError()
}

final class ProfilePresenter: ObservableObject, ProfilePresenterProtocol {
    @Published private(set) var user: User?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String = ""
    @Published private(set) var logoutErrorMessage: String?

    private let interactor: ProfileInteractorProtocol

    init(interactor: ProfileInteractorProtocol) {
        self.interactor = interactor
        self.interactor.output = self
    }

    func viewDidAppear() {
        fetchUser()
    }

    func retryTapped() {
        fetchUser()
    }

    func logOutTapped() {
        interactor.logOut()
    }

    func clearLogoutError() {
        logoutErrorMessage = nil
    }

    private func fetchUser() {
        isLoading = true
        errorMessage = ""
        interactor.fetchUser()
    }
}

extension ProfilePresenter: ProfileInteractorOutput {
    func fetchDidSucceed(user: User) {
        self.user = user
        isLoading = false
        errorMessage = ""
    }

    func fetchDidFail(message: String) {
        isLoading = false
        errorMessage = message
    }

    func logoutDidSucceed() {
        // MainInteractor's auth listener fires → MainPresenter clears userId
        // → MainView switches back to the auth screen automatically.
    }

    func logoutDidFail(message: String) {
        logoutErrorMessage = message
    }
}
