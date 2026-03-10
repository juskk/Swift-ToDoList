//
//  NewItemPresenter.swift
//  ToDoList
//
//  VIPER – Presenter
//  Owns form state and validation for the NewItem sheet.
//  Sets isDismissed = true on success so the View can call dismiss().
//  Never imports Firebase.
//

import Foundation

protocol NewItemPresenterProtocol: AnyObject {
    var title: String { get set }
    var dueDate: Date { get set }
    var alertMessage: String { get }
    var isDismissed: Bool { get }
    func saveTapped()
    func dismissAlert()
}

final class NewItemPresenter: ObservableObject, NewItemPresenterProtocol {
    @Published var title: String = ""
    @Published var dueDate: Date = .init()
    @Published private(set) var alertMessage: String = ""
    @Published private(set) var isDismissed: Bool = false

    private let interactor: NewItemInteractorProtocol

    init(interactor: NewItemInteractorProtocol) {
        self.interactor = interactor
        self.interactor.output = self
    }

    func saveTapped() {
        guard validate() else { return }
        alertMessage = ""
        interactor.save(title: title, dueDate: dueDate)
    }

    func dismissAlert() {
        alertMessage = ""
    }

    private func validate() -> Bool {
        if title.trimmingCharacters(in: .whitespaces).isEmpty {
            alertMessage = "Please enter a title."
            return false
        }
        if dueDate < Date().addingTimeInterval(-86400) {
            alertMessage = "Due date must be today or in the future."
            return false
        }
        return true
    }
}

extension NewItemPresenter: NewItemInteractorOutput {
    func saveDidSucceed() {
        isDismissed = true
    }

    func saveDidFail(message: String) {
        alertMessage = message
    }
}
